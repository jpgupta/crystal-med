//
//  CMProfileView.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NZCircularImageView.h>

@interface CMProfileView : UITableViewController

@property (strong, nonatomic) IBOutlet NZCircularImageView *profileView;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelUniversity;
@property (retain) NSArray *posts;

@end
