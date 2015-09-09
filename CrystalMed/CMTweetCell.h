//
//  CMTweetCell.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 06/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NZCircularImageView.h>

@interface CMTweetCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelTweet;
@property (strong, nonatomic) IBOutlet NZCircularImageView *profilePicture;

@end
