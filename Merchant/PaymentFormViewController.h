//
//  SubmitFormViewController.h
//  Paypoint
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "PaymentFormViewControllerAnimationManager.h"
#import "ActionButton.h"

@interface PaymentFormViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingPaypointLogoImageView;
@end
