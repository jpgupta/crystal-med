//
//  CMNewTipView.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMNewTipView.h"
#import <Parse/Parse.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import <UIAlertView+Blocks.h>

@implementation CMNewTipView

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"New Tip";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath {
    self.chosenIndexPath = indexPath;
    if (indexPath.row == 1) {
        CMObjectListView *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"objectList"];
        vc.delegate = self;
        vc.className = @"Topics";
        vc.mainKey = @"name";
//        self.chosenIndexPath = indexPath;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)pressedClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSelectObject:(PFObject *)object {
    self.chosenCategory = object;
    self.labelCategory.text = [object valueForKey:@"name"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.textTip becomeFirstResponder];
    [self.tableView deselectRowAtIndexPath:self.chosenIndexPath animated:YES];
}

-(void)didCancel {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)submitButtonPressed:(id)sender {
    
    if ([self.textTip.text length] > 0) {
        PFObject *newTip = [[PFObject alloc]initWithClassName:@"Posts"];
        [newTip setValue:self.textTip.text forKey:@"content"];
        if (self.chosenCategory) [newTip setObject:@[self.chosenCategory] forKey:@"topics"];
        [newTip setObject:[PFUser currentUser] forKey:@"author"];
        
        [[AppDelegate appDelegate]showHUDWithMessage:@"Loading..." inView:self.navigationController.view];
        
        [newTip saveInBackgroundWithBlock:^(BOOL success,NSError *error) {
            
            [[AppDelegate appDelegate]hideHUD];
            
            if (success) {
                [UIAlertView showWithTitle:@"Success" message:@"Your tip has been submitted, thanks for contributing!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alert, NSInteger buttonIndex) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else {
                [[AppDelegate appDelegate]showAlertForError:error];
            }
            
        }];
    }
    else {
        //error
    }
}


@end
