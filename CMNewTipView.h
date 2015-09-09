//
//  CMNewTipView.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMObjectListView.h"


@interface CMNewTipView : UITableViewController
<CMDataSelectionDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textTip;
@property (strong, nonatomic) IBOutlet UIButton *buttonSubmit;
@property (retain) PFObject *chosenCategory;
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
@property (retain) NSIndexPath *chosenIndexPath;
@end
