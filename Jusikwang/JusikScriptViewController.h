//
//  JusikScriptViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 9..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikScript;
@interface JusikScriptViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *speechView;
@property (nonatomic, retain) IBOutlet UILabel *speechText;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) BOOL showsBackground;
@property (nonatomic, getter=isSpeeching) BOOL speeching;

- (void)runScript: (JusikScript *)script defaultBackground: (UIImage *)image;
- (void)nextSpeech;

@end


extern NSString *const JusikScriptViewScriptDidStartNotification;
extern NSString *const JusikScriptViewNextSpeechNotification;
extern NSString *const JusikScriptViewScriptDidEndNotification;