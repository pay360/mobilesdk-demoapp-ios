//
//  ActionButton.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "ActionButton.h"
#import "ColourManager.h"

@implementation ActionButton

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [ColourManager pay360Yellow];
    self.titleLabel.font = [UIFont fontWithName:@"FoundryContext-Regular" size:20.0f];
}

@end
