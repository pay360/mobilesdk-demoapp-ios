//
//  NetworkManager.h
//  Paypoint
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "Reachability.h"

#define INSTALLATION_ID @"5300302"

@class PPOCredentials;
@interface MerchantServer : NSObject

+(void)getCredentialsWithCompletion:(void(^)(PPOCredentials *credentials, NSError *retrievalError))completion;

@end
