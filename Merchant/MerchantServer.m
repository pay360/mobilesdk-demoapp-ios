//
//  NetworkManager.m
//  Pay360
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "MerchantServer.h"
#import <Pay360Payments/PPOCredentials.h>

@implementation MerchantServer

+(void)getCredentialsWithCompletion:(void(^)(PPOCredentials *credentials, NSError *retrievalError))completion {
    
    __block NSString *token;
    __block PPOCredentials *c;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://dev.mite.pay360.com/explore/rest/mockmobilemerchant/getToken/%@", [MerchantServer installationID]]];
    
    NSLog(@"Getting token at URL: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0f];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (((NSHTTPURLResponse*)response).statusCode == 200) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            id t = [json objectForKey:@"accessToken"];
            if ([t isKindOfClass:[NSString class]]) {
                token = t;
            }
        }
        
        if (token.length > 0) {
            c = [PPOCredentials new];
            c.installationID = [MerchantServer installationID];
            c.token = token;
        }
        
        completion(c, error);
        
    }];
    
    [task resume];
    
}

+(NSString*)installationID {
    
    id value = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"InstallationID"];
    
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    return nil;
}

@end
