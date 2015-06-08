//
//  CardDetailsFieldsManager.m
//  Merchant
//
//  Created by Robert Nash on 23/04/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "CardDetailsFieldsManager.h"
#import "TimeManager.h"

@interface CardDetailsFieldsManager ()
@property (nonatomic, strong) UIPickerView *expiryDatePickerView;
@property (nonatomic, strong) UIPickerView *timeoutPickerView;
@property (nonatomic, strong) NSArray *expiryDatePickerViewSelections;
@property (nonatomic, strong) NSArray *timeoutPickerViewSelections;
@property (nonatomic, strong) NSString *previousTextFieldContent;
@property (nonatomic, strong) UITextRange *previousSelection;
@property (nonatomic, strong) TimeManager *timeController;
@end

@implementation CardDetailsFieldsManager

-(void)setTextFields:(NSArray *)textFields {
    if (![_textFields isEqualToArray:textFields]) {
        _textFields = textFields;
        for (UITextField *textField in _textFields) {
            textField.delegate = self;
        }
    }
}

-(TimeManager *)timeController {
    if (_timeController == nil) {
        _timeController = [TimeManager new];
    }
    return _timeController;
}

-(NSArray *)expiryDatePickerViewSelections {
    if (_expiryDatePickerViewSelections == nil) {
        NSMutableArray *selections = [[TimeManager expiryDatesFromDate:[NSDate date]] mutableCopy];
        [selections insertObject:[NSNull null] atIndex:0];
        _expiryDatePickerViewSelections = [selections copy];
    }
    return _expiryDatePickerViewSelections;
}

-(NSArray *)timeoutPickerViewSelections {
    if (_timeoutPickerViewSelections == nil) {
        NSMutableArray *collector = [@[] mutableCopy];
        for (NSUInteger i = 60; i>0; i--) {
            [collector addObject:@(i)];
        }
        _timeoutPickerViewSelections = [collector copy];
    }
    return _timeoutPickerViewSelections;
}

-(UIPickerView *)expiryDatePickerView {
    if (_expiryDatePickerView == nil) {
        _expiryDatePickerView = [[UIPickerView alloc] init];
        _expiryDatePickerView.showsSelectionIndicator = YES;
        _expiryDatePickerView.delegate = self;
        _expiryDatePickerView.dataSource = self;
    }
    return _expiryDatePickerView;
}

-(UIPickerView *)timeoutPickerView {
    if (_timeoutPickerView == nil) {
        _timeoutPickerView = [[UIPickerView alloc] init];
        _timeoutPickerView.showsSelectionIndicator = YES;
        _timeoutPickerView.delegate = self;
        _timeoutPickerView.dataSource = self;
    }
    return _timeoutPickerView;
}

#pragma mark - UITextField Four Digit Spacing

// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformatAsCardNumber:(UITextField *)textField
{
    if (textField != self.textFields[TEXT_FIELD_TYPE_CARD_NUMBER]) {
        return;
    }
    
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > 19) {
        // If the user is trying to enter more than 19 digits, we prevent
        // their change, leaving the text field in  its previous state.
        // While 16 digits is usual, credit card numbers have a hard
        // maximum of 19 digits defined by ISO standard 7812-1 in section
        // 3.8 and elsewhere. Applying this hard maximum here rather than
        // a maximum of 16 ensures that users with unusual card numbers
        // will still be able to enter their card number even if the
        // resultant formatting is odd.
        [textField setText:_previousTextFieldContent];
        textField.selectedTextRange = _previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
}

-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    self.previousTextFieldContent = textField.text;
    self.previousSelection = textField.selectedTextRange;
    
    return YES;
}

/*
 Removes non-digits from the string, decrementing `cursorPosition` as
 appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
 and a cursor position of `8`, the cursor position will be changed to
 `7` (keeping it between the '2' and the '3' after the spaces are removed).
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/*
 Inserts spaces into the string to format it as a credit card number,
 incrementing `cursorPosition` as appropriate so that, for instance, if we
 pass in `@"111111231111"` and a cursor position of `7`, the cursor position
 will be changed to `8` (keeping it between the '2' and the '3' after the
 spaces are added).
 */
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    switch (textField.tag) {
            
        case TEXT_FIELD_TYPE_EXPIRY: {
            textField.inputView = self.expiryDatePickerView;
            NSInteger selected = [self.expiryDatePickerView selectedRowInComponent:0];
            if (selected >= 0 && selected < self.expiryDatePickerViewSelections.count) {
                NSDate *selection = self.expiryDatePickerViewSelections[selected];
                NSString *date = [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
                textField.text = date;
                [self.delegate cardDetailsFieldsManager:self didUpdateExpiryDate:date];
            }
        }
            break;
            
        case TEXT_FIELD_TYPE_TIMEOUT: {
            textField.inputView = self.timeoutPickerView;
            NSInteger selected = [self.timeoutPickerView selectedRowInComponent:0];
            if (selected >= 0 && selected < self.timeoutPickerViewSelections.count) {
                NSNumber *selection = self.timeoutPickerViewSelections[selected];
                textField.text = selection.stringValue;
                [self.delegate cardDetailsFieldsManager:self didUpdateTimeout:selection.stringValue];
            }
        }
            break;
            
        default:
            break;
    }
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    textField.text = nil;
    
    switch (textField.tag) {
        case TEXT_FIELD_TYPE_CARD_NUMBER:
            [self.delegate cardDetailsFieldsManager:self didUpdateCardNumber:nil];
            break;
        case TEXT_FIELD_TYPE_EXPIRY:
            [self.delegate cardDetailsFieldsManager:self didUpdateExpiryDate:nil];
            break;
        case TEXT_FIELD_TYPE_CVV:
            [self.delegate cardDetailsFieldsManager:self didUpdateCVV:nil];
            break;
        case TEXT_FIELD_TYPE_TIMEOUT:
            [self.delegate cardDetailsFieldsManager:self didUpdateTimeout:nil];
            break;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    UITextField *nextTextField;
    
    switch (textField.tag) {
        case TEXT_FIELD_TYPE_CARD_NUMBER:
            nextTextField = self.textFields[TEXT_FIELD_TYPE_EXPIRY];
            break;
        case TEXT_FIELD_TYPE_EXPIRY:
            nextTextField = self.textFields[TEXT_FIELD_TYPE_CVV];
            break;
        case TEXT_FIELD_TYPE_CVV:
            nextTextField = self.textFields[TEXT_FIELD_TYPE_TIMEOUT];
            break;
        case TEXT_FIELD_TYPE_TIMEOUT:
            [textField resignFirstResponder];
            break;
    }
    
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIPickerView Datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == self.expiryDatePickerView) {
        return self.expiryDatePickerViewSelections.count;
    } else {
        return self.timeoutPickerViewSelections.count;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    id selection;
    
    if (pickerView == self.expiryDatePickerView) {
        
        selection = self.expiryDatePickerViewSelections[row];
        
        if ([selection isKindOfClass:[NSDate class]]) {
            return [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
        } else if ([selection isKindOfClass:[NSNull class]]) {
            return @"--/--";
        }
        
    } else {
        
        selection = self.timeoutPickerViewSelections[row];
        
        if ([selection isKindOfClass:[NSNumber class]]) {
            return ((NSNumber*)selection).stringValue;
        }
    }
    
    return nil;
}

#pragma mark - UIPickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UITextField *textField;
    
    id selection;
    
    if (pickerView == self.expiryDatePickerView) {
        textField = self.textFields[TEXT_FIELD_TYPE_EXPIRY];
        selection = self.expiryDatePickerViewSelections[row];
        if ([selection isKindOfClass:[NSNull class]]) {
            textField.text = nil;
            [self.delegate cardDetailsFieldsManager:self didUpdateExpiryDate:nil];
        } else if ([selection isKindOfClass:[NSDate class]]) {
            NSString *dateString = [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
            textField.text = dateString;
            [self.delegate cardDetailsFieldsManager:self didUpdateExpiryDate:dateString];
        }
    } else {
        textField = self.textFields[TEXT_FIELD_TYPE_TIMEOUT];
        selection = self.timeoutPickerViewSelections[row];
        if ([selection isKindOfClass:[NSNumber class]]) {
            textField.text = ((NSNumber*)selection).stringValue;
            [self.delegate cardDetailsFieldsManager:self didUpdateTimeout:((NSNumber*)selection).stringValue];
        }
    }
}

@end
