//
//  CMHomeView.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMHomeView.h"
#import <Parse/Parse.h>
#import "CMPostCell.h"
#import "CMNewTipView.h"
#import <PFFacebookUtils.h>
#import "AppDelegate.h"
#import "NSArray+PFObject.h"
#import "CMButton.h"

@implementation CMHomeView

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Tips";
   
}

-(void)viewWillAppear:(BOOL)animated {
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query setLimit:1000];
    [query includeKey:@"author"];
    [query includeKey:@"profilePicture"];
    [query includeKey:@"likedBy"];
    [query includeKey:@"topics"];
    [query orderByDescending:@"numberOfLikes"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && [array count] > 0) {
            NSLog(@"Found objects");
            
            
       //     [PFObject pinAllInBackground:array block:^(BOOL success, NSError *e) {
        //        if (success) {
                    
                    
                    self.posts = [[NSArray alloc]initWithArray:array];
                    [self.tableView reloadData];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"postsUpdated" object:nil];
       //         }
        //    }];
            
        }
        else {
            NSLog(@"ERROR: %@", error);
        }
    }];
}
- (IBAction)addNewTipPressed:(id)sender {
    
    CMNewTipView *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"newTipView"];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
    //    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
     //   [logInViewController setDelegate:self]; // Set ourselves as the delegate
     //   [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
 //   [logInViewController setFields:PFLogInFieldsFacebook];
        [PFUser logInWithUsernameInBackground:@"zereda" password:@"123456" block:^(PFUser *user, NSError *error) {
            NSLog(@"LOGIN USER: %@", error);
            NSLog(@"LOGIN USER: %@", user);
        }];
    
        // Present the log in view controller
   //     [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    //}
 /*   else {
        if (![PFUser currentUser]) {
           // [PFUser logInWithUsername:@"ameehacks" password:@"hackathon2015"]
        
            [PFUser logInWithUsernameInBackground:@"zereda" password:@"123456" block:^(PFUser *user, NSError *error) {
                NSLog(@"LOGIN USER: %@", error);
                NSLog(@"LOGIN USER: %@", user);
            }];
        }
    }*/
}


// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             [[PFUser currentUser]setValue:[result objectForKey:@"id"] forKey:@"fbid"];
             NSLog(@"RESULT: %@", result);
            [[PFUser currentUser]setValue:[result objectForKey:@"name"] forKey:@"name"];
             [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                 
                 [self dismissViewControllerAnimated:YES completion:NULL];

             }];

         }
         else {
             NSLog(@"ERROR: %@", error);
         }
     }];
    
}


// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...%@", error);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction)crystalButtonPressed:(CMButton*)sender {
    PFObject *obj = [self.posts objectAtIndex:sender.indexPath.row];

    
    NSArray *likesArray = [obj objectForKey:@"likedBy"];
    
    if ([likesArray containsParseObject:[PFUser currentUser]]) {
//        [cell.buttonCrystal setImage:[UIImage imageNamed:@"crystal_off"] forState:UIControlStateNormal];
        
        [sender setEnabled:NO];
  
        NSNumber *num = [obj valueForKey:@"numberOfLikes"];
       
        NSInteger integer = [num integerValue];
        if (integer > 0) {
            integer -= 1;
        }
        
        [obj setValue:[NSNumber numberWithInteger:integer] forKey:@"numberOfLikes"];
        
        NSMutableArray *array = [[NSMutableArray alloc]initWithArray:[obj objectForKey:@"likedBy"]];
        
        
        int indexToRemove = -1;
        
        for (int i = 0; i < [array count]; i++) {
            PFUser *user = [array objectAtIndex:i];
            
            if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
                indexToRemove = i;
                break;
            }
        }
        
        if (indexToRemove != -1) {
            [array removeObjectAtIndex:indexToRemove];
        }
        
        [obj setObject:array forKey:@"likedBy"];
        
        [obj saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
           
            if (success) {
                NSLog(@"OBJECT SAVED SUCCESSFULLY");
            }
            else {
                NSLog(@"ERROR SAVING: %@", error);
            }
            [sender setEnabled:YES];
            
        }];
        
        
        
    }
    else {
        [sender setImage:[UIImage imageNamed:@"crystal_off"] forState:UIControlStateNormal];
        
        [sender setEnabled:NO];
        
        NSNumber *num = [obj valueForKey:@"numberOfLikes"];
        
        NSInteger integer = [num integerValue];
            integer += 1;
        
        [obj setValue:[NSNumber numberWithInteger:integer] forKey:@"numberOfLikes"];
        
        NSMutableArray *array = [[NSMutableArray alloc]initWithArray:[obj objectForKey:@"likedBy"]];
        
        [array addObject:[PFUser currentUser]];
        
        [obj setObject:array forKey:@"likedBy"];
        
        [obj saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
            
            if (success) {
                NSLog(@"OBJECT SAVED SUCCESSFULLY");
            }
            else {
                NSLog(@"ERROR SAVING: %@", error);
            }
            [sender setEnabled:YES];
            
        }];

        
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc]initWithArray:self.posts];
    
    NSArray *newArray = [mutableArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"numberOfLikes" ascending:NO]]];
    
                         self.posts = newArray;
                         
    [self.tableView reloadData];

    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    
    cell.buttonCrystal.indexPath = indexPath;

    PFObject *obj = [self.posts objectAtIndex:indexPath.row];


    cell.labelCategor.text = [NSString stringWithFormat:@"%@", [[[obj objectForKey:@"topics"]objectAtIndex:0]valueForKey:@"name"]];
    

    if (indexPath.row == 0) {
        cell.labelCategor.text = @"Western Infirmary";
    }
    else if (indexPath.row == 1) {
        cell.labelCategor.text = @"Glasgow Heritage";
    }
    else {
        cell.labelCategor.text = @"AMEEHacks Tips!";
    }
    
    
    
    cell.labelPostTitle.text = [obj valueForKey:@"content"];
    cell.authorPicture.borderWidth = @1;
    NSLog(@"AUTHOR NAME: %@", [obj objectForKey:@"author"]);
    
    cell.authorPicture.borderColor = [UIColor darkGrayColor];
    cell.labelDistance.text = [NSString stringWithFormat:@"%@m",[obj valueForKey:@"distance"]];
 
    cell.labelCrystals.text = [[obj valueForKey:@"numberOfLikes"]stringValue];
    
    NSArray *likesArray = [obj objectForKey:@"likedBy"];
    
    if ([likesArray containsParseObject:[PFUser currentUser]]) {
        [cell.buttonCrystal setImage:[UIImage imageNamed:@"crystal"] forState:UIControlStateNormal];
    }
    else {
        [cell.buttonCrystal setImage:[UIImage imageNamed:@"crystal_off"] forState:UIControlStateNormal];
    }
    [cell.authorPicture setImage:[UIImage imageNamed:@"placeHolder"]];
    
    
    if ([obj valueForKeyPath:@"author.fbid"]) {
    
    [cell.authorPicture setImageWithURL:[AppDelegate urlForFacebookId:[obj valueForKeyPath:@"author.fbid"]] placeholderImage:[UIImage imageNamed:@"placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    }
    else {
        PFUser *user = [obj objectForKey:@"author"];
        PFFile *file = [user objectForKey:@"profilePicture"];
        NSLog(@"PROFILE FILE: %@", file);
        NSLog(@"PROFILE FILE: %@", file.url);
        NSLog(@"PROFILE URL: %@", [obj valueForKeyPath:@"author.profileURL"]);
        
            [cell.authorPicture setImageWithURL:[NSURL URLWithString:file.url] placeholderImage:[UIImage imageNamed:@"placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}



@end
