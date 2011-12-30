//
//  JusikLogoViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 28..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JusikLogoViewController : UIViewController {
    UIImageView *_logoImageView;
}

@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;

- (void)show3DsLogo;
- (void)fadeIn:(id)object;
- (void)fadeOut:(id)object;
- (void)postEndNotification:(id)object;

@end

extern NSString *JusikLogoViewAnimationDidEndNotification;