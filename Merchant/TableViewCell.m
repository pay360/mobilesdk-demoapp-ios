//
//  TableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

+(NSString *)cellIdentifier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"ID"];
}

@end
