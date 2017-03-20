//
//  PaymentFormField.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "PaymentFormField.h"
#import "ColourManager.h"

@implementation PaymentFormField

-(void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [ColourManager pay360Yellow];
    self.textColor = [ColourManager pay360Blue];
    self.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    
}

@end
