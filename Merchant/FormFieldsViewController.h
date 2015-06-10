//
//  FormFieldsViewController.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "PaymentEntryFieldsManager.h"
#import "FormDetails.h"

@interface FormFieldsViewController : UIViewController

// The UI logic for the payment form has been pushed up into this superclass, away from 'PaymentFormViewController'. Mainly so that it does not clutter the payment logic. Hopefully this makes the code easier read.

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, strong) FormDetails *form;

@end
