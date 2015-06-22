//
//  PaymentFormField.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormField.h"

@interface PaymentFormField : FormField
@property (nonatomic) BOOL borderIsActive;
@property (nonatomic, strong) UIColor *currentBorderColour;
@end
