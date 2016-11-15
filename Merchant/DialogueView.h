//
//  DialogueView.h
//  Merchant
//
//  Created by Robert Nash on 22/06/2015.
//  Copyright (c) 2016 Pay360 by Capita. All rights reserved.
//

#import "ActionButton.h"

@interface DialogueView : UIView

@property (nonatomic, copy) void(^actionButtonHandler)(ActionButton *);

+(instancetype)dialogueView;

-(void)updateBody:(NSString*)text updateTitle:(NSString*)title;

@end
