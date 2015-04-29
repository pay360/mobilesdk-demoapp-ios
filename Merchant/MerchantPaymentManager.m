//
//  PaymentManager.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "MerchantPaymentManager.h"
#import "EnvironmentManager.h"
#import "MerchantServer.h"

@interface MerchantPaymentManager ()
@property (nonatomic, strong) PPOPaymentManager *paymentManager;
@end

@implementation MerchantPaymentManager

-(instancetype)initWithDelegate:(id<PaymentManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

-(PPOPaymentManager *)paymentManager {
    if (_paymentManager == nil) {
        PPOEnvironment currentEnvironment = [EnvironmentManager currentEnvironment];
        
        NSURL *baseURL = [PPOPaymentBaseURLManager baseURLForEnvironment:currentEnvironment];
        
        _paymentManager = [[PPOPaymentManager alloc] initWithBaseURL:baseURL];
        
    }
    return _paymentManager;
}

+(PPOPayment*)buildPaymentExampleWithDetails:(FormDetails*)form {
    
    PPOBillingAddress *address = [PPOBillingAddress new];
    address.line1 = nil;
    address.line2 = nil;
    address.line3 = nil;
    address.line4 = nil;
    address.city = nil;
    address.region = nil;
    address.postcode = nil;
    address.countryCode = nil;
    
    PPOTransaction *transaction = [PPOTransaction new];
    transaction.currency = @"GBP";
    transaction.amount = @100;
    transaction.transactionDescription = @"A desc";
    transaction.merchantRef = [NSString stringWithFormat:@"mer_%.0f", [[NSDate date] timeIntervalSince1970]];
    transaction.isDeferred = @NO;
    
    PPOCreditCard *card = [PPOCreditCard new];
    card.pan = form.cardNumber;
    card.cvv = form.cvv;
    card.expiry = form.expiry;
    card.cardHolderName = @"Dai Jones";
    
    PPOPayment *payment = [PPOPayment new];
    payment.transaction = transaction;
    payment.card = card;
    payment.address = address;
    
    return payment;
}

-(void)attemptPayment:(PPOPayment*)payment {
    
    NSError *invalid = [PPOPaymentValidator validatePayment:payment];
    
    if (invalid) {
        [self.delegate paymentManager:self didFailWithError:invalid];
        return;
    }
    
    [self.delegate paymentManager:self willAttemptPayment:payment];
    
    __weak typeof (self) weakSelf = self;
    
    [MerchantServer getCredentialsWithCompletion:^(PPOCredentials *credentials, NSError *retrievalError) {
        
        if (retrievalError) {
            [weakSelf.delegate paymentManager:weakSelf didFailWithError:retrievalError];
            return;
        }
        
        [weakSelf attemptPayment:payment withCredentials:credentials];
        
    }];
    
}

-(void)attemptPayment:(PPOPayment*)payment withCredentials:(PPOCredentials*)credentials {
    
    NSError *invalidCredentials = [PPOPaymentValidator validateCredentials:credentials];
    
    if (invalidCredentials) {
        [self.delegate paymentManager:self didFailWithError:invalidCredentials];
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    
    [self.paymentManager makePayment:payment
                     withCredentials:credentials
                         withTimeOut:60.0f
                      withCompletion:^(PPOOutcome *outcome, NSError *paymentFailure) {
                          
                          if (paymentFailure) {
                              [weakSelf.delegate paymentManager:weakSelf didFailWithError:paymentFailure];
                          } else {
                              [weakSelf.delegate paymentManager:weakSelf successfullWithOutcome:outcome];
                          }
                          
                      }];
}

@end
