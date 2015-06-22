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
#import "DialogueView.h"
#import "PaymentFormTableView.h"

#import <PayPointPayments/PPOPaymentManager.h>
#import <PayPointPayments/PPOPaymentBaseURLManager.h>
#import <PayPointPayments/PPOValidator.h>

#define UI_ALERT_CHECK_STATUS 1
#define UI_ALERT_TRY_AGAIN 2

@interface PaymentFormViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) PPOPaymentManager *paymentManager;
@property (nonatomic, strong) PPOPayment *currentPayment;
@property (nonatomic, strong) PaymentFormViewControllerAnimationManager *paymentFormAnimationManager;
@property (weak, nonatomic) IBOutlet PaymentFormTableView *tableView;
@end

@implementation PaymentFormViewController

-(PPOPaymentManager *)paymentManager {
    
    if (_paymentManager == nil) {
        
        /*
         *A custom environment can be used.
         */
        NSURL *baseURL;
        
        /*
         *Or a selection of PayPoint environments are available.
         */
        baseURL = [PPOPaymentBaseURLManager baseURLForEnvironment:PPOEnvironmentMerchantIntegrationTestingEnvironment];
        
        _paymentManager = [[PPOPaymentManager alloc] initWithBaseURL:baseURL];
        
    }
    return _paymentManager;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Details";
    self.payNowButton.accessibilityLabel = @"PayNowButton";
    
}

#pragma mark - Actions

-(IBAction)payNowButtonPressed:(UIButton *)button {
    
    [self.view endEditing:YES];
    
    /*
     * Nothing will happen if this button is pressed and the animation is still underway.
     * It should be impossible to press the button when the animation is in progress, because a view is placed on top of the button, which blocks gestures.
    */
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"There is no internet connection"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil, nil]
         show];
        
    } else if (self.animationManager.animationState == LOADING_ANIMATION_STATE_ENDED) {
        
        /*!
         * The 'form' model object represents the data acquired by each FormField.h
         * in our payment form. We utilise the PaypointSDK to perform inline validation.
         * This is handled in our implementation of the PaymentEntryFieldsManager protocol, which can
         * be found in our superclass.
         */
        FormDetails *formDetails = self.form;
        
        self.currentPayment.card = [PPOCard new];
        self.currentPayment.card.pan = formDetails.cardNumber;
        self.currentPayment.card.cvv = formDetails.cvv;
        self.currentPayment.card.expiry = formDetails.expiry;
        self.currentPayment.transaction.amount = formDetails.amount;
        self.currentPayment.card.cardHolderName = @"Dai Jones";
        
        NSError *invalid = [PPOValidator validatePayment:self.currentPayment];
        
        if (invalid) {
            PPOOutcome *outcome = [PPOOutcome new];
            outcome.error = invalid;
            outcome.payment = self.currentPayment;
            
            [self handleLocalValidationOutcome:outcome];
        } else {
            [self.paymentFormAnimationManager beginLoadingAnimation];
            
            __weak typeof(self) weakSelf = self;
            
            [self fetchTokenForPayment:self.currentPayment withCompletion:^(NSError *error) {
                
                if (error) {
                    [weakSelf handleErrorGeneratedByMerchantDemoApp:error];
                } else {
                    if (self.currentPayment.credentials) {
                        [self makePayment:self.currentPayment];
                    }
                }
            }];
        }

    }
        
}

-(void)fetchTokenForPayment:(PPOPayment*)payment withCompletion:(void(^)(NSError *error))completion {
    
    [MerchantServer getCredentialsWithCompletion:^(PPOCredentials *credentials, NSError *retrievalError) {
        
        NSLog(@"Got token with length: %lu chars", (unsigned long)credentials.token.length);
        
        payment.credentials = credentials;
        
        completion(retrievalError);
        
    }];
    
}

-(void)makePayment:(PPOPayment*)payment {
    
    /*
     *The PaypointSDK performs paramater validation before any network request is made.
     */
    [self.paymentManager makePayment:payment
                         withTimeOut:60.0f
                      withCompletion:[self paymentCompletionHandler]];
    
}

-(void)handleErrorGeneratedByMerchantDemoApp:(NSError*)error {
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials Acquisition"
                                                            message:@"The attempt to retrieve your Paypoint credentials failed with a network error. Please check your signal."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials Acquisition"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
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

#pragma mark - Outcome Handling

-(void)handleOutcomeGeneratedByPaymentsSDK:(PPOOutcome*)outcome {
    
    __weak typeof(self) weakSelf = self;
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if (outcome.error && [outcome.error.domain isEqualToString:PPOPaymentErrorDomain]) {
            
            [weakSelf handlePaymentOutcome:outcome];
            
        }
        else if (outcome.error && [outcome.error.domain isEqualToString:PPOLocalValidationErrorDomain]) {
            
            [weakSelf handleLocalValidationOutcome:outcome];
            
        }
        else if ([outcome.error.domain isEqualToString:NSURLErrorDomain]) {
            
            [weakSelf handleNetworkErrorOutcome:outcome];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"An unforseen error occured and we were unable to determine the outcome of your payment. Would you like to check the status of your payment now ?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:@"Check Status", nil];
            
            alert.tag = UI_ALERT_CHECK_STATUS;
            [alert show];
            
        }
        
    }];
    
}

-(void)handlePaymentOutcome:(PPOOutcome*)outcome {
    
    switch (outcome.error.code) {
        case PPOPaymentErrorMasterSessionTimedOut: {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Timeout"
                                                            message:@"Would you like to check the status of this payment ?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:@"Check Status", nil];
            
            alert.tag = UI_ALERT_CHECK_STATUS;
            [alert show];
            
        }
            break;
            
        case PPOPaymentErrorPaymentProcessing: {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment In Progress"
                                                            message:@"Would you like to check the status of this payment again ?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:@"Check Status", nil];
            
            alert.tag = UI_ALERT_CHECK_STATUS;
            [alert show];
            
        }
            break;
            
        default: {
            
            __weak typeof(self) weakSelf = self;
            [self showDialogueWithTitle:@"Error"
                               withBody:[outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                               animated:YES
                         withCompletion:^{
                             if ([PPOPaymentManager isSafeToRetryPaymentWithOutcome:outcome]) {
                                 [weakSelf askUserRetryPayment:outcome.payment];
                             }
                         }];
            
        }
            break;
    }
    
}

-(void)handleLocalValidationOutcome:(PPOOutcome*)outcome {
   
    [self showDialogueWithTitle:@"Error"
                       withBody:[outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                       animated:YES
                 withCompletion:^{
                     
                 }];
    
}

-(void)showDialogueWithTitle:(NSString*)title
                    withBody:(NSString*)body
                    animated:(BOOL)animated
              withCompletion:(void(^)(void))completion {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    DialogueView *dialogueView = [DialogueView dialogueView];
    dialogueView.translatesAutoresizingMaskIntoConstraints = NO;
    
    dialogueView.actionButtonHandler = ^ (ActionButton *button) {
        
        if (animated) {
            [UIView animateWithDuration:.3 animations:^{
                backgroundView.alpha = 0;
            } completion:^(BOOL finished) {
                [backgroundView removeFromSuperview];
                completion();
            }];
        } else {
            [backgroundView removeFromSuperview];
            completion();
        }
    };
    
    [dialogueView updateBody:body
                 updateTitle:title];
    
    if (animated) {
        backgroundView.alpha = 0;
    }
    
    [backgroundView addSubview:dialogueView];
    
    NSLayoutConstraint *constraint;
    
    constraint = [NSLayoutConstraint constraintWithItem:dialogueView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:backgroundView
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1
                                               constant:0];
    
    [backgroundView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:dialogueView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:backgroundView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0];
    
    [backgroundView addConstraint:constraint];
    
    NSArray *constraints;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(dialogueView);
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[dialogueView]-(>=20)-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    
    [backgroundView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=20)-[dialogueView]-(>=20)-|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    
    [backgroundView addConstraints:constraints];
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            backgroundView.alpha = 1;
        }];
    }
    
}

-(void)handleNetworkErrorOutcome:(PPOOutcome*)outcome {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                    message:@"Please check your signal."
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:@"Check Status", nil];
    
    alert.tag = UI_ALERT_CHECK_STATUS;
    [alert show];
    
}

-(void)askUserRetryPayment:(PPOPayment*)payment {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Failed"
                                                    message:@"Would you like to retry this payment ?"
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:@"Try Again", nil];
    
    alert.tag = UI_ALERT_TRY_AGAIN;
    [alert show];
    
}

#pragma mark - PaymentFormViewControllerAnimationManager

-(PaymentFormViewControllerAnimationManager *)animationManager {
    if (_paymentFormAnimationManager == nil) {
        _paymentFormAnimationManager = [[PaymentFormViewControllerAnimationManager alloc] init];
        _paymentFormAnimationManager.rootView = self.view;
        _paymentFormAnimationManager.loadingView = self.loadingView;
        _paymentFormAnimationManager.loadingMessageLabel = self.loadingMessageLabel;
        _paymentFormAnimationManager.loadingPaypointLogoImageView = self.loadingPaypointLogoImageView;
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

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        switch (alertView.tag) {
                
            case UI_ALERT_CHECK_STATUS:
                [self.paymentManager queryPayment:self.currentPayment
                                   withCompletion:[self paymentCompletionHandler]];
                break;
                
            case UI_ALERT_TRY_AGAIN:
                [self makePayment:self.currentPayment];
                break;
                
            default:
                break;
        }
        
    }
    
}

#pragma mark - CurrentPayment

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
        address.countryCode = @"GBR";
        
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

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case 0:
            return [self dequeeCardPanCell:tableView atIndexPath:indexPath];
            break;
            
        case 1:
            return [self dequeeCardDetailsCell:tableView atIndexPath:indexPath];
            break;
            
        case 2:
            return [self dequeePaymentCell:tableView atIndexPath:indexPath];
            break;
            
        default:
            return nil;
            break;
    }

}

-(CardPanTableViewCell*)dequeeCardPanCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    CardPanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CardPanTableViewCell cellIdentifier]];
    return cell;
}

-(CardDetailsTableViewCell*)dequeeCardDetailsCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    CardDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CardDetailsTableViewCell cellIdentifier]];
    return cell;
}

-(PaymentTableViewCell*)dequeePaymentCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    PaymentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PaymentTableViewCell cellIdentifier]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
