//
//  JusikMainMenuViewController.h
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 29..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JusikMainMenuViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *startGameButton;
@property (nonatomic, retain) IBOutlet UIButton *startNewGameButton;

@property (nonatomic, retain) IBOutlet UIView *mainMenuView;
@property (nonatomic, retain) IBOutlet UIView *preferenceView;
@property (nonatomic, retain) IBOutlet UIView *creditView;

@property (nonatomic, retain) IBOutlet UISlider *prefBGMSlider;
@property (nonatomic, retain) IBOutlet UISlider *prefSoundSlider;

- (void)changeToMainMenuView;
- (void)showMainMenuAnimation;

- (IBAction)showPreferences: (id)sender;
- (IBAction)showCredit: (id)sender;
- (IBAction)backToMainMenu:(id)sender;

- (IBAction)changeBGMVolume:(id)sender;
- (IBAction)changeSoundVolume:(id)sender;

@end
