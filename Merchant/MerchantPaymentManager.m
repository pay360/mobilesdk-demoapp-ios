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
        
        /*
         *A selection of environments are available. 
         *Envionrments differ by baseURL.
         *A list of baseURL's are accessible via 'PPOEnvironment' keys.
         */
        PPOEnvironment currentEnvironment = [EnvironmentManager currentEnvironment];
        
        /*
         *Alternatively, a custom URL can be passed in here.
         */
        NSURL *baseURL;
        
        baseURL = [PPOPaymentBaseURLManager baseURLForEnvironment:currentEnvironment];
        
        _paymentManager = [[PPOPaymentManager alloc] initWithBaseURL:baseURL];
        
    }
    return _paymentManager;
}

/*
 *Here is an example payment, containing some random values, for testing.
 */
+(PPOPayment*)buildPaymentExampleWithDetails:(FormDetails*)form {
    
    PPOBillingAddress *address = [PPOBillingAddress new];
    address.line1 = @"Street 1";
    address.line2 = @"Street 2";
    address.line3 = @"Street 3";
    address.line4 = @"Street 4";
    address.city = @"City";
    address.region = @"Region";
    address.postcode = @"Postcode";
    address.countryCode = @"Country Code";
    
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
    
    /*
     *Payments require fresh credentials, each time a payment request is made.
     *Optional validation can be performed here, before we begin this process.
     */
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
    
    __weak typeof (self) weakSelf = self;
    
    /*
     *The PaypointSDK performs paramater validation, to the best extent possible, before any network request is made.
     */
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
