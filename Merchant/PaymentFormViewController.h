//
//  SubmitFormViewController.h
//  Paypoint
//
//  Created by Robert Nash on 08/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewController.h"
#import "PaymentFormViewControllerAnimationManager.h"

@interface PaymentFormViewController : FormFieldsViewController
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loadingPaypointLogoImageView;
@property (weak, nonatomic) IBOutlet UIButton *payNowButton;
@property (weak, nonatomic) IBOutlet UIImageView *formPaypointLogo;
@end
