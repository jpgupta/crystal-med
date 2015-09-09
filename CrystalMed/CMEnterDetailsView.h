//
//  CMEnterDetailsView.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMObjectListView.h"

@interface CMEnterDetailsView : UITableViewController
<CMDataSelectionDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelUniversityName;
@property (retain) PFObject *chosenUniversity;
@property (retain) PFObject *chosenYear;
@property (retain) NSIndexPath *chosenIndexPath;

@end
