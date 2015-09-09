//
//  CMTabBarController.m
//  CrystalMed
//
//  Created by JAMES GUPTA on 05/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import "CMTabBarController.h"

@implementation CMTabBarController
-(void)viewDidLoad {
    [super viewDidLoad];
    
    //Set images and colours for the tab car icons
    
    for (UIView *v in self.tabBar.subviews)
        if ([NSStringFromClass(v.class) isEqual:@"UITabBarButton"])
            [v performSelector:@selector(_setUnselectedTintColor:)
                    withObject:[UIColor whiteColor]];
    
    
}

@end
