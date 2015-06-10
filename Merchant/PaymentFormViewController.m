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
@property (nonatomic, strong) PaymentFormViewControllerAnimationManager *paymentFormAnimationManager;
@end

@implementation PaymentFormViewController

-(PPOPayment *)currentPayment {
    
    if (_currentPayment == nil) {
        
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
        
        PPOPayment *payment = [PPOPayment new];
        payment.transaction = transaction;
        payment.address = address;
        
        _currentPayment = payment;
    }
    
    return _currentPayment;
}

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
    
    self.amountLabel.text = [@"£" stringByAppendingString:self.currentPayment.transaction.amount.stringValue];
    self.amountLabel.textColor = [ColourManager ppBlue];
    self.amountLabel.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 40];
}

#pragma mark - Actions

-(IBAction)payNowButtonPressed:(UIBarButtonItem *)button {
    
    [self.view endEditing:YES];
    
    /*
     * Nothing will happen if this button is pressed, and the animation is still underway.
     * It should be impossible to press the button when the animation is in progress, because a view is placed on top of the button, which blocks gestures.
     * A cynical check is being done here anyway.
    */
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"There is no internet connection"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil, nil]
         show];
        
    } else if (self.animationManager.animationState == LOADING_ANIMATION_STATE_ENDED) {
        
        FormDetails *formDetails = self.form;
        
        self.currentPayment.card = [PPOCreditCard new];
        self.currentPayment.card.pan = formDetails.cardNumber;
        self.currentPayment.card.cvv = formDetails.cvv;
        self.currentPayment.card.expiry = formDetails.expiry;
        self.currentPayment.card.cardHolderName = @"Dai Jones";
        
        [self makePayment:self.currentPayment];
        
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
        PPOOutcome *outcome = [[PPOOutcome alloc] initWithError:invalid forPayment:payment];
        [self handleOutcomeGeneratedByPaymentsSDK:outcome];
        return;
    }
    
    [self.animationManager hideFeedbackBubble];
    [self.animationManager beginLoadingAnimation];
    
    __weak typeof (self) weakSelf = self;
    
    [MerchantServer getCredentialsWithCompletion:^(PPOCredentials *credentials, NSError *retrievalError) {
        
        if (retrievalError) {
            [weakSelf handleErrorGeneratedByMerchantDemoApp:retrievalError];
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

-(void(^)(PPOOutcome *outcome))paymentCompletionHandler {
    __weak typeof (self) weakSelf = self;
    return ^ (PPOOutcome *outcome) {
        if (outcome.error) {
            [weakSelf handleOutcomeGeneratedByPaymentsSDK:outcome];
        } else {
            [weakSelf.animationManager endLoadingAnimationWithCompletion:^{
                [weakSelf performSegueWithIdentifier:@"OutcomeViewControllerSegueID" sender:outcome];
            }];
        }
    };
}

#pragma mark - Error Handling

-(void)handleErrorGeneratedByMerchantDemoApp:(NSError*)error {
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            
            [self displayMessage:@"The attempt to retrieve your Paypoint credentials failed with a network error. Please check your signal."
                       withTitle:@"Credentials Acquisition"
     withDestructiveButtonAction:nil];
            
        } else {
            
            [self displayMessage:error.localizedDescription
                       withTitle:@"Credentials Acquisition"
     withDestructiveButtonAction:nil];
            
        }
        
    }];
    
}

-(void)handleOutcomeGeneratedByPaymentsSDK:(PPOOutcome*)outcome {
    
    __weak typeof(self) weakSelf = self;
    
    BOOL isPaymentError = outcome.error && [outcome.error.domain isEqualToString:PPOPaymentErrorDomain];
    BOOL isLocalValidationError = outcome.error && [outcome.error.domain isEqualToString:PPOLocalValidationErrorDomain];
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if (isPaymentError) {
            
            [weakSelf handlePaymentOutcome:outcome];
            
        } else if (isLocalValidationError) {
            
            [weakSelf.animationManager showFeedbackBubbleWithText:[outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                                                   withCompletion:[weakSelf shakeUIForValidationError:outcome.error]];
            
        } else if ([outcome.error.domain isEqualToString:NSURLErrorDomain]) {
            
            [self displayMessage:@"Please check your signal."
                       withTitle:@"Network Error"
     withDestructiveButtonAction:[self queryPaymentAction]];
            
        } else {
            
            [self displayMessage:@"An unforseen error occured and we were unable to determine the outcome of your payment. Would you like to check the status of your payment now ?"
                       withTitle:@"Error"
     withDestructiveButtonAction:nil];
            
        }
        
    }];
    
}

-(UIAlertAction*)queryPaymentAction {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Check Status"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {
                                                       [weakSelf.paymentManager queryPayment:weakSelf.currentPayment
                                                                              withCompletion:[weakSelf paymentCompletionHandler]];
                                                   }];
    
    return action;
}

-(UIAlertAction*)reattemptPayment:(PPOPayment*)payment {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Yes"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {
                                                       [weakSelf.animationManager hideFeedbackBubble];
                                                       [weakSelf.paymentManager makePayment:payment
                                                                                withTimeOut:weakSelf.form.timeout.doubleValue
                                                                             withCompletion:[weakSelf paymentCompletionHandler]];
                                                   }];
    
    return action;
}

-(void)displayMessage:(NSString*)message withTitle:(NSString*)title withDestructiveButtonAction:(UIAlertAction*)action {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    if (action) {
        [alert addAction:action];
    }
    
    action = [UIAlertAction actionWithTitle:@"Dismiss"
                                      style:UIAlertActionStyleCancel
                                    handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
    
}

-(void)handlePaymentOutcome:(PPOOutcome*)outcome {
    
    switch (outcome.error.code) {
        case PPOPaymentErrorMasterSessionTimedOut: {
            [self displayMessage:@"Would you like to check the status of this payment ?"
                       withTitle:@"Session Timeout"
     withDestructiveButtonAction:[self queryPaymentAction]];
        }
            break;
            
        case PPOPaymentErrorPaymentProcessing: {
            [self displayMessage:@"Would you like to check the status of this payment again ?"
                       withTitle:@"Payment In Progress"
     withDestructiveButtonAction:[self queryPaymentAction]];
        }
            break;
            
        default: {
            //__weak typeof(self) weakSelf = self;
            [self.animationManager showFeedbackBubbleWithText:[outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                                               withCompletion:^{
//                                                   if ([PPOPaymentManager isSafeToRetryPaymentWithOutcome:outcome]) {
//                                                       [weakSelf retryPayment:outcome.payment];
//                                                   }
                                               }];
        }
            break;
    }
    
}

-(void)retryPayment:(PPOPayment*)payment {
    
    [self displayMessage:@"Would you like to retry this payment ?" withTitle:@"Payment Failed" withDestructiveButtonAction:[self reattemptPayment:payment]];
    
}

-(void(^)(void))shakeUIForValidationError:(NSError*)error {
    
    __weak typeof(self) weakSelf = self;
    
    return ^ {
        
        PPOLocalValidationError code = error.code;
        
        FormField *textField;
        
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
    if (_paymentFormAnimationManager == nil) {
        _paymentFormAnimationManager = [[PaymentFormViewControllerAnimationManager alloc] init];
        _paymentFormAnimationManager.rootView = self.view;
        _paymentFormAnimationManager.loadingView = self.loadingView;
        _paymentFormAnimationManager.loadingMessageLabel = self.loadingMessageLabel;
        _paymentFormAnimationManager.paypointLogoImageView = self.paypointLogoImageView;
    }
    return _paymentFormAnimationManager;
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
