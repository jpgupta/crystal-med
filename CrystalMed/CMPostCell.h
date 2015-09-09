//
//  CMPostCell.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NZCircularImageView.h>

@class CMButton;

@interface CMPostCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelPostTitle;
@property (strong, nonatomic) IBOutlet NZCircularImageView *authorPicture;
@property (strong, nonatomic) IBOutlet CMButton *buttonCrystal;
@property (strong, nonatomic) IBOutlet UILabel *labelCrystals;
@property (strong, nonatomic) IBOutlet UILabel *labelDistance;
@property (strong, nonatomic) IBOutlet UILabel *labelCategor;

@end
