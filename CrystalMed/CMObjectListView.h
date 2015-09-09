//
//  CMUniversityListView.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol CMDataSelectionDelegate <NSObject>

-(void)didSelectObject:(PFObject*)object;
-(void)didCancel;


@end

@interface CMObjectListView : UITableViewController

@property id<CMDataSelectionDelegate> delegate;

@property (retain) NSArray *objects;
@property (retain) NSString *className;
@property (retain) NSString *mainKey;

@end
