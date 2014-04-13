//
//  TTViewController.h
//  UITextField
//
//  Created by sergey on 4/2/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *infoTextField;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoLabel;
- (IBAction)textChange:(id)sender;

@end
