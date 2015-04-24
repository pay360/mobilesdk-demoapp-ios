//
//  NetworkErrorManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkErrorManager : NSObject

+(BOOL)noNetwork:(NSError*)error;

@end
