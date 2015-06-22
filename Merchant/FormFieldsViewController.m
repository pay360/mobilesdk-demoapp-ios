//
//  FormFieldsViewController.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewController.h"
#import "ColourManager.h"

#import <PayPointPayments/PPOValidator.h>

@interface FormFieldsViewController () <PaymentEntryFieldsManagerDelegate>
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (nonatomic, strong) PaymentEntryFieldsManager *fieldsManager;
@end

@implementation FormFieldsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.form = [FormDetails new];
    
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
            
        case TEXT_FIELD_TYPE_AMOUNT:
            self.form.amount = @(sender.text.doubleValue);
            break;
            
        default:
            break;
    }
    
#warning hide dialogue
    
}

#pragma mark - Actions

-(void)backgroundTapped:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

#pragma mark - PaymentEntryFieldsManager Delegate

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCardNumber:(NSString *)cardNumber {
    self.form.cardNumber = cardNumber;
#warning hide dialogue
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateCVV:(NSString *)cvv {
    self.form.cvv = cvv;
#warning hide dialogue
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateExpiryDate:(NSString *)expiryDate {
    self.form.expiry = expiryDate;
#warning hide dialogue
}

-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager *)manager didUpdateAmount:(NSNumber *)amount {
    self.form.amount = amount;
#warning hide dialogue
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
