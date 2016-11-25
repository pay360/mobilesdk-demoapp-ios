//
//  FormDetails.m
//  Pay360
//
//  Created by Robert Nash on 07/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "FormDetails.h"
#import <Pay360Payments/PPOValidator.h>

@implementation FormDetails

-(NSNumber *)amount {
    if (_amount == nil) {
        _amount = @(100.0);
    }
    return _amount;
}

-(BOOL)isComplete {
    
    NSError *error = [PPOValidator validateCardPan:self.cardNumber];
    if (error) return NO;
    
    error = [PPOValidator validateCardCVV:self.cvv];
    if (error) return NO;
    
    error = [PPOValidator validateCardExpiry:self.expiry];
    if (error) return NO;
    
    return YES;
}

@end
