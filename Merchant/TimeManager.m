//
//  TimeManager.m
//  Pay360
//
//  Created by Robert Nash on 07/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "TimeManager.h"

@implementation TimeManager

-(NSDateFormatter *)cardExpiryDateFormatter {
    if (_cardExpiryDateFormatter == nil) {
        _cardExpiryDateFormatter = [NSDateFormatter new];
        [_cardExpiryDateFormatter setDateFormat:@"MM YY"];
        [_cardExpiryDateFormatter setLocale:[TimeManager locale]];
    }
    return _cardExpiryDateFormatter;
}

+(NSArray*)expiryDatesFromDate:(NSDate*)now {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:5];
    NSDate *endDate = [gregorian dateByAddingComponents:offsetComponents toDate:now options:NSCalendarWrapComponents];
    
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:now  toDate:endDate  options:NSCalendarWrapComponents];
    NSUInteger months = [comps month];
    
    NSMutableArray *dateCollector = [NSMutableArray new];
    
    NSDate *date;
    NSCalendar *currentCalendar;
    NSDateComponents *dateComponents;
    
    currentCalendar = [NSCalendar currentCalendar];
    dateComponents = [currentCalendar components:
                      NSCalendarUnitHour |
                      NSCalendarUnitMinute |
                      NSCalendarUnitYear |
                      NSCalendarUnitMonth |
                      NSCalendarUnitDay
                                        fromDate:now];
    
    date = [currentCalendar dateFromComponents:dateComponents];
    if (date) [dateCollector addObject:date];
    
    for (NSInteger i = 1; i < months; i++) {
        currentCalendar = [NSCalendar currentCalendar];
        dateComponents = [currentCalendar components:
                          NSCalendarUnitHour |
                          NSCalendarUnitMinute |
                          NSCalendarUnitYear |
                          NSCalendarUnitMonth |
                          NSCalendarUnitDay
                                            fromDate:now];
        
        dateComponents.month += (i);
        date = [currentCalendar dateFromComponents:dateComponents];
        if (date) [dateCollector addObject:date];
    }
    
    return [dateCollector copy];
}

+(NSLocale *)locale {
    return [NSLocale localeWithLocaleIdentifier:@"en_GB"];
}

@end
