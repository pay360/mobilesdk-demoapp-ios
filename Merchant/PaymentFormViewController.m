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
#import "FormDetails.h"
#import "PaymentFormField.h"
#import "TimeManager.h"

#import <PayPointPayments/PPOPaymentManager.h>
#import <PayPointPayments/PPOPaymentBaseURLManager.h>
#import <PayPointPayments/PPOValidator.h>

#define UI_ALERT_CHECK_STATUS 1
#define UI_ALERT_TRY_AGAIN 2

typedef enum : NSUInteger {
    TABLE_ROW_CARD_PAN,
    TABLE_ROW_CARD_DETAILS,
    TABLE_ROW_EMPTYNESS,
    TABLE_ROW_PAYMENT,
} TABLE_ROW;

@interface PaymentFormViewController () <UITextFieldDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PaymentTableViewCellDelegate>
@property (nonatomic, strong) PPOPaymentManager *paymentManager;
@property (nonatomic, strong) PPOPayment *currentPayment;
@property (nonatomic, strong) PaymentFormViewControllerAnimationManager *paymentFormAnimationManager;
@property (weak, nonatomic) IBOutlet PaymentFormTableView *tableView;
@property (nonatomic, strong) FormDetails *form;
@end

@implementation PaymentFormViewController

-(FormDetails *)form {
    if (_form == nil) {
        _form = [FormDetails new];
    }
    return _form;
}

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
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGSize keyboardSize = [notif.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updateTableViewInsets:keyboardSize.height];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self updateTableViewInsets:0];
}

-(void)updateTableViewInsets:(CGFloat)height {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case TABLE_ROW_CARD_PAN:
            return [self dequeeCardPanCell:tableView atIndexPath:indexPath];
            break;
            
        case TABLE_ROW_CARD_DETAILS:
            return [self dequeeCardDetailsCell:tableView atIndexPath:indexPath];
            break;
            
        case TABLE_ROW_EMPTYNESS:
            return [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            break;
            
        case TABLE_ROW_PAYMENT:
            return [self dequeePaymentCell:tableView atIndexPath:indexPath];
            break;
            
        default:
            return nil;
            break;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
            
        case TABLE_ROW_CARD_PAN:
            return 82.0f;
            break;
            
        case TABLE_ROW_CARD_DETAILS:
            return 86.0f;
            break;
            
        case TABLE_ROW_EMPTYNESS: {
            CGFloat value = tableView.frame.size.height - 82.0f - 86.0f - 117.0f;
            if (value < 0.0f) value = 0.0f;
            return value;
        }
            break;
            
        case TABLE_ROW_PAYMENT:
            return 117.0f;
            break;
            
        default:
            return 0.0f;
            break;
    }
    
}

-(CardPanTableViewCell*)dequeeCardPanCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    CardPanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CardPanTableViewCell cellIdentifier]];
    [cell configureWithForm:self.form];
    return cell;
}

-(CardDetailsTableViewCell*)dequeeCardDetailsCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    CardDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CardDetailsTableViewCell cellIdentifier]];
    [cell configureWithForm:self.form];
    return cell;
}

-(PaymentTableViewCell*)dequeePaymentCell:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
    PaymentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PaymentTableViewCell cellIdentifier]];
    cell.delegate = self;
    [cell configureWithForm:self.form];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark - PaymentTableViewCell

-(void)paymentTableViewCell:(PaymentTableViewCell *)cell actionButtonPressed:(ActionButton *)button {
    
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

#pragma mark - UITextField

-(BOOL)textFieldShouldClear:(PaymentFormField *)textField {
    textField.text = nil;
    
    switch (textField.tag) {
        case TEXT_FIELD_TYPE_CARD_NUMBER:
            self.form.cardNumber = nil;
            break;
        case TEXT_FIELD_TYPE_EXPIRY:
            self.form.expiry = nil;
            break;
        case TEXT_FIELD_TYPE_CVV:
            self.form.cvv = nil;
            break;
        case TEXT_FIELD_TYPE_AMOUNT:
            self.form.amount = nil;
            break;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(PaymentFormField *)textField {
    
    FormField *nextTextField;
    
//    switch (textField.tag) {
//        case TEXT_FIELD_TYPE_CARD_NUMBER:
//            nextTextField = self.textFields[TEXT_FIELD_TYPE_EXPIRY];
//            break;
//        case TEXT_FIELD_TYPE_EXPIRY:
//            nextTextField = self.textFields[TEXT_FIELD_TYPE_CVV];
//            break;
//        case TEXT_FIELD_TYPE_CVV:
//            nextTextField = self.textFields[TEXT_FIELD_TYPE_AMOUNT];
//            break;
//    }
    
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(PaymentFormField *)textField {
    
    NSError *error;
    
    TEXT_FIELD_TYPE type = 0;
    
    if (textField.tag == TEXT_FIELD_TYPE_CARD_NUMBER) {
        type = TEXT_FIELD_TYPE_CARD_NUMBER;
        error = [PPOValidator validateCardPan:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_EXPIRY) {
        type = TEXT_FIELD_TYPE_EXPIRY;
        error = [PPOValidator validateCardExpiry:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_CVV) {
        type = TEXT_FIELD_TYPE_CVV;
        error = [PPOValidator validateCardCVV:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_AMOUNT) {
        type = TEXT_FIELD_TYPE_AMOUNT;
        error = [PPOValidator validateAmount:@(textField.text.doubleValue)];
    }
    
    if (textField.text.length == 0) {
        [self resetTextFieldBorder:textField];
    } else {
        if (error) {
            [self highlightTextFieldBorderInactive:textField];
        } else {
            [self highlightTextFieldBorderActive:textField];
        }
    }
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSIndexPath *indexPath;
    
    switch (textField.tag) {
            
        case TEXT_FIELD_TYPE_CARD_NUMBER:
            indexPath = [NSIndexPath indexPathForRow:TABLE_ROW_CARD_PAN inSection:0];
            break;
            
        case TEXT_FIELD_TYPE_EXPIRY:
            indexPath = [NSIndexPath indexPathForRow:TABLE_ROW_CARD_DETAILS inSection:0];
            break;
            
        case TEXT_FIELD_TYPE_CVV:
            indexPath = [NSIndexPath indexPathForRow:TABLE_ROW_PAYMENT inSection:0];
            break;
            
        case TEXT_FIELD_TYPE_AMOUNT:
            indexPath = [NSIndexPath indexPathForRow:TABLE_ROW_PAYMENT inSection:0];
            break;
            
        default:
            break;
    }
    
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

-(void)highlightTextFieldBorderActive:(PaymentFormField*)textField {
    
    if (!textField.borderIsActive || textField.currentBorderColour == nil) {
        
        textField.borderIsActive = YES;
        
        textField.layer.borderWidth = 2.0f;
        
        UIColor *activeColour = [UIColor greenColor];
        UIColor *fromColour = (textField.currentBorderColour) ? : [UIColor clearColor];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        animation.fromValue = (id)fromColour.CGColor;
        animation.toValue   = (id)activeColour.CGColor;
        animation.duration = .3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [textField.layer addAnimation:animation forKey:@"Border"];
        
        textField.layer.borderColor = activeColour.CGColor;
        
        textField.currentBorderColour = activeColour;
    }
}

-(void)highlightTextFieldBorderInactive:(PaymentFormField*)textField {
    
    if (textField.borderIsActive || textField.currentBorderColour == nil) {
        
        textField.borderIsActive = NO;
        
        textField.layer.borderWidth = 2.0f;
        
        UIColor *inactiveColour = [UIColor redColor];
        UIColor *fromColour = (textField.currentBorderColour) ? : [UIColor clearColor];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        animation.fromValue = (id)fromColour.CGColor;
        animation.toValue   = (id)inactiveColour.CGColor;
        animation.duration = .3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        [textField.layer addAnimation:animation forKey:@"Border"];
        
        textField.layer.borderColor = inactiveColour.CGColor;
        
        textField.currentBorderColour = inactiveColour;
    }
    
}

-(void)resetTextFieldBorder:(PaymentFormField*)textField {
    
    if (textField.currentBorderColour) {
        
        textField.layer.borderWidth = 2.0f;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        animation.fromValue = (id)textField.currentBorderColour.CGColor;
        animation.toValue   = (id)[UIColor clearColor].CGColor;
        animation.duration = .3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        [textField.layer addAnimation:animation forKey:@"Border"];
        
        textField.layer.borderColor = [UIColor clearColor].CGColor;
        
        textField.currentBorderColour = nil;
    }
    
}

@end
