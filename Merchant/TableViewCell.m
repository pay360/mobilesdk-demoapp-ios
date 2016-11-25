//
//  TableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

+(NSString *)cellIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"ID"];
}

+(CGFloat)rowHeight {
    return 0.0f;
}

@end
