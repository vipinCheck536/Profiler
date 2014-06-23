//
//  AppDelegate.m
//  MockupSmartContacts
//
//  Created by Polisetty, Siddartha on 6/17/14.
//  Copyright (c) 2014 Polisetty, Siddartha. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:@"uHP4UuhQAVYfMmC3fHCCDfDHLl0lhDrNYB0MQQoq"
                  clientKey:@"gn4B2ufwQh8iye34XU9g0Hcr3o5u8zsRbBqSqie7"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [self.window makeKeyAndVisible];
    if(![PFUser currentUser])
    [self presentLoginViewControllerAnimated:NO];
    return YES;
}


-(void)presentLoginViewControllerAnimated:(BOOL)animated
{
    ParseLoginVC *plvc=[[ParseLoginVC alloc]init];
    plvc.delegate=self;
    plvc.fields = PFLogInFieldsUsernameAndPassword
    | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten;
    ParseSignUpVC *psvc=[[ParseSignUpVC alloc]init];
    plvc.signUpController=psvc;
    psvc.delegate=self;
    [self.window.rootViewController presentViewController:plvc animated:animated completion:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    self.isFbLogin=YES;
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    if(self.isFbLogin)
    {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
       if(!error)
       {
           [self facebookHandlerWithResult:result];
       }
       else
       {
           [SCUtility showAlertWithErrorCode:@SCFBFAILURE];
       }
    }];
    }
    else
    {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"USER SUCCESFULLY LOGGED IN");
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    [SCUtility showAlertWithErrorCode:@SCLOGINFAILURE];
}


- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSString *password = info[@"password"];
    NSString *username=info[@"username"];
    NSString *passwordSpaceRange = [password stringByReplacingOccurrencesOfString:@" "
                                                                       withString:@""];
    NSString *usernameSpaceRange=[username stringByReplacingOccurrencesOfString:@" "
                                                                 withString:@""];
    BOOL returnValue = password.length >= 8 && username.length>=8 && [username isEqualToString:usernameSpaceRange] && [password isEqualToString:passwordSpaceRange];
    if(!returnValue) [SCUtility showAlertWithErrorCode:@SCSIGNUPINVALIDINPUTS];
    return returnValue;
}



- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"USER SUCCESFULLY SIGNED UP");
}


- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    [SCUtility showAlertWithErrorCode:@SCSIGNUPFAILURE];
}

-(void)facebookHandlerWithResult:(id)result
{
    PFUser *user= [PFUser currentUser];
    if (user) {
        NSString *fbName=result[@"name"];
        user.username=fbName;
        NSString *fbId=result[@"id"];
        user[@"facebookId"]=fbId;
        NSURL *dpURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",fbId]];
        NSURLRequest *dpURLRequest=[NSURLRequest requestWithURL:dpURL];
        [NSURLConnection connectionWithRequest:dpURLRequest delegate:self];
        
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.dpData=[[NSMutableData alloc]init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dpData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (!self.dpData || self.dpData.length==0) {
        [SCUtility showAlertWithErrorCode:@SCFBFAILURE];
    }
    else
    {
        PFFile * dpFile=[PFFile fileWithData:self.dpData];
        [dpFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [SCUtility showAlertWithErrorCode:@SCFBFAILURE];
            }
            else
            {
                PFUser *user=[PFUser currentUser];
                user[@"profilePicture"]=dpFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [SCUtility showAlertWithErrorCode:@SCFBFAILURE];
                    }
                    else
                    {
                       [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                    }
                }];
            }
        }];
    }
}
@end
