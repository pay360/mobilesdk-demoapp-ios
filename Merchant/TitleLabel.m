//
//  TitleLabel.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "TitleLabel.h"
#import "ColourManager.h"

@implementation TitleLabel

-(void)awakeFromNib {
    
    self.textColor = [ColourManager pay360Blue];
    self.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
    
}

@end
