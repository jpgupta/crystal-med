//
//  CMTwitterList.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 06/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMObjectListView.h"

@interface CMTwitterList : UITableViewController
<CMDataSelectionDelegate>

@property (retain) NSArray *tweets;
@property (retain) PFObject *chosenCategory;
@property (strong, nonatomic) IBOutlet UILabel *labelNumCrystals;

@end
