//
//  FormDetails.m
//  Paypoint
//
//  Created by Robert Nash on 07/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormDetails.h"
#import <PayPointPayments/PPOValidator.h>
#import "NSString+strip.h"

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
