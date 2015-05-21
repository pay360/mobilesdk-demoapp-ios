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
#import "MerchantPaymentManager.h"

@interface PaymentFormViewController () <PaymentManagerDelegate>
@property (nonatomic, strong) MerchantPaymentManager *paymentManager;
@end

@implementation PaymentFormViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Details";
    
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
        
        PPOPayment *payment = [MerchantPaymentManager buildPaymentExampleWithDetails:self.form];
        [self.paymentManager attemptPayment:payment];
        
    }
    
}

#pragma mark - MerchantPaymentManager

/*
 *The merchant is responsible for obtaining credentials via paypoint.
 *The 'MerchantPaymentManager' class is a dedicated class for handling credentials acquisition.
 *Credentials are acquired and retained in memory by the 'MerchantPaymentManager' class. So the merchant manager subsequently liases with the PaypointSDK, and reports back to this controller, vis it's delegate.
 */
-(MerchantPaymentManager *)paymentManager {
    if (_paymentManager == nil) {
        _paymentManager = [[MerchantPaymentManager alloc] initWithDelegate:self];
    }
    return _paymentManager;
}

#pragma mark - MerchantPaymentManager Delegate

-(void)paymentManager:(MerchantPaymentManager *)manager willAttemptPayment:(PPOPayment *)payment {
    [self.animationManager hideFeedbackBubble];
    [self.animationManager beginLoadingAnimation];
}

-(void)paymentManager:(MerchantPaymentManager *)manager successfullWithOutcome:(PPOOutcome *)outcome {
    __weak typeof(self) weakSelf = self;
    [self.animationManager endLoadingAnimationWithCompletion:^{
        [weakSelf performSegueWithIdentifier:@"OutcomeViewControllerSegueID" sender:outcome];
    }];
}

-(void)paymentManager:(MerchantPaymentManager *)manager didFailWithError:(NSError *)error {
    [self handleError:error];
}

#pragma mark - Error Handling

-(void)handleError:(NSError*)error {
    
    BOOL paypointSpecific = (error && error.domain == PPOPaypointSDKErrorDomain);
    
    __weak typeof(self) weakSelf = self;
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if (paypointSpecific) {
            
            NSString *message = [error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            
            [weakSelf.animationManager showFeedbackBubbleWithText:message
                                                   withCompletion:[weakSelf handlePaypointFeedback:error]];
            
            
            
        }
        else if ([NetworkErrorManager noNetwork:error]) {
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:@"Please check your internet or data connection and try again."
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil, nil]
             show];
            
        } else {
            
            NSString *message = [error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:(message) ?: @"Unknown error"
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil, nil]
             show];
            
        }
        
    }];
    
}

-(void(^)(void))handlePaypointFeedback:(NSError*)error {
    
    __weak typeof(self) weakSelf = self;
    
    return ^ {
        PPOErrorCode code = error.code;
        
        UITextField *textField;
        
        switch (code) {
            case PPOErrorLuhnCheckFailed: textField = weakSelf.textFields[TEXT_FIELD_TYPE_CARD_NUMBER]; break;
            case PPOErrorCardExpiryDateInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_EXPIRY]; break;
            case PPOErrorCardPanInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_CARD_NUMBER]; break;
            case PPOErrorCVVInvalid: textField = weakSelf.textFields[TEXT_FIELD_TYPE_CVV]; break;
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
