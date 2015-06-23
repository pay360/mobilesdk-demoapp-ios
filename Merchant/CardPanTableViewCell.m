//
//  CardPanTableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "CardPanTableViewCell.h"
#import "PaymentFormField.h"
#import "FormDetails.h"

@interface CardPanTableViewCell ()
@property (nonatomic, weak) FormDetails *form;
@end

@implementation CardPanTableViewCell

- (IBAction)textFieldEditingChanged:(PaymentFormField *)sender {
    [PaymentFormField reformatAsCardNumber:sender];
    self.form.cardNumber = sender.text;
}

+(CGFloat)rowHeight {
    return 83.0f;
}

-(void)configureWithForm:(FormDetails *)form {
    self.form = form;
}

@end
