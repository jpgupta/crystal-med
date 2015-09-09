//
//  CMTwitterList.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 06/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMTwitterList.h"
#import <AFNetworking.h>
#import "CMTweetCell.h"


@implementation CMTwitterList

-(void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)filterPressed:(id)sender {
    
        CMObjectListView *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"objectList"];
        vc.delegate = self;
        vc.className = @"Topics";
        vc.mainKey = @"name";
        //        self.chosenIndexPath = indexPath;
        
        [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)pressedClose:(id)sender {
    [self didCancel];
}

-(void)didSelectObject:(PFObject *)object {
    self.chosenCategory = object;
  //  self.labelCategory.text = [object valueForKey:@"name"];
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewDidAppear:(BOOL)animated {
    [self reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103.0;
}

-(void)reloadData {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *str = nil;
    if (self.chosenCategory) {
        str = [self.chosenCategory valueForKey:@"hashtag"];
    }
    
    NSMutableArray *hashtags = [[NSMutableArray alloc]init];
    [hashtags addObject:@"crystalmed"];
    
    if ([str length] > 0) {
        [hashtags addObject:str];
    }
    
    NSArray *array = [NSArray arrayWithArray:hashtags];
    
    [manager GET:[NSString stringWithFormat:@"http://crystalmed.pythonanywhere.com/tweet"] parameters:@{@"hashtags": array} success:^(AFHTTPRequestOperation *operation, id responseObject) {

        
        self.tweets = [[NSArray alloc]initWithArray:responseObject];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    
    NSDictionary *obj = [self.tweets objectAtIndex:indexPath.row];
    cell.labelTweet.text = [obj valueForKey:@"text"];
    
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:[[obj objectForKey:@"user"]valueForKey:@"profile_image_url_https"]]placeholderImage:[UIImage imageNamed:@"placeHolder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    return cell;
}


@end
