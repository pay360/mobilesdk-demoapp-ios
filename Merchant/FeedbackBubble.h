//
//  FeedbackBubble.h
//  Paypoint
//
//  Created by Robert Nash on 21/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackBubble : UIView
@property (nonatomic, strong) NSString *feedbackText;

-(instancetype)initWithFrame:(CGRect)frame withText:(NSString*)text;

@end
