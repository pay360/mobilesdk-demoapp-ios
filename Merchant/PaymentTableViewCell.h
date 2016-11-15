//
//  PaymentTableViewCell.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "TableViewCell.h"
#import "ActionButton.h"

@class FormDetails;
@class PaymentTableViewCell;
@protocol PaymentTableViewCellDelegate <NSObject>
-(void)paymentTableViewCell:(PaymentTableViewCell*)cell
        actionButtonPressed:(ActionButton*)button;
@end

@interface PaymentTableViewCell : TableViewCell
@property (nonatomic, weak) id <PaymentTableViewCellDelegate> delegate;
-(void)configureWithForm:(FormDetails*)form;
@end
