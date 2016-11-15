//
//  PaymentFormAnimationManager.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "PaymentFormViewControllerAnimationManager.h"

@interface PaymentFormViewControllerAnimationManager ()
@property (nonatomic, readwrite) LOADING_ANIMATION_STATE animationState;
@property (nonatomic) BOOL animationShouldEndAsSoonHasItHasFinishedStarting;
@property (nonatomic, copy) void(^endAnimationCompletion)(void);
@end

@implementation PaymentFormViewControllerAnimationManager

-(instancetype)init {
    self = [super init];
    if (self) {
        _animationState = LOADING_ANIMATION_STATE_ENDED;
        _loadingView.accessibilityLabel = @"LoadingView";
    }
    return self;
}

#pragma mark - Loading Animation

-(void)beginLoadingAnimation {
    
    self.animationState = LOADING_ANIMATION_STATE_STARTING;
    
    NSTimeInterval duration = 1.0;
    
    self.loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    
    self.loadingView.hidden = NO;
    
    self.loadingPaypointLogoImageView.alpha = 1;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:duration/6 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        weakSelf.loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        
        weakSelf.loadingPaypointLogoImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        
    } completion:^(BOOL finished) {
        
        weakSelf.animationState = LOADING_ANIMATION_STATE_IN_PROGRESS;
        
        weakSelf.loadingMessageLabel.hidden = NO;
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [UIView animateWithDuration:duration/2 animations:^{
            strongSelf.loadingMessageLabel.alpha = 1;
        }];
        
        [UIView animateKeyframesWithDuration:duration/2 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
            
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                strongSelf.loadingPaypointLogoImageView.transform = CGAffineTransformMakeScale(1.6, 1.6);
            }];
            
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                strongSelf.loadingPaypointLogoImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            }];
            
        } completion:nil];
        
        if (weakSelf.animationShouldEndAsSoonHasItHasFinishedStarting) {
            [weakSelf endLoadingAnimationWithCompletion:weakSelf.endAnimationCompletion];
        }
        
    }];
    
}

-(void)endLoadingAnimationWithCompletion:(void(^)(void))completion {
    
    self.endAnimationCompletion = completion;
    
    if (self.animationState == LOADING_ANIMATION_STATE_ENDED) {
        if (self.endAnimationCompletion) self.endAnimationCompletion();
        return;
    }
    
    if (self.animationState == LOADING_ANIMATION_STATE_IN_PROGRESS) {
        
        self.animationState = LOADING_ANIMATION_STATE_ENDING;
        
        [self.loadingPaypointLogoImageView.layer removeAllAnimations];
        
        CALayer *currentLayer = self.loadingPaypointLogoImageView.layer.presentationLayer;
        
        self.loadingPaypointLogoImageView.layer.transform = currentLayer.transform;
        
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            weakSelf.loadingPaypointLogoImageView.alpha = 0;
            weakSelf.loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            weakSelf.loadingMessageLabel.alpha = 0;
            weakSelf.loadingPaypointLogoImageView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
            weakSelf.loadingView.hidden = YES;
            weakSelf.loadingMessageLabel.hidden = YES;
            weakSelf.animationState = LOADING_ANIMATION_STATE_ENDED;
            weakSelf.animationShouldEndAsSoonHasItHasFinishedStarting = NO;
            
            if (completion) completion();
            
        }];
        
    } else {
        self.animationShouldEndAsSoonHasItHasFinishedStarting = YES;
    }
    
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
