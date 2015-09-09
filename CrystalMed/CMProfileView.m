//
//  CMProfileView.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMProfileView.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "CMPostCell.h"
#import "CMButton.h"
#import "NSArray+PFObject.h"
#import "CMProfileCell.h"

@implementation CMProfileView

-(void)viewDidLoad {
    [super viewDidLoad];
    self.labelName.text = [[PFUser currentUser]valueForKey:@"name"];
//    self.labelUniversity.text = [PFUser currentUser]
    [self.profileView setImageWithURL:[AppDelegate urlForFacebookId:[[PFUser currentUser]valueForKey:@"fbid"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)viewWillAppear:(BOOL)animated {
    [self reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    
    else if (section == 1) {
        return [self.posts count];
    }
    
    else return 0;
}

-(void)reloadData {
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query setLimit:10];
    [query includeKey:@"author"];
    [query includeKey:@"likedBy"];
    [query includeKey:@"topics"];
    [query orderByDescending:@"numberOfLikes"];
    [query whereKey:@"author" equalTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && [array count] > 0) {
            NSLog(@"Found objects for profile: %lu", (unsigned long)[array count]);
            
            
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 254;
    }
    else {
        return 105;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CMProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
        [cell.profilePicture setImageWithURL:[AppDelegate urlForFacebookId:[[PFUser currentUser]valueForKey:@"fbid"]] placeholderImage:[UIImage imageNamed:@"placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    

        
        return cell;
    }
    else {
     
        CMPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
        
        cell.buttonCrystal.indexPath = indexPath;
        
        PFObject *obj = [self.posts objectAtIndex:indexPath.row];
        
        
        cell.labelCategor.text = [NSString stringWithFormat:@"%@", [[[obj objectForKey:@"topics"]objectAtIndex:0]valueForKey:@"name"]];
        
        
        
        cell.labelPostTitle.text = [obj valueForKey:@"content"];
        cell.authorPicture.borderWidth = @1;
        
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
            PFFile *file = [obj objectForKey:@"profilePicture"];
            if ([file.url  length] > 0) {
                [cell.authorPicture setImageWithURL:[AppDelegate urlForFacebookId:[obj valueForKeyPath:@"author.fbid"]] placeholderImage:[UIImage imageNamed:@"placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
        }
        return cell;

    }
}


@end
