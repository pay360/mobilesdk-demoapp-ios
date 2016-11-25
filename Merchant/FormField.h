//
//  FormField.h
//  Merchant
//
//  Created by Robert Nash on 10/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TEXT_FIELD_TYPE_CARD_NUMBER,
    TEXT_FIELD_TYPE_EXPIRY,
    TEXT_FIELD_TYPE_CVV,
    TEXT_FIELD_TYPE_AMOUNT
} TEXT_FIELD_TYPE;

@interface FormField : UITextField

+(void)reformatAsCardNumber:(FormField *)textField;

@end
