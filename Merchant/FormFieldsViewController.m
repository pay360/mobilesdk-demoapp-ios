//
//  FormFieldsViewController.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewController.h"
#import "ColourManager.h"
#import "FormFieldsViewControllerAnimationManager.h"
#import <Paypoint/PPOValidator.h>

@interface FormFieldsViewController () <PaymentEntryFieldsManagerDelegate>
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (nonatomic, strong) FormFieldsViewControllerAnimationManager *animationManager;
@end

@implementation FormFieldsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.form = [FormDetails new];
    
    self.animationManager = [FormFieldsViewControllerAnimationManager new];
    self.animationManager.rootView = self.view;
    
    //This is the delegate of each text field.
    self.fieldsManager = [PaymentEntryFieldsManager new];
    self.fieldsManager.delegate = self;
    self.fieldsManager.textFields = self.textFields;
    
    for (UILabel *titleLabel in self.titleLabels) {
        titleLabel.textColor = [ColourManager ppBlue];
        titleLabel.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:tap];
}

-(IBAction)textFieldEditingChanged:(FormField *)sender forEvent:(UIEvent *)event {
    
    switch (sender.tag) {
            
        case TEXT_FIELD_TYPE_CARD_NUMBER: {
            self.form.cardNumber = sender.text;
            [self.fieldsManager reformatAsCardNumber:sender];
        }
            break;
            
        case TEXT_FIELD_TYPE_CVV:
            self.form.cvv = sender.text;
            break;
            
        default:
            break;
    }
    
    [self.animationManager hideFeedbackBubble];
    
}

#pragma mark - Actions

-(void)backgroundTapped:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

#pragma mark - PaymentEntryFieldsManager Delegate

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCardNumber:(NSString *)cardNumber {
    self.form.cardNumber = cardNumber;
    [self.animationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCVV:(NSString *)cvv {
    self.form.cvv = cvv;
    [self.animationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateExpiryDate:(NSString *)expiryDate {
    self.form.expiry = expiryDate;
    [self.animationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateTimeout:(NSString *)timeout {
    self.form.timeout = timeout;
    [self.animationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager textFieldDidEndEditing:(FormField *)textField {
    
    NSError *error;
    
    if ((self.textFields[TEXT_FIELD_TYPE_CARD_NUMBER] == textField)) {
        error = [PPOValidator validateCardPan:textField.text];
        if (error) {
            [self.fieldsManager highlightTextFieldBorderOfType:TEXT_FIELD_TYPE_CARD_NUMBER withAnimation:YES];
        } else {
            [self.fieldsManager resetTextFieldBorderOfType:TEXT_FIELD_TYPE_CARD_NUMBER];
        }
    } else if ((self.textFields[TEXT_FIELD_TYPE_EXPIRY] == textField)) {
        error = [PPOValidator validateCardExpiry:textField.text];
        if (error) {
            [self.fieldsManager highlightTextFieldBorderOfType:TEXT_FIELD_TYPE_EXPIRY withAnimation:YES];
        } else {
            [self.fieldsManager resetTextFieldBorderOfType:TEXT_FIELD_TYPE_EXPIRY];
        }
    } else if ((self.textFields[TEXT_FIELD_TYPE_CVV] == textField)) {
        error = [PPOValidator validateCardCVV:textField.text];
        if (error) {
            [self.fieldsManager highlightTextFieldBorderOfType:TEXT_FIELD_TYPE_CVV withAnimation:YES];
        } else {
            [self.fieldsManager resetTextFieldBorderOfType:TEXT_FIELD_TYPE_CVV];
        }
    }
    
}

@end
