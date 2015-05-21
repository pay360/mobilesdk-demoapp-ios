//
//  FormFieldsViewController.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "FormFieldsViewController.h"
#import "ColourManager.h"
#import "FormFieldsViewControllerAnimationManager.h"

@interface FormFieldsViewController () <CardDetailsFieldsManagerDeleate>
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (nonatomic, strong) CardDetailsFieldsManager *fieldsManager;
@property (nonatomic, strong) FormFieldsViewControllerAnimationManager *animationManager;
@end

@implementation FormFieldsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    for (UITextField *textField in self.textFields) {
        textField.textColor = [ColourManager ppBlue];
        textField.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
        textField.leftView = paddingView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    UIColor *blue = [ColourManager ppBlue];
    
    for (UILabel *titleLabel in self.titleLabels) {
        titleLabel.textColor = blue;
        titleLabel.font = [UIFont fontWithName: @"FoundryContext-Regular" size: 18];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions

-(void)backgroundTapped:(UITapGestureRecognizer*)gesture {
    [self.view endEditing:YES];
}

#pragma mark - FormDetails

-(FormDetails *)form {
    if (_form == nil) {
        _form = [FormDetails new];
    }
    return _form;
}

#pragma mark - CardDetailsFieldsManager

-(CardDetailsFieldsManager *)fieldsManager {
    if (_fieldsManager == nil) {
        _fieldsManager = [CardDetailsFieldsManager new];
        _fieldsManager.delegate = self;
        _fieldsManager.textFields = self.textFields;
    }
    return _fieldsManager;
}

-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager *)manager didUpdateCardNumber:(NSString *)cardNumber {
    self.form.cardNumber = cardNumber;
    [self.animationManager hideFeedbackBubble];
}

-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager *)manager didUpdateCVV:(NSString *)cvv {
    self.form.cvv = cvv;
    [self.animationManager hideFeedbackBubble];
}

-(void)cardDetailsFieldsManager:(CardDetailsFieldsManager *)manager didUpdateExpiryDate:(NSString *)expiryDate {
    self.form.expiry = expiryDate;
    [self.animationManager hideFeedbackBubble];
}

-(IBAction)textFieldEditingChanged:(UITextField *)sender forEvent:(UIEvent *)event {
    
    switch (sender.tag) {
        case TEXT_FIELD_TYPE_CARD_NUMBER: {
            self.form.cardNumber = sender.text;
            [self.fieldsManager reformatAsCardNumber:sender];
        }
            break;
        case TEXT_FIELD_TYPE_CVV:
            self.form.cvv = sender.text;
            break;
        default:
            break;
    }
    
    [self.animationManager hideFeedbackBubble];
    
}

-(FormFieldsViewControllerAnimationManager *)animationManager {
    if (_animationManager == nil) {
        _animationManager = [[FormFieldsViewControllerAnimationManager alloc] init];
        _animationManager.rootView = self.view;
        
    }
    return _animationManager;
}

@end
