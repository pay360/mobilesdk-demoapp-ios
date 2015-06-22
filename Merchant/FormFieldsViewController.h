//
//  FormFieldsViewController.h
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "PaymentEntryFieldsManager.h"
#import "FormDetails.h"

/*
 * The UI logic for the payment form has been pushed up into this superclass, away
 * from 'PaymentFormViewController'. Mainly so that it does not clutter the payment
 * logic, which we would like to be the main focus on this demo. 
 */
@interface FormFieldsViewController : UIViewController
@property (strong, nonatomic) IBOutletCollection(FormField) NSArray *textFields;
@property (nonatomic, strong) FormDetails *form;
@end
