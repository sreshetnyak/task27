//
//  TTViewController.m
//  UITextField
//
//  Created by sergey on 4/2/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "TTViewController.h"

#define LASTFIELD_TAG 17
#define KEYBOARD_SIZE 213.0

@interface TTViewController () <UITextFieldDelegate>

@property (nonatomic,assign) NSInteger currentTextField;

@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    for (UITextField *field in self.infoTextField) {
        field.delegate = self;
    }
    
    for (UILabel *label in self.infoLabel) {
        label.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITextField *field in self.infoTextField) {
        [field resignFirstResponder];
    }
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    self.currentTextField = textField.tag;
    
    if (textField.tag != LASTFIELD_TAG) {
        self.currentTextField ++;
        UITextField *field = (UITextField *)[self.view viewWithTag:self.currentTextField];
        [field becomeFirstResponder];
        
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self animateTextField:textField up:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL state;
    NSCharacterSet* textValidationSet = [[NSCharacterSet letterCharacterSet] invertedSet];
    NSCharacterSet* numberValidationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    switch (textField.tag) {
        case 10:
            state = ([[string componentsSeparatedByCharactersInSet:textValidationSet] count] > 1) ? NO : YES;
            break;
        case 11:
            state = ([[string componentsSeparatedByCharactersInSet:textValidationSet] count] > 1) ? NO : YES;
            break;
        case 12:
            return YES;
            break;
        case 13:
            return YES;
            break;
        case 14:
            state = ([[string componentsSeparatedByCharactersInSet:numberValidationSet] count] > 1) ? NO : YES;
            break;
        case 15:
            state = [self validationPhoneFor:textField inRange:range replacementString:string];
            break;
        case 16:
            state = ([[string componentsSeparatedByCharactersInSet:textValidationSet] count] > 1) ? NO : YES;
            break;
        case 17:
            state = [self validationEmailFor:textField inRange:range replacementString:string];
            break;
            
        default:
            break;
    }
    
    return state;
}

#pragma mark - IBAction

- (IBAction)textChange:(id)sender {
    UITextField *field = sender;
    UILabel *label = (UILabel *)[self.view viewWithTag:field.tag - 9];
    label.text = field.text;
}

#pragma marks - Methods

- (void)animateTextField:(UITextField*)textField up:(BOOL)up {
    
    CGFloat hight = textField.frame.origin.y;
    NSLog(@"%f",hight);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat maxHight = screenRect.size.height;
    NSLog(@"%f",maxHight);
    
    if (hight > KEYBOARD_SIZE + maxHight/5) {
        
        const int movementDistance = - (KEYBOARD_SIZE + 50 - (maxHight - hight));
        
        int movement = (up ? movementDistance : -movementDistance);
        
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.25f];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
}

- (BOOL)validationPhoneFor:(UITextField *)textField inRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    
    newString = [validComponents componentsJoinedByString:@""];
    
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 3;
    static const int countryCodeMaxLength = 3;
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength) {
        return NO;
    }
    
    NSMutableString* resultString = [NSMutableString string];
    NSInteger localNumberLength = MIN([newString length], localNumberMaxLength);
    
    if (localNumberLength > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLength];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    
    if ([newString length] > localNumberMaxLength) {
        
        NSInteger areaCodeLength = MIN((int)[newString length] - localNumberMaxLength, areaCodeMaxLength);
        
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
        
        NSString* area = [newString substringWithRange:areaRange];
        
        area = [NSString stringWithFormat:@"(%@) ", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    if ([newString length] > localNumberMaxLength + areaCodeMaxLength) {
        
        NSInteger countryCodeLength = MIN((int)[newString length] - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLength);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        
        [resultString insertString:countryCode atIndex:0];
    }
    
    textField.text = resultString;
    
    return NO;
}

- (BOOL)validationEmailFor:(UITextField *)textField inRange:(NSRange)range replacementString:(NSString *)string {

    NSLog(@"%@",string);
    NSLog(@"%lu",(unsigned long)[string rangeOfString:@"@"].location);
    NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@".ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@0123456789!#$%&'*+-/=?^_`{|}~"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
    
    if ([textField.text rangeOfString:@"@"].location == NSNotFound && [string rangeOfString:@"@"].location != NSNotFound) {
        return [string isEqualToString:filtered];
        
    } else if ([string rangeOfString:@"@"].location == NSNotFound) {
        
        return [string isEqualToString:filtered];
    } else {
        return NO;
    }
}

@end
