//
//  CardDetailsTableViewCell.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "TableViewCell.h"

@class FormDetails;
@interface CardDetailsTableViewCell : TableViewCell

-(void)configureWithForm:(FormDetails*)form;

@end
