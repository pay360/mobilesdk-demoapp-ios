//
//  UITestCase.m
//  Merchant
//
//  Created by Robert Nash on 22/05/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "UITestCase.h"
#import "KIFUITestActor+PaymentForm.h"

@implementation UITestCase

-(void)beforeEach {
    [tester navigateToPaymentForm];
}

-(void)testSimplePayment {
    [tester enterText:@"9900 0000 0000 5159" intoViewWithAccessibilityLabel:@"CardPanTextField"];
    [tester tapViewWithAccessibilityLabel:@"CardExpiryTextField"];
    [tester waitForTimeInterval:2];
    [tester selectPickerViewRowWithTitle:@"01 17"];
    [tester enterText:@"123" intoViewWithAccessibilityLabel:@"CardCVVTextField"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"PayNowButton"];
    [tester waitForAnimationsToFinish];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"LoadingView"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"CardPanTextField"];
}

-(void)testFastAuthenticationPayment {
    [tester enterText:@"9902 0000 0000 5140" intoViewWithAccessibilityLabel:@"CardPanTextField"];
    [tester tapViewWithAccessibilityLabel:@"CardExpiryTextField"];
    [tester waitForTimeInterval:2];
    [tester selectPickerViewRowWithTitle:@"01 17"];
    [tester enterText:@"123" intoViewWithAccessibilityLabel:@"CardCVVTextField"];
    [tester waitForTimeInterval:1];
    [tester tapViewWithAccessibilityLabel:@"PayNowButton"];
    [tester waitForAnimationsToFinish];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"LoadingView"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"CardPanTextField"];
}

-(void)afterEach {
    [tester navigateHomeFromReceipt];
}

@end
