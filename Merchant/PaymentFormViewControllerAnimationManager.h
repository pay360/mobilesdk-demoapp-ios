//
//  PaymentFormAnimationManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewControllerAnimationManager.h"

typedef enum : NSUInteger {
    LOADING_ANIMATION_STATE_STARTING,
    LOADING_ANIMATION_STATE_IN_PROGRESS,
    LOADING_ANIMATION_STATE_ENDING,
    LOADING_ANIMATION_STATE_ENDED
} LOADING_ANIMATION_STATE;

@interface PaymentFormViewControllerAnimationManager : FormFieldsViewControllerAnimationManager

@property (nonatomic, readonly) LOADING_ANIMATION_STATE animationState;
@property (nonatomic, weak) UIView *loadingView;
@property (nonatomic, weak) UILabel *loadingMessageLabel;

-(instancetype)init;

-(void)beginLoadingAnimation;
-(void)endLoadingAnimationWithCompletion:(void(^)(void))completion;

@end
