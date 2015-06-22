//
//  CardPanTableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "CardPanTableViewCell.h"
#import "PaymentFormField.h"

@implementation CardPanTableViewCell

- (IBAction)textFieldEditingChanged:(PaymentFormField *)sender {
    [PaymentFormField reformatAsCardNumber:sender];
}

@end
