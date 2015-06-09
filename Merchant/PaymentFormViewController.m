//
//  SubmitFormViewController.m
//  Paypoint
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "PaymentFormViewController.h"
#import "Reachability.h"
#import "OutcomeViewController.h"
#import "NetworkErrorManager.h"
#import "ColourManager.h"
#import "MerchantServer.h"
#import "EnvironmentManager.h"

@interface PaymentFormViewController ()
@property (nonatomic, strong) PPOPaymentManager *paymentManager;
@property (nonatomic, strong) PPOPayment *currentPayment;
@end

@implementation PaymentFormViewController

-(PPOPaymentManager *)paymentManager {
    
    if (_paymentManager == nil) {
        
        /*
         *A selection of environments are available.
         *Envionrments differ by baseURL.
         *A list of baseURL's are accessible via 'PPOEnvironment' keys.
         */
        PPOEnvironment currentEnvironment = [EnvironmentManager currentEnvironment];
        
        /*
         *Alternatively, a custom URL can be passed in here.
         */
        NSURL *baseURL = [PPOPaymentBaseURLManager baseURLForEnvironment:currentEnvironment];
        
        _paymentManager = [[PPOPaymentManager alloc] initWithBaseURL:baseURL];
        
    }
    return _paymentManager;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Details";
    self.payNowButton.accessibilityLabel = @"PayNowButton";
    
    /*
     *A value of £100 assigned to the UI here, just for aesthetics
     *The true payment value is delievered via the model, which is built when the payment is initiated (via the paynow button pressed action).
     */
    self.amountLabel.text = @"£100";
    self.amountLabel.textColor = [ColourManager ppBlue];
    self.amountLabel.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 40];
}

#pragma mark - Actions

-(IBAction)payNowButtonPressed:(UIBarButtonItem *)button {
    
    [self.view endEditing:YES];
    
    /*
     *Nothing will happen if this button is pressed, and the animation is still underway.
     *It should be impossible to press the button when the animation is in progress, because a view is placed on top of the button, which blocks gestures.
     *But an animation state check is being done here anyway.
    */
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"There is no internet connection"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil, nil]
         show];
        
    } else if (self.animationManager.animationState == LOADING_ANIMATION_STATE_ENDED) {
        
        PPOPayment *payment = [self buildPaymentExample];
        
        [self makePayment:payment];
        
    }
        
}

-(void)makePayment:(PPOPayment*)payment {
    
    self.currentPayment = payment;
        
    /*
     *Payments require credentials.
     *Optional validation can be performed here, before we begin this process.
     */
    NSError *invalid = [PPOValidator validatePayment:payment];
    
    if (invalid) {
        [self handleError:invalid];
        return;
    }
    
    [self.animationManager hideFeedbackBubble];
    [self.animationManager beginLoadingAnimation];
    
    __weak typeof (self) weakSelf = self;
    
    [MerchantServer getCredentialsWithCompletion:^(PPOCredentials *credentials, NSError *retrievalError) {
        
        if (retrievalError) {
            [weakSelf handleError:retrievalError];
            return;
        }
        
        payment.credentials = credentials;
        
        /*
         *The PaypointSDK performs paramater validation, to the best extent possible, before any network request is made.
         */
        [weakSelf.paymentManager makePayment:payment
                                 withTimeOut:self.form.timeout.doubleValue
                              withCompletion:[weakSelf paymentCompletionHandler]];
        
    }];
    
}

-(PPOPayment*)buildPaymentExample {
    PPOBillingAddress *address = [PPOBillingAddress new];
    address.line1 = @"Street 1";
    address.line2 = @"Street 2";
    address.line3 = @"Street 3";
    address.line4 = @"Street 4";
    address.city = @"City";
    address.region = @"Region";
    address.postcode = @"Postcode";
    address.countryCode = @"Country Code";
    
    PPOTransaction *transaction = [PPOTransaction new];
    transaction.currency = @"GBP";
    transaction.amount = @100;
    transaction.transactionDescription = @"A desc";
    transaction.merchantRef = [NSString stringWithFormat:@"mer_%.0f", [[NSDate date] timeIntervalSince1970]];
    transaction.isDeferred = @NO;
    
    PPOCreditCard *card = [PPOCreditCard new];
    card.pan = self.form.cardNumber;
    card.cvv = self.form.cvv;
    card.expiry = self.form.expiry;
    card.cardHolderName = @"Dai Jones";
    
    PPOPayment *payment = [PPOPayment new];
    payment.transaction = transaction;
    payment.card = card;
    payment.address = address;
    
    return payment;
}

-(void(^)(PPOOutcome *outcome))paymentCompletionHandler {
    __weak typeof (self) weakSelf = self;
    return ^ (PPOOutcome *outcome) {
        if (outcome.error) {
            [weakSelf handleError:outcome.error];
        } else {
            [weakSelf.animationManager endLoadingAnimationWithCompletion:^{
                [weakSelf performSegueWithIdentifier:@"OutcomeViewControllerSegueID" sender:outcome];
            }];
        }
    };
}

#pragma mark - Error Handling

-(void)handleError:(NSError*)error {
    
    __weak typeof(self) weakSelf = self;
    
    BOOL isPaymentError = error && [error.domain isEqualToString:PPOPaymentErrorDomain];
    BOOL isLocalValidationError = error && [error.domain isEqualToString:PPOLocalValidationErrorDomain];
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if (isPaymentError) {
            
            [weakSelf handlePaymentError:error];
            
        } else if (isLocalValidationError) {
            
            [weakSelf.animationManager showFeedbackBubbleWithText:[error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                                                   withCompletion:[weakSelf shakeUIForValidationError:error]];
            
        } else {
            
            [self displayPaymentQueryOptionWithMessage:@"An unforseen error occured and we were unable to determine the outcome of your payment. Would you like to check the status of your payment now ?"
                                             withTitle:@"Error"];
            
        }
        
    }];
    
}

-(void)displayPaymentQueryOptionWithMessage:(NSString*)message withTitle:(NSString*)title {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action;
    
    action = [UIAlertAction actionWithTitle:@"Check Status"
                                      style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction *action) {
                                        id completion = [weakSelf paymentCompletionHandler];
                                        [weakSelf.paymentManager queryPayment:weakSelf.currentPayment withCompletion:completion];
                                    }];
    
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Dismiss"
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
    
}

-(void)handlePaymentError:(NSError*)error {
    
    switch (error.code) {
        case PPOPaymentErrorMasterSessionTimedOut: {
            [self displayPaymentQueryOptionWithMessage:@"Would you like to check the status of this payment ?" withTitle:@"Session Timeout"];
        }
            break;
            
        case PPOPaymentErrorPaymentProcessing: {
            [self displayPaymentQueryOptionWithMessage:@"Would you like to check the status of this payment again ?" withTitle:@"Payment In Progress"];
        }
            break;
            
        default: {
            [self displayPaymentQueryOptionWithMessage:@"An unforseen error occured and we were unable to determine the outcome of your payment. Would you like to check the status of your payment now ?" withTitle:@"Error"];
        }
            break;
    }
    
}

-(void(^)(void))shakeUIForValidationError:(NSError*)error {
    
    __weak typeof(self) weakSelf = self;
    
    return ^ {
        
        PPOLocalValidationError code = error.code;
        
        UITextField *textField;
        
        switch (code) {
            case PPOLocalValidationErrorCardPanInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_CARD_NUMBER]; break;
            case PPOLocalValidationErrorCardExpiryDateInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_EXPIRY]; break;
            case PPOLocalValidationErrorCVVInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_CVV]; break;
            default:
                break;
        }
        
        if (textField) {
            [textField.layer addAnimation:[FormFieldsViewControllerAnimationManager shakeAnimation] forKey:@"transform"];
        }
    };
}

#pragma mark - PaymentFormViewControllerAnimationManager

-(PaymentFormViewControllerAnimationManager *)animationManager {
    if (_animationManager == nil) {
        _animationManager = [[PaymentFormViewControllerAnimationManager alloc] init];
        _animationManager.rootView = self.view;
        _animationManager.loadingView = self.loadingView;
        _animationManager.loadingMessageLabel = self.loadingMessageLabel;
        _animationManager.paypointLogoImageView = self.paypointLogoImageView;
    }
    return _animationManager;
}

#pragma mark - Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"OutcomeViewControllerSegueID"] && [sender isKindOfClass:[PPOOutcome class]]) {
        
        PPOOutcome *outcome = (PPOOutcome*)sender;
        OutcomeViewController *controller = segue.destinationViewController;
        controller.outcome = outcome;
        
    }
    
}

@end
