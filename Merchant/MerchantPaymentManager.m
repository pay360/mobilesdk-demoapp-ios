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
    
    PPOBillingAddress *address = [[PPOBillingAddress alloc] initWithFirstLine:nil
                                                               withSecondLine:nil
                                                                withThirdLine:nil
                                                               withFourthLine:nil
                                                                     withCity:nil
                                                                   withRegion:nil
                                                                 withPostcode:nil
                                                              withCountryCode:nil];
    
    NSString *genericRef = [NSString stringWithFormat:@"mer_%.0f", [[NSDate date] timeIntervalSince1970]];
    
    PPOTransaction *transaction = [[PPOTransaction alloc] initWithCurrency:@"GBP"
                                                                withAmount:@100
                                                           withDescription:@"A description"
                                                     withMerchantReference:genericRef
                                                                isDeferred:NO];
    
    
    PPOCreditCard *card = [[PPOCreditCard alloc] initWithPan:form.cardNumber
                                        withSecurityCodeCode:form.cvv
                                                  withExpiry:form.expiry
                                          withCardholderName:@"Dai Jones"];
    
    return [[PPOPayment alloc] initWithTransaction:transaction
                                          withCard:card
                                withBillingAddress:address];
}

-(void)attemptPayment:(PPOPayment*)payment {
    
    NSError *invalid = [self.paymentManager validatePayment:payment];
    
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
    
    NSError *invalidCredentials = [self.paymentManager validateCredentials:credentials];
    
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
