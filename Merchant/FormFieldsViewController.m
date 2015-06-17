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
#import <PayPointPayments/PPOValidator.h>

@interface FormFieldsViewController () <PaymentEntryFieldsManagerDelegate>
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (nonatomic, strong) FormFieldsViewControllerAnimationManager *formFieldsAnimationManager;
@end

@implementation FormFieldsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.form = [FormDetails new];
    
    self.formFieldsAnimationManager = [FormFieldsViewControllerAnimationManager new];
    self.formFieldsAnimationManager.rootView = self.view;
    
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
    
    [self.formFieldsAnimationManager hideFeedbackBubble];
    
}

#pragma mark - Actions

-(void)backgroundTapped:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

#pragma mark - PaymentEntryFieldsManager Delegate

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCardNumber:(NSString *)cardNumber {
    self.form.cardNumber = cardNumber;
    [self.formFieldsAnimationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCVV:(NSString *)cvv {
    self.form.cvv = cvv;
    [self.formFieldsAnimationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateExpiryDate:(NSString *)expiryDate {
    self.form.expiry = expiryDate;
    [self.formFieldsAnimationManager hideFeedbackBubble];
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager textFieldDidEndEditing:(FormField *)textField {
    
    NSError *error;
    
    TEXT_FIELD_TYPE type = 0;
    
    if ((self.textFields[TEXT_FIELD_TYPE_CARD_NUMBER] == textField)) {
        type = TEXT_FIELD_TYPE_CARD_NUMBER;
        error = [PPOValidator validateCardPan:textField.text];
    } else if ((self.textFields[TEXT_FIELD_TYPE_EXPIRY] == textField)) {
        type = TEXT_FIELD_TYPE_EXPIRY;
        error = [PPOValidator validateCardExpiry:textField.text];
    } else if ((self.textFields[TEXT_FIELD_TYPE_CVV] == textField)) {
        type = TEXT_FIELD_TYPE_CVV;
        error = [PPOValidator validateCardCVV:textField.text];
    }
    
    if (textField.text.length == 0) {
        [self.fieldsManager resetTextFieldBorderOfType:type];
    } else {
        if (error) {
            [self.fieldsManager highlightTextFieldBorderInactive:type];
        } else {
            [self.fieldsManager highlightTextFieldBorderActive:type];
        }
    }
}

@end
