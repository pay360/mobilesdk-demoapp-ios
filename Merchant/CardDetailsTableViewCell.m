//
//  CardDetailsTableViewCell.m
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2015 Paypoint. All rights reserved.
//

#import "CardDetailsTableViewCell.h"
#import "FormField.h"
#import "TimeManager.h"

@interface CardDetailsTableViewCell () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet FormField *expirytextField;
@property (nonatomic, strong) UIPickerView *expiryDatePickerView;
@property (nonatomic, strong) NSArray *expiryDatePickerViewSelections;
@property (nonatomic, strong) TimeManager *timeController;
@end

@implementation CardDetailsTableViewCell


-(NSArray *)expiryDatePickerViewSelections {
    if (_expiryDatePickerViewSelections == nil) {
        NSMutableArray *selections = [[TimeManager expiryDatesFromDate:[NSDate date]] mutableCopy];
        [selections insertObject:[NSNull null] atIndex:0];
        _expiryDatePickerViewSelections = [selections copy];
    }
    return _expiryDatePickerViewSelections;
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

-(void)awakeFromNib {
    
    self.expirytextField.inputView = self.expiryDatePickerView;
    NSInteger selected = [self.expiryDatePickerView selectedRowInComponent:0];
    if (selected >= 0 && selected < self.expiryDatePickerViewSelections.count) {
        NSDate *selection = self.expiryDatePickerViewSelections[selected];
        NSString *date = [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
        self.expirytextField.text = date;
#warning model not updating here
        //self.form.expiry = date;
    }
    
}

#pragma mark - UIPickerView Datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.expiryDatePickerViewSelections.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    id selection = self.expiryDatePickerViewSelections[row];
    
    if ([selection isKindOfClass:[NSDate class]]) {
        return [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
    } else if ([selection isKindOfClass:[NSNull class]]) {
        return @"--/--";
    }
    
    return nil;
}

#pragma mark - UIPickerView Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    FormField *textField = self.expirytextField;
    id selection = self.expiryDatePickerViewSelections[row];
    if ([selection isKindOfClass:[NSNull class]]) {
        textField.text = nil;
#warning not updating model here
        
    } else if ([selection isKindOfClass:[NSDate class]]) {
        NSString *dateString = [self.timeController.cardExpiryDateFormatter stringFromDate:selection];
        textField.text = dateString;
        
#warning not updating model here
        
    }
}

@end
