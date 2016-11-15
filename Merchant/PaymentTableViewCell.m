//
//  PaymentTableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "PaymentTableViewCell.h"
#import "PaymentFormField.h"
#import "FormDetails.h"
@interface PaymentTableViewCell ()
@property (weak, nonatomic) IBOutlet ActionButton *actionButton;
@property (nonatomic, weak) FormDetails *form;
@property (weak, nonatomic) IBOutlet PaymentFormField *textField;
@end

@implementation PaymentTableViewCell

-(void)awakeFromNib {
    self.actionButton.accessibilityLabel = @"PayNowButton";
    self.textField.placeholder = @"100.00";
}

-(IBAction)actionButtonPressed:(ActionButton*)button {
    [self.delegate paymentTableViewCell:self actionButtonPressed:button];
}

-(void)configureWithForm:(FormDetails *)form {
    self.form = form;
}

+(CGFloat)rowHeight {
    return 117.0f;
}

- (IBAction)textFieldEditingChanged:(PaymentFormField *)sender {
    self.form.amount = (sender.text.length) ? @(sender.text.doubleValue) : nil;
}

@end
