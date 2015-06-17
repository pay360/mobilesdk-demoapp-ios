//
//  FormFieldsViewControllerAnimationManager.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormFieldsViewControllerAnimationManager : NSObject
@property (nonatomic, weak) UIImageView *formPaypointLogoImageView;
@property (nonatomic, weak) UIImageView *loadingPaypointLogoImageView;
@property (nonatomic, weak) UIView *rootView;

-(void)showFeedbackBubbleWithText:(NSString*)text withCompletion:(void(^)(void))completion;
-(void)hideFeedbackBubble;

+(CAKeyframeAnimation*)shakeAnimation;

@end
