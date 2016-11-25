//
//  FormDetails.h
//  Pay360
//
//  Created by Robert Nash on 07/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormDetails : NSObject

@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *expiry;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, strong) NSNumber *amount;

-(BOOL)isComplete;

@end
