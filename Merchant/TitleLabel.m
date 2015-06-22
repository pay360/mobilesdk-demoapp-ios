//
//  TitleLabel.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "TitleLabel.h"
#import "ColourManager.h"

@implementation TitleLabel

-(void)awakeFromNib {
    
    self.textColor = [ColourManager ppBlue];
    self.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
    
}

@end
