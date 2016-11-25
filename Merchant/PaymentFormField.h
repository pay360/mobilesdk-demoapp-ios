//
//  PaymentFormField.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "FormField.h"

@interface PaymentFormField : FormField
@property (nonatomic) BOOL borderIsActive;
@property (nonatomic, strong) UIColor *currentBorderColour;
@end
