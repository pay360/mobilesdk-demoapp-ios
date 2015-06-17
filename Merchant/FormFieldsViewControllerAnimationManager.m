//
//  FormFieldsViewControllerAnimationManager.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewControllerAnimationManager.h"
#import "FeedbackBubble.h"

#define SHIFT_LEFT -1.0f
#define SHIFT_RIGHT 300.0
#define REMOVE_VIEW(view) [view removeFromSuperview], view = nil

@interface FormFieldsViewControllerAnimationManager ()
@property (nonatomic, strong) FeedbackBubble *bubble;
@property (nonatomic, strong) NSLayoutConstraint *feedbackBubbleLeadingEdgeConstraint;
@end

@implementation FormFieldsViewControllerAnimationManager

#pragma mark - FeedbackBuble

-(BOOL)feedbackBubbleShowing {
    return self.feedbackBubbleLeadingEdgeConstraint.constant < 0;
}

-(void)hideFeedbackBubble {
    
    if ([self feedbackBubbleShowing]) {
        self.feedbackBubbleLeadingEdgeConstraint.constant = SHIFT_RIGHT;
        [UIView animateWithDuration:.3 animations:^{
            [self.rootView layoutIfNeeded];
        } completion:^(BOOL finished) {
            REMOVE_VIEW(self.bubble);
        }];
    }
    
}

-(void)showFeedbackBubbleWithText:(NSString*)text withCompletion:(void(^)(void))completion {
    
    if (self.bubble && [self feedbackBubbleShowing]) {
        self.bubble.feedbackText = text;
        if (completion) completion();
        return;
    }
    
    CGRect frame = CGRectMake(0, 309, 190, 163);
    self.bubble = [[FeedbackBubble alloc] initWithFrame:frame withText:text];
    self.bubble.backgroundColor = [UIColor clearColor];
    self.bubble.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rootView addSubview:self.bubble];
    [self.rootView addConstraints:[self constraintsForView:self.bubble]];
    [self.rootView layoutIfNeeded];
    
    self.feedbackBubbleLeadingEdgeConstraint.constant = SHIFT_LEFT;
    
    [UIView animateWithDuration:.3 animations:^{
        [self.rootView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
    
}

-(NSArray*)constraintsForView:(FeedbackBubble*)view {
    
    self.feedbackBubbleLeadingEdgeConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                            attribute:NSLayoutAttributeLeading
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.formPaypointLogoImageView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                           multiplier:1
                                                                             constant:SHIFT_RIGHT];
    
    NSMutableSet *collector = [NSMutableSet new];
    
    [collector addObject:self.feedbackBubbleLeadingEdgeConstraint];
    
    [collector addObject:[NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeHeight
                                                     multiplier:(231.0/199.0)
                                                       constant:0]];
    
    [collector addObject:[NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeWidth
                                                     multiplier:(199.0/231.0)
                                                       constant:0]];
    
    [collector addObject:[NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeCenterY
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.formPaypointLogoImageView
                                                      attribute:NSLayoutAttributeCenterY
                                                     multiplier:1
                                                       constant:-45.0]];
    
    [collector addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(==190)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(view)]];
    
    
    return [collector allObjects];
}

+(CAKeyframeAnimation*)shakeAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-10.0, 0.0, 0.0)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(10.0, 0.0, 0.0)]];
    animation.autoreverses = YES;
    animation.repeatCount = 2;
    animation.duration = 0.07;
    return animation;
}

@end
