//
//  FormFieldsViewController.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "CardDetailsFieldsManager.h"
#import "FormDetails.h"

@interface FormFieldsViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, strong) FormDetails *form;

@end
