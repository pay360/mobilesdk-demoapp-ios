//
//  NavigationViewController.m
//  Pay360
//
//  Created by Robert Nash on 15/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "NavigationViewController.h"
#import "ColourManager.h"

@implementation NavigationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
        
    UIColor *blue = [ColourManager pay360Blue];
    
    UIColor *white = [UIColor whiteColor];
    self.navigationBar.translucent = NO;
    self.navigationBar.tintColor = white;
    self.navigationBar.barTintColor = blue;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: white};
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
