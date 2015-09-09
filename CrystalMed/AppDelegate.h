//
//  AppDelegate.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain) MBProgressHUD *HUD;
-(void)showHUDWithMessage:(NSString*)message inView:(UIView*)view;
-(void)hideHUD;
-(void)showConfirmationHUDWithMessage:(NSString*)message InView:(UIView*)view for:(NSTimeInterval)seconds;
-(void)showAlertForError:(NSError*)error;
+(AppDelegate*)appDelegate;
+(NSURL*)urlForFacebookId:(NSString*)facebookId;
@end

