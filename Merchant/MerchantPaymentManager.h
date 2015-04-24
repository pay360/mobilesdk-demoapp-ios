//
//  PaymentManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import <Paypoint/Paypoint.h>

#import "FormDetails.h"

@class MerchantPaymentManager;
@protocol PaymentManagerDelegate <NSObject>
-(void)paymentManager:(MerchantPaymentManager*)manager didFailWithError:(NSError*)error;
-(void)paymentManager:(MerchantPaymentManager*)manager willAttemptPayment:(PPOPayment*)payment;
-(void)paymentManager:(MerchantPaymentManager*)manager successfullWithOutcome:(PPOOutcome*)outcome;
@end

@interface MerchantPaymentManager : NSObject
@property (nonatomic, weak) id <PaymentManagerDelegate> delegate;

-(instancetype)initWithDelegate:(id<PaymentManagerDelegate>)delegate;
-(void)attemptPayment:(PPOPayment*)payment;

+(PPOPayment*)buildPaymentExampleWithDetails:(FormDetails*)form;

@end
