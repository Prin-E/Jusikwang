//
//  JusikViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 24..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JusikLogoViewController;
@class JusikMainMenuViewController;
@class JusikGameViewController;
@class JusikLoadingViewController;
@interface JusikViewController : UIViewController

@property (nonatomic, retain) JusikLogoViewController *logoViewController;
@property (nonatomic, retain) JusikMainMenuViewController *mainMenuViewController;
@property (nonatomic, retain) JusikGameViewController *gameViewController;
@property (nonatomic, retain) JusikLoadingViewController *loadingViewController;

// 초기화
- (void)setupUserDefaults;
- (void)setupBGMVolume;

// 로고
- (void)logoAnimationDidEnd: (NSNotification *)n;
- (void)showLogoView;
- (void)hideLogoView;

// 메인메뉴
- (void)showMainMenuView;
- (void)hideMainMenuView;

// 게임 시작
- (void)startGame: (id)sender;
- (void)startNewGame: (id)sender;
- (void)exitGame;

@end
