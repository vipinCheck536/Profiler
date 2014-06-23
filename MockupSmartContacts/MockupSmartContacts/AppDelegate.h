//
//  AppDelegate.h
//  MockupSmartContacts
//
//  Created by Polisetty, Siddartha on 6/17/14.
//  Copyright (c) 2014 Polisetty, Siddartha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseLoginVC.h"
#import "ParseSignUpVC.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate,NSURLConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableData *dpData;
@property (nonatomic)  BOOL isFbLogin;
-(void)presentLoginViewControllerAnimated:(BOOL)animated;
@end
