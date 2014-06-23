//
//  SaveVCViewController.m
//  MockupSmartContacts
//
//  Created by Polisetty, Siddartha on 6/22/14.
//  Copyright (c) 2014 Polisetty, Siddartha. All rights reserved.
//

#import "SaveVCViewController.h"
#import <Parse/Parse.h>

@interface SaveVCViewController ()
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

@end

@implementation SaveVCViewController


-(BOOL)validateInputs
{
    BOOL verified = YES;
    NSString *fullName=self.fullNameTextField.text;
    NSString *phoneNumber=self.phoneNumberTextField.text;
    if(!fullName || !phoneNumber || fullName.length<=0 || phoneNumber.length<=0)
    {
        verified&=NO;
    }
    return verified;
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.fullNameTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    return YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.fullNameTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.fullNameTextField.text=nil;
    self.phoneNumberTextField.text=nil;
}


- (IBAction)saveContactInfo:(id)sender {
    
    if ([self validateInputs]) {
        PFObject *contact=[PFObject objectWithClassName:@"Contact"];
        contact[@"owner"]=[PFUser currentUser];
        contact[@"phonenumber"]=self.phoneNumberTextField.text;
        contact[@"fullname"]=self.fullNameTextField.text;
        [contact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [SCUtility showAlertWithErrorCode:@SCCONTACTUPLOADFAILURE];
            }
        }];
        [self.tabBarController setSelectedIndex:0];
    }
}


@end
