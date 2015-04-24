//
//  FeedbackBubble.m
//  Paypoint
//
//  Created by Robert Nash on 21/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FeedbackBubble.h"
#import "StyleKit.h"

@implementation FeedbackBubble

-(instancetype)initWithFrame:(CGRect)frame withText:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        _feedbackText = text;
    }
    return self;
}

-(void)setFeedbackText:(NSString *)feedbackText {
    if (![_feedbackText isEqualToString:feedbackText]) {
        _feedbackText = feedbackText;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [StyleKit drawFeedbackBubbleWithFrame:self.bounds message:self.feedbackText];
}

@end
