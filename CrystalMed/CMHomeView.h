//
//  CMHomeView.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PFLoginViewController.h>
#import <PFSignUpViewController.h>

@interface CMHomeView : UITableViewController
<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (retain) NSArray *posts;

@end
