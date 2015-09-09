//
//  CMButton.h
//  CrystalMed
//
//  Created by JAMES GUPTA on 06/09/2015.
//  Copyright (c) 2015 AMEEHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMButton : UIButton

//This is just a really simple subclass of the standard Button (UIButton) class. It contains an IndexPath which can be used to reference the cell which it belongs to (in a table), so that we can get a handle on the data its representing

@property (retain) NSIndexPath *indexPath;
@end
