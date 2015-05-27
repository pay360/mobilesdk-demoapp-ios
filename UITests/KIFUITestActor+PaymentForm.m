//
//  KIFUITestActor+PaymentForm.m
//  Merchant
//
//  Created by Robert Nash on 22/05/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "KIFUITestActor+PaymentForm.h"

@implementation KIFUITestActor (PaymentForm)

-(void)navigateToPaymentForm {
    [self tapViewWithAccessibilityLabel:@"DemoButton" traits:UIAccessibilityTraitButton];
    [self waitForAbsenceOfViewWithAccessibilityLabel:@"DemoButton"];
}

-(void)navigateHomeFromPaymentForm {
    [self tapViewWithAccessibilityLabel:@"Back" traits:UIAccessibilityTraitButton];
    [self waitForAbsenceOfViewWithAccessibilityLabel:@"CardPanTextField"];
}

-(void)navigateHomeFromReceipt {
    [self tapViewWithAccessibilityLabel:@"RestartButton" traits:UIAccessibilityTraitButton];
    [self waitForAbsenceOfViewWithAccessibilityLabel:@"TickLogo"];
}

@end
