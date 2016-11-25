//
//  NetworkErrorManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkErrorManager : NSObject

+(BOOL)noNetwork:(NSError*)error;

@end
