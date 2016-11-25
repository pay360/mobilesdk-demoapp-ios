//
//  TimeManager.h
//  Pay360
//
//  Created by Robert Nash on 07/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeManager : NSObject
@property (nonatomic, strong) NSDateFormatter *cardExpiryDateFormatter;

+(NSArray*)expiryDatesFromDate:(NSDate*)now;
+(NSLocale*)locale;

@end
