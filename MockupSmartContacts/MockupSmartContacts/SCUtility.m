//
//  SCUtility.m
//  MockupSmartContacts
//
//  Created by Polisetty, Siddartha on 6/17/14.
//  Copyright (c) 2014 Polisetty, Siddartha. All rights reserved.
//

#import "SCUtility.h"


@implementation SCUtility

+(void)showAlertWithErrorCode:(NSString *)errorCode
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"error" message:errorCode delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

@end
