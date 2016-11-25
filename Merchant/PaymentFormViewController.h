//
//  SubmitFormViewController.h
//  Pay360
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "PaymentFormViewControllerAnimationManager.h"
#import "ActionButton.h"

@interface PaymentFormViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingPay360LogoImageView;
@end
