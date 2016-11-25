//
//  ColourManager.m
//  Pay360
//
//  Created by Robert Nash on 15/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "ColourManager.h"

@implementation ColourManager

+(UIColor*)pay360Yellow {
    return [UIColor colorWithRed:240/255.0f green:171/255.0f blue:0/255.0f alpha:1];
}

+(UIColor*)pay360Blue {
    return [UIColor colorWithRed:4/255.0f green:71/255.0f blue:111/255.0f alpha:1];
}

+(UIColor*)pay360LightGrey:(CGFloat)alpha {
    return [UIColor colorWithRed:165/255.0f green:157/255.0f blue:149/255.0f alpha:alpha];
}

@end
