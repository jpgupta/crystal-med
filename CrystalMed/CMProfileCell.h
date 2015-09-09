//
//  CMProfileCell.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 06/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NZCircularImageView;

@interface CMProfileCell : UITableViewCell
@property (strong, nonatomic) IBOutlet NZCircularImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCrystals;

@end
