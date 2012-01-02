//
//  JusikPlayerInfoViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingTabsControl.h"

@class JusikPlayer;
@interface JusikPlayerInfoViewController : UIViewController <SlidingTabsControlDelegate>

@property (nonatomic, retain) IBOutlet SlidingTabsControl *tab;

@property (nonatomic, retain) JusikPlayer *player;
@end
