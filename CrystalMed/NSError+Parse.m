//
//  NSError+Parse.m
//  MyCQs
//
//  Created by JAMES GUPTA on 05/09/2014.
//  Copyright (c) 2014 MyLabs. All rights reserved.
//

#import "NSError+Parse.h"
#import <Parse/Parse.h>
#import <UIAlertView+Blocks.h>

@implementation NSError (Parse)
/*
 This is a class extension which gives automatic error descriptions for all of the Parse error codes which can be displayed in a UIAlertView or wherever.
 
 It defaults to a standard 'your request couldnt be completed' if no error code is found.
 
 NOTE: Currently this is NOT an exhaustive list of all Parse error codes, see ToDo
 */

-(void)showAlert {
    [UIAlertView showWithTitle:@"Error" message:[self parseErrorDescription] style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
}

-(NSString*)parseErrorDescription {
    if (self.code == kPFErrorInvalidEmailAddress) {
        return @"Please enter a valid email address";
    }
    else if (self.code == kPFErrorUserWithEmailNotFound) {
        return @"No user found with that email address";
    }
    else if (self.code == kPFErrorConnectionFailed || self.code == kPFErrorTimeout) {
        return @"Please check your internet connection and try again later";
    }
    else if (self.code == kPFErrorUserEmailTaken) {
         return @"An account already exists with this email address, try logging in instead";
    }
    else if (self.code == kPFErrorUserEmailMissing) {
        return @"Please enter a valid email address";
    }
    else if (self.code == kPFErrorFacebookAccountAlreadyLinked) {
        return @"";
    }
    else if (self.code == kPFErrorConnectionFailed) {
        return @"There was a problem with your internet connection, please check and try again";
    }
    else if (self.code == kPFErrorDuplicateValue) {
        return @"";
    }
    else if (self.code == kPFErrorExceededQuota) {
        return @"We're experiencing a lot of traffic right now sorry! Please try again later";
    }
    else if (self.code == kPFErrorFacebookAccountAlreadyLinked) {
        return @"";
    }
    else if (self.code == kPFErrorFacebookIdMissing) {
        return @"";
    }
    else if (self.code == kPFErrorFacebookInvalidSession) {
        return @"";
    }
    
    //TODO add all kPFError codes here
    
    return @"Sorry we couldn't complete your request. Please check your internet connection and try again";
    
}

@end
