//
//  PaymentTableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "PaymentTableViewCell.h"

@interface PaymentTableViewCell ()
@property (weak, nonatomic) IBOutlet ActionButton *actionButton;
@end

@implementation PaymentTableViewCell

-(void)awakeFromNib {
    self.actionButton.accessibilityLabel = @"PayNowButton";
}

-(IBAction)actionButtonPressed:(ActionButton*)button {
    [self.delegate paymentTableViewCell:self actionButtonPressed:button];
}

@end
