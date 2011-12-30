//
//  JusikViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 24..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikLogoViewController;
@interface JusikViewController : UIViewController

@property (nonatomic, retain) JusikLogoViewController *logoViewController;

- (void)logoAnimationDidEnd: (NSNotification *)n;
@end
