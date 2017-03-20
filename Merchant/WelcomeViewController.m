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
@property (weak, nonatomic) IBOutlet UIView *splashView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *demoButton;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"pay360_logo_version_1"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    NSDictionary *views = [NSDictionary dictionaryWithObject:imageView forKey:@"view"];
    NSArray *constraints = [self makeConstraintsWithViews:views];
    [self.view addConstraints:constraints];
    self.demoButton.accessibilityLabel = @"DemoButton";
    [self.view bringSubviewToFront:self.splashView];
}

-(NSArray <NSLayoutConstraint *> *)makeConstraintsWithViews:(NSDictionary *)views {
    UIImageView *imageView = views[@"view"];
    [imageView sizeToFit];
    NSMutableArray *collection = [@[] mutableCopy];
    NSArray *constraints;
    NSLayoutConstraint *constraint;
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[view]-(>=20)-|" options:0 metrics:nil views:views];
    [collection addObjectsFromArray:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views];
    [collection addObjectsFromArray:constraints];
    constraint = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imageView.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    constraint.priority = UILayoutPriorityDefaultLow;
    [collection addObject:constraint];
    return collection;
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
