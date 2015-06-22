//
//  PaymentEntryFieldsManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormField.h"

typedef enum : NSUInteger {
    TEXT_FIELD_TYPE_CARD_NUMBER,
    TEXT_FIELD_TYPE_EXPIRY,
    TEXT_FIELD_TYPE_CVV,
    TEXT_FIELD_TYPE_AMOUNT
} TEXT_FIELD_TYPE;

@class PaymentEntryFieldsManager;
@protocol PaymentEntryFieldsManagerDelegate <NSObject>
-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager*)manager didUpdateCardNumber:(NSString*)cardNumber;
-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager*)manager didUpdateExpiryDate:(NSString*)expiryDate;
-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager*)manager didUpdateCVV:(NSString*)cvv;
-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager*)manager didUpdateAmount:(NSNumber*)amount;
-(void)paymentEntryFieldsManager:(PaymentEntryFieldsManager*)manager textFieldDidEndEditing:(FormField*)textField;
@end

@interface PaymentEntryFieldsManager : NSObject <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id <PaymentEntryFieldsManagerDelegate> delegate;
@property (nonatomic, weak) NSArray *textFields;

-(void)reformatAsCardNumber:(FormField *)textField;
-(void)highlightTextFieldBorderActive:(TEXT_FIELD_TYPE)type;
-(void)highlightTextFieldBorderInactive:(TEXT_FIELD_TYPE)type;
-(void)resetTextFieldBorderOfType:(TEXT_FIELD_TYPE)type;

@end
