//
//  CMEnterDetailsView.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMEnterDetailsView.h"

@implementation CMEnterDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        
        CMObjectListView *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"objectList"];
        vc.delegate = self;
        vc.className = @"University";
        vc.mainKey = @"name";
        self.chosenIndexPath = indexPath;
        
        [self.navigationController pushViewController:vc animated:YES];
        // do something here
    }
 
}


-(void)didSelectObject:(PFObject *)object {

    if (self.chosenIndexPath.row == 1) {
        self.chosenUniversity = object;
        self.labelUniversityName.text = [self.chosenUniversity valueForKey:@"name"];
    }
  
    else if (self.chosenIndexPath.row == 2) {
        self.chosenYear = object;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)didCancel {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
