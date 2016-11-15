//
//  SubmitFormViewController.m
//  Pay360
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
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

#import <Pay360Payments/PPOPaymentManager.h>
#import <Pay360Payments/PPOPaymentBaseURLManager.h>
#import <Pay360Payments/PPOValidator.h>

#define UI_ALERT_CHECK_STATUS -1

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
@property (nonatomic, weak) UITextField *fieldFirstResponder;
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
        NSURL *baseURL = [PPOPaymentBaseURLManager baseURLForEnvironment:PPOEnvironmentMerchantIntegrationTestingEnvironment];
        _paymentManager = [[PPOPaymentManager alloc] initWithBaseURL:baseURL];
    }
    return _paymentManager;
}

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Details";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                      }];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification *)notif {
    CGRect beginFrame = [notif.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [self updateTableViewInsets:CGRectGetHeight(beginFrame)];
}

-(void)keyboardDidShow:(NSNotification *)notif {
    [self performSelector:@selector(scrollToIndexPath:)
               withObject:[self indexPathForTextField:self.fieldFirstResponder]
               afterDelay:.1];
}

-(NSIndexPath *)indexPathForTextField:(UITextField*)textField {
    
    switch (textField.tag) {
            
        case TEXT_FIELD_TYPE_CARD_NUMBER:
            return [NSIndexPath indexPathForRow:TABLE_ROW_CARD_PAN inSection:0];
            break;
        case TEXT_FIELD_TYPE_EXPIRY:
            return [NSIndexPath indexPathForRow:TABLE_ROW_CARD_DETAILS inSection:0];
            break;
        case TEXT_FIELD_TYPE_CVV:
            return [NSIndexPath indexPathForRow:TABLE_ROW_CARD_DETAILS inSection:0];
            break;
        case TEXT_FIELD_TYPE_AMOUNT:
            return [NSIndexPath indexPathForRow:TABLE_ROW_PAYMENT inSection:0];
            break;
            
        default:
            return nil;
            break;
    }
}

-(void)keyboardWillHide:(NSNotification *)notif {
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
        _paymentFormAnimationManager.loadingPay360LogoImageView = self.loadingPay360LogoImageView;
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
        
        if (alertView.tag == UI_ALERT_CHECK_STATUS) {
            [self.paymentManager queryPayment:self.currentPayment
                               withCompletion:[self paymentCompletionHandler]];
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
            return [CardPanTableViewCell rowHeight];
            break;
            
        case TABLE_ROW_CARD_DETAILS:
            return [CardDetailsTableViewCell rowHeight];
            break;
            
        case TABLE_ROW_EMPTYNESS: {
            CGFloat value = CGRectGetHeight(tableView.frame) -
                            [CardPanTableViewCell rowHeight] -
                            [CardDetailsTableViewCell rowHeight] -
                            [PaymentTableViewCell rowHeight];
            return MAX(0, value);
        }
            break;
            
        case TABLE_ROW_PAYMENT:
            return [PaymentTableViewCell rowHeight];
            break;
            
        default:
            return 0.0f;
            break;
    }
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TABLE_ROW_EMPTYNESS inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
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

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"There is no internet connection"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil, nil]
         show];
        
    } else if (self.animationManager.animationState == LOADING_ANIMATION_STATE_ENDED) {
        
        FormDetails *formDetails = self.form;
        
        self.currentPayment.card = [PPOCard new];
        self.currentPayment.card.pan = formDetails.cardNumber;
        self.currentPayment.card.cvv = formDetails.cvv;
        self.currentPayment.card.expiry = formDetails.expiry;
        self.currentPayment.transaction.amount = formDetails.amount;
        self.currentPayment.card.cardHolderName = @"Dai Jones";
        
        NSError *invalid = [PPOValidator validatePayment:self.currentPayment];
        
        if (invalid) {
            [self handleLocalValidationError:invalid];
        } else {
            [self.paymentFormAnimationManager beginLoadingAnimation];
            
            __weak typeof(self) weakSelf = self;
            
            [MerchantServer getCredentialsWithCompletion:^(PPOCredentials *credentials, NSError *retrievalError) {
                
                NSLog(@"Got token with length: %lu chars", (unsigned long)credentials.token.length);
                
                weakSelf.currentPayment.credentials = credentials;
                
                if (retrievalError || !credentials) {
                    [weakSelf handleErrorGeneratedByMerchantDemoApp:retrievalError];
                } else {
                    if (weakSelf.currentPayment.credentials) {
                        [weakSelf makePayment:weakSelf.currentPayment];
                    }
                }
                
            }];

        }
        
    }
    
}

-(void)handleErrorGeneratedByMerchantDemoApp:(NSError*)error {
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials"
                                                            message:@"The attempt to retrieve your credentials failed with a network error. Please check your signal."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
            
        } else if (!error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials"
                                                            message:@"There has been a problem retrieving your credentials and it wasn't a networking issue..."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credentials"
                                                            message:error.localizedDescription
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }];
    
}

-(void)makePayment:(PPOPayment*)payment {
    [self.paymentManager makePayment:self.currentPayment
                         withTimeOut:60.0f
                      withCompletion:[self paymentCompletionHandler]];
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

#pragma mark - Outcome Error Handling

-(void)handleOutcomeGeneratedByPaymentsSDK:(PPOOutcome*)outcome {
    
    __weak typeof(self) weakSelf = self;
    
    [self.animationManager endLoadingAnimationWithCompletion:^{
        
        if (outcome.error && [outcome.error.domain isEqualToString:PPOPaymentErrorDomain]) {
            
            [weakSelf handlePaymentOutcome:outcome];
            
        }
        else if (outcome.error && [outcome.error.domain isEqualToString:PPOLocalValidationErrorDomain]) {
            
            [weakSelf handleLocalValidationError:outcome.error];
            
        }
        else if ([outcome.error.domain isEqualToString:NSURLErrorDomain]) {
            
            [weakSelf handleNetworkError:outcome.error];
            
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
            
        case PPOPaymentValidationError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Invalid"
                                                            message:[outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
        }
            break;
            
        default: {
            
            NSString *message;
            
            message = [outcome.error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            
            NSMutableString *mutableString = [@"" mutableCopy];
            [mutableString appendString:message];
            
            if ([PPOPaymentManager isSafeToRetryPaymentWithOutcome:outcome]) {
                [mutableString appendString:@"\nNo money has been taken from your account."];
            } else {
                [mutableString appendString:@"\nPlease contact the merchant to find out if the payment completed."];
            }
            
            message = [mutableString copy];
            
            [self showDialogueWithTitle:@"Error"
                               withBody:message
                               animated:YES
                         withCompletion:^{
                         }];
            
        }
            break;
    }
    
}

-(void)handleLocalValidationError:(NSError*)error {
    
    [self showDialogueWithTitle:@"Error"
                       withBody:[error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey]
                       animated:YES
                 withCompletion:^{
                     
                 }];
    
}

-(void)showDialogueWithTitle:(NSString*)title
                    withBody:(NSString*)body
                    animated:(BOOL)animated
              withCompletion:(void(^)(void))completion {
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
    [[[UIApplication sharedApplication] keyWindow] addSubview:backgroundView];
    
    NSArray *constraints;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(backgroundView);
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundView]-0-|" options:0 metrics:nil views:views];
    
    [[[UIApplication sharedApplication] keyWindow] addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backgroundView]-0-|" options:0 metrics:nil views:views];
    
    [[[UIApplication sharedApplication] keyWindow] addConstraints:constraints];
    
    DialogueView *dialogueView = [DialogueView dialogueView];
    
    dialogueView.actionButtonHandler = ^ (ActionButton *button) {
        
        if (animated) {
            [UIView animateWithDuration:.3 animations:^{
                backgroundView.alpha = 0;
            } completion:^(BOOL finished) {
                [backgroundView removeFromSuperview];
                if (completion) completion();
            }];
        } else {
            [backgroundView removeFromSuperview];
            if (completion) completion();
        }
        
    };
    
    [dialogueView updateBody:body
                 updateTitle:title];
    
    if (animated) {
        backgroundView.alpha = 0;
    
    }
    
    dialogueView.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    views = NSDictionaryOfVariableBindings(dialogueView);
    
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

-(void)handleNetworkError:(NSError*)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                    message:@"Please check your signal."
                                                   delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:@"Check Status", nil];
    
    alert.tag = UI_ALERT_CHECK_STATUS;
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *value;
    
    if (string.length == 0) {
        return YES;
    }
    
    if (textField.tag == TEXT_FIELD_TYPE_CARD_NUMBER) {
        value = [self.form.cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        return !(value && value.length >= 19);
    }
    
    if (textField.tag == TEXT_FIELD_TYPE_CVV) {
        value = [self.form.cvv stringByReplacingOccurrencesOfString:@" " withString:@""];
        return !(value && value.length >= 4);
    }
    
    if (textField.tag == TEXT_FIELD_TYPE_AMOUNT) {
        value = self.form.amount.stringValue;
        NSArray *components = [value componentsSeparatedByString:@"."];
        if (components.count > 1) {
            NSString *last = components.lastObject;
            return !(last.length >= 2);
        }
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.fieldFirstResponder = textField;
}

-(void)textFieldDidEndEditing:(PaymentFormField *)textField {
    
    self.fieldFirstResponder = nil;
    
    NSError *error;
    
    if (textField.tag == TEXT_FIELD_TYPE_CARD_NUMBER) {
        error = [PPOValidator validateCardPan:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_EXPIRY) {
        error = [PPOValidator validateCardExpiry:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_CVV) {
        error = [PPOValidator validateCardCVV:textField.text];
    } else if (textField.tag == TEXT_FIELD_TYPE_AMOUNT) {
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

-(void)scrollToIndexPath:(NSIndexPath*)indexPath {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
