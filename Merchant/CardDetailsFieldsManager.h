//
//  CardDetailsFieldsManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TEXT_FIELD_TYPE_CARD_NUMBER,
    TEXT_FIELD_TYPE_EXPIRY,
    TEXT_FIELD_TYPE_CVV,
    TEXT_FIELD_TYPE_TIMEOUT
} TEXT_FIELD_TYPE;

@class CardDetailsFieldsManager;
@protocol CardDetailsFieldsManagerDeleate <NSObject>
-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager*)manager didUpdateCardNumber:(NSString*)cardNumber;
-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager*)manager didUpdateExpiryDate:(NSString*)expiryDate;
-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager*)manager didUpdateCVV:(NSString*)cvv;
-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager*)manager didUpdateTimeout:(NSString*)timeout;
@end

@interface CardDetailsFieldsManager : NSObject <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, weak) id <CardDetailsFieldsManagerDeleate> delegate;
@property (nonatomic, weak) NSArray *textFields;

-(void)reformatAsCardNumber:(UITextField *)textField;

@end
