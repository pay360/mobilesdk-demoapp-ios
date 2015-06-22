//
//  CardDetailsTableViewCell.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "TableViewCell.h"

@class FormDetails;
@interface CardDetailsTableViewCell : TableViewCell

-(void)configureWithForm:(FormDetails*)form;

@end
