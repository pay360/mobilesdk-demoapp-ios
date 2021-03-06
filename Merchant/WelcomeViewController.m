//
//  WelcomeViewController.m
//  Pay360
//
//  Created by Robert Nash on 16/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ColourManager.h"
#import "PaymentFormViewController.h"

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *pay360Label;
@property (weak, nonatomic) IBOutlet UIImageView *pay360Logo;
@property (weak, nonatomic) IBOutlet UIView *logoContainer;
@property (weak, nonatomic) IBOutlet UIView *splashView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *demoButton;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demoButton.accessibilityLabel = @"DemoButton";
    self.pay360Label.textColor = [ColourManager pay360Blue];
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.splashView) {
        [UIView animateWithDuration:.3 animations:^{
            self.splashView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.splashView removeFromSuperview];
            self.splashView = nil;
        }];
    }
}

@end
