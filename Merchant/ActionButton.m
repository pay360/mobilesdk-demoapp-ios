//
//  ActionButton.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "ActionButton.h"
#import "ColourManager.h"

@implementation ActionButton

-(void)awakeFromNib {
    
    self.backgroundColor = [ColourManager ppYellow];
    self.titleLabel.font = [UIFont fontWithName:@"FoundryContext-Regular" size:20.0f];
    
}

@end
