//
//  AppDelegate.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>
#import <UIAlertView+Blocks.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

/*
 ApPDelegate is the main 'control' file for iOS apps - handles events when the app starts, stops, enters the background etc. The main method is didFinishLaunchingWithOptions, which is called when the app starts.
 
 */

@implementation AppDelegate



/*
Basic methods to check which operating system the device is using. Important as certain functions aren't available in older versions of iOS
 */

+(BOOL)isAtLeastIOS7{
    NSArray *ver = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    int osVerson = [[ver objectAtIndex:0] intValue];
    return (osVerson >= 7);
}

+(BOOL)isAtLeastIOS8{
    NSArray *ver = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
    int osVerson = [[ver objectAtIndex:0] intValue];
    return (osVerson >= 8);
}

/*
Important for Facebook login if the user has to switch from CrystalMed to Facebook in order to log in.
 */

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}


/*
 Show a 'Loading...' or similar indicator in the current window - good for when processing network requests and keeping the UI updated
 */

-(void)showHUDWithMessage:(NSString*)message inView:(UIView*)view {
    [self.HUD hide:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    self.HUD.labelText = message;
}


/*
Similar to above but instead of showing a Loading message, will show a confirmation message for a few seconds i.e. 'Done!' and then disappear
*/

-(void)showConfirmationHUDWithMessage:(NSString*)message InView:(UIView*)view for:(NSTimeInterval)seconds {
    
    [self showHUDWithMessage:message inView:view];
    
    [self.HUD setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]]];
    
    self.HUD.mode = MBProgressHUDModeCustomView;
    [self.HUD hide:YES afterDelay:seconds];
}


-(void)hideHUD {
    if (![self.HUD isHidden]) {
        [self.HUD hide:YES];
    }
}




/*
 Small convenience method to get a reference to the current AppDelegate
 */

+ (AppDelegate*)appDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}


/*
 Convenience method to get a Facebook profile picture URL from a user's facebook ID
 */

+(NSURL*)urlForFacebookId:(NSString*)facebookId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", facebookId]];
    
    return url;
}

/*
 Standard way of showing specific Parse.com error descriptions
 */


-(void)showAlertForError:(NSError*)error {
    [UIAlertView showWithTitle:@"Error" message:[error.userInfo valueForKey:@"error"] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
}

//Go to the root screen from any point in the app
+(void)popToRootViewController {
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}



/*
 Main initialisation when the app starts
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    //Pase.com required methods
    [Parse setApplicationId:@"GRU67RqOoSaeEJLwzPdhv4BmLvPdMM96Av1MbLzK"
                  clientKey:@"jp1OaCUxsSp0MzweeX9IJwTNkZdDTzIs6hCVjcBe"];
        [PFFacebookUtils initializeFacebook];
    
    //Customise the appearance of the app
    [self setAppearance];
    
 

    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

-(void)setAppearance {
    
    //Ways of setting the app appearance i.e. colour, fonts etc
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance]setBarTintColor:[UIColor ICDLightBlueColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor whiteColor],
                                                           UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue" size:0.0],
                                                           }];
    
    [[UITabBarItem appearance]setTitleTextAttributes:@{
                                                       UITextAttributeTextColor: [UIColor whiteColor],
                                                       UITextAttributeFont: [UIFont fontWithName:@"HelveticaNeue" size:0.0],
                                                       } forState:UIControlStateNormal];
    
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance]setBarTintColor:[UIColor ICDLightBlueColor]];
  
    
    if ([AppDelegate isAtLeastIOS8]) {
        //These methods don't work, cause a crash in older versions of iOS
    [[UITabBar appearance]setTranslucent:NO];
    
    [[UINavigationBar appearance]setTranslucent:NO];
    [[UISearchBar appearance]setTranslucent:NO];
    }
    
    [[UISearchBar appearance]setBackgroundColor:[UIColor ICDDarkBlueColor]];
    
    [[UILabel appearance]setTextColor:[UIColor ICDDarkTextColor]];
    
    
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //For analytics purposes
    [FBSDKAppEvents activateApp];
}


@end
