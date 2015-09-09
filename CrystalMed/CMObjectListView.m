//
//  CMUniversityListView.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMObjectListView.h"

@implementation CMObjectListView
@synthesize className;
@synthesize mainKey;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    [query setLimit:100];

    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && [array count] > 0) {
            NSLog(@"Found objects");
           
                    self.objects = [[NSArray alloc]initWithArray:array];
                    [self.tableView reloadData];

            
        }
    }];
    

    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectObject:[self.objects objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSObject *obj = [self.objects objectAtIndex:indexPath.row];
   cell.textLabel.text = [obj valueForKey:self.mainKey];
    
    
    return cell;
}

@end
