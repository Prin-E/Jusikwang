//
//  JusikScriptViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 9..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "JusikScriptViewController.h"
#import "JusikScript.h"
#import "JusikUIDataTypes.h"
#import "JusikBGMPlayer.h"

NSString *const JusikScriptViewScriptDidStartNotification = @"JusikScriptViewScriptDidStartNotification";
NSString *const JusikScriptViewNextSpeechNotification = @"JusikScriptViewNextSpeechNotification";
NSString *const JusikScriptViewScriptDidEndNotification = @"JusikScriptViewScriptDidEndNotification";

@interface JusikScriptViewController (Private)
- (void)_showLeftStandingImageWithImage: (UIImage *)image animated: (BOOL)animated;
- (void)_hideLeftStandingImageAnimated: (BOOL)animated;
- (void)_showRightStandingImageWithImage: (UIImage *)image animated: (BOOL)animated;
- (void)_hideRightStandingImageAnimated: (BOOL)animated;
@end

@implementation JusikScriptViewController {
    JusikScript *_script;
    NSUInteger _currentSpeechIndex;
    NSUInteger _speechCount;
    
    UIImageView *_leftStandingImage;
    UIImageView *_rightStandingImage;
    BOOL _showingLeftStandingImage;
    BOOL _showingRightStandingImage;
    
    AVAudioPlayer *_soundEffectPlayer;
    BOOL _scriptEnded;
}

@synthesize speechView = _speechView;
@synthesize speechText = _speechText;
@synthesize backgroundView = _backgroundView;
@synthesize backgroundImageView = _backgroundImageView;

@synthesize showsBackground = _showsBackground;
@synthesize speeching = _speeching;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _showsBackground = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 프로퍼티 메서드
- (BOOL)showsBackground {
    return _showsBackground;
}

- (void)setShowsBackground:(BOOL)showsBackground {
    if(showsBackground == _showsBackground) return;
    _showsBackground = showsBackground;
    
    CGRect viewFrame = self.view.frame;
    CGRect speechFrame = self.speechView.frame;
    CGRect backgroundFrame = self.backgroundView.frame;
    if(showsBackground) {
        viewFrame.size.height = backgroundFrame.size.height;
        viewFrame.origin.y += backgroundFrame.size.height - speechFrame.size.height;
        self.view.frame = viewFrame;
        
        speechFrame.origin.y = backgroundFrame.size.height;
        self.speechView.frame = speechFrame;
        
        backgroundFrame.origin.x = 0;
        backgroundFrame.origin.y = 0;
        self.backgroundView.frame = backgroundFrame;
        [self.view addSubview: self.backgroundView];
    }
    else {
        viewFrame.size.height = speechFrame.size.height;
        viewFrame.origin.y -= backgroundFrame.size.height - speechFrame.size.height;
        self.view.frame = viewFrame;
        
        speechFrame.origin.y = 0;
        self.speechView.frame = speechFrame;
        [self.backgroundView removeFromSuperview];
    }
    [self.view addSubview: self.speechView];
}

#pragma mark - 스크립트 실행
- (void)runScript:(JusikScript *)script defaultBackground:(UIImage *)image {
    _speeching = YES;
    
    [script retain];
    [_script release];
    _script = script;
    _currentSpeechIndex = -1;
    _speechCount = [_script.speeches count];
    
    _scriptEnded = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikScriptViewScriptDidStartNotification
                                                        object: self];
    
    self.backgroundView.alpha = 1.0;
    if(image) {
        self.backgroundImageView.alpha = 0;
        self.backgroundImageView.image = image;
        [UIView animateWithDuration: kJusikViewFadeTime
                         animations: ^{
                             self.backgroundImageView.alpha = 1; 
                         }];
    }
    else {
        self.backgroundImageView.image = nil;
    }
    
    [self nextSpeech];
}

- (void)nextSpeech {
    // 스크립트가 완전히 끝나면 노티피케이션 호출
    if(_scriptEnded) {
        [self _hideLeftStandingImageAnimated: NO];
        [self _hideRightStandingImageAnimated: NO];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName: JusikScriptViewScriptDidEndNotification object: self];
        return;
    }
    
    // 대화가 끝나면 호출된다.
    if(_currentSpeechIndex + 1 >= [_script.speeches count]) {
        _speeching = NO;
        self.speechText.text = NSLocalizedString(@"com.jusikwang.script.end", @"스크립트가 종료되었습니다.");
        [UIView animateWithDuration: kJusikViewFadeTime
                         animations: ^{
                             self.backgroundView.alpha = 0;
                         }];
        
        _scriptEnded = YES;
        return;
    }
    
    // 대화는 진행중    
    _currentSpeechIndex++;
    JusikSpeech *speech = [_script.speeches objectAtIndex: _currentSpeechIndex];
    NSString *who;
    if(speech.who)
        who = NSLocalizedString(speech.who, speech.who);
    else
        who = nil;
    NSString *speechStr;
    if(speech.speech)
        speechStr = NSLocalizedString(speech.speech, speech.speech);
    else
        speechStr = nil;
    
    UIImage *standingImage = nil;
    if(speech.standingImageName)
        standingImage = [UIImage imageNamed: speech.standingImageName];
    if(speech.position != JusikStandingCutPositionNone) {
        if(speech.position == JusikStandingCutPositionLeft) {
            [self _hideLeftStandingImageAnimated: NO];
            [self _showLeftStandingImageWithImage: standingImage animated: YES];
        }
        else if(speech.position == JusikStandingCutPositionRight) {
            [self _hideRightStandingImageAnimated: NO];
            [self _showRightStandingImageWithImage: standingImage animated: YES];
        }
    }
    if(speech.backgroundImageName) {
        UIImage *backgroundImage = [UIImage imageNamed: speech.backgroundImageName];
        [UIView animateWithDuration: kJusikViewFadeTime
                         animations: ^{
                             self.backgroundImageView.alpha = 0;
                         }
                         completion: ^(BOOL finished) {
                             self.backgroundImageView.image = backgroundImage;
                             [UIView animateWithDuration: kJusikViewFadeTime
                                                   delay: 0
                                                 options: UIViewAnimationCurveEaseOut
                                              animations: ^{
                                                  self.backgroundImageView.alpha = 1.0;
                                              }
                                              completion: nil];
                         }];
    }
    
    if(speech.musicName) {
        [[JusikBGMPlayer sharedPlayer] playMusic: speech.musicName];
    }
    if(speech.soundEffectName) {
        if(_soundEffectPlayer) {
            [_soundEffectPlayer stop];
            [_soundEffectPlayer release];
            _soundEffectPlayer = nil;
        }
        NSArray *components = [speech.soundEffectName componentsSeparatedByString: @"/"];
        if(components.count >= 2) {
            NSString *directory = [components objectAtIndex: 0];
            NSString *filename = [[components objectAtIndex: 1] stringByDeletingPathExtension];
            NSString *extension = [speech.soundEffectName pathExtension];
            NSString *path = [[NSBundle mainBundle] pathForResource: filename ofType: extension inDirectory: directory];
            if(path) {
                _soundEffectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: path] error: nil];
                [_soundEffectPlayer play];
            }
        }
    }
    
    // 메시지 출력
    NSString *touchMessage = NSLocalizedString(@"com.jusikwang.script.touch", @"touch");
    if(who && speechStr)
        self.speechText.text = [NSString stringWithFormat: @"%@ : 『%@』%@", who, speechStr, touchMessage];
    else if(speechStr)
        self.speechText.text = [NSString stringWithFormat: @"〖 %@ 〗%@", speechStr, touchMessage];
    else
        self.speechText.text = [NSString stringWithFormat: @"-- %@", touchMessage];
    
    // 노티피케이션 호출
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: JusikScriptViewNextSpeechNotification object: self];
}

#pragma mark - 터치 이벤트
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self nextSpeech];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _leftStandingImage = [[UIImageView alloc] initWithFrame: CGRectMake(-140, 25, 140, 175)];
    _rightStandingImage = [[UIImageView alloc] initWithFrame: CGRectMake(480, 25, 140, 175)];
    
    CGRect viewFrame = self.view.frame;
    CGRect speechFrame = self.speechView.frame;
    CGRect backgroundFrame = self.backgroundView.frame;
    if(_showsBackground) {
        viewFrame.size.height = backgroundFrame.size.height;
        viewFrame.origin.y = 0;
        self.view.frame = viewFrame;
        
        speechFrame.origin.y = backgroundFrame.size.height - speechFrame.size.height;
        self.speechView.frame = speechFrame;
        
        backgroundFrame.origin.x = 0;
        backgroundFrame.origin.y = 0;
        self.backgroundView.frame = backgroundFrame;
        [self.view addSubview: self.backgroundView];
    }
    else {
        viewFrame.size.height = speechFrame.size.height;
        viewFrame.origin.y = 0;
        self.view.frame = viewFrame;
        
        speechFrame.origin.y = 0;
        self.speechView.frame = speechFrame;
        [self.backgroundView removeFromSuperview];
    }
    [self.view addSubview: self.speechView];
    
    self.speechView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Images/dialog.png"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.speechView = nil;
    self.speechText = nil;
    self.backgroundView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 비공개 메서드
- (void)_showLeftStandingImageWithImage: (UIImage *)image animated: (BOOL)animated {
    if(_showingLeftStandingImage) {
        [self _hideLeftStandingImageAnimated: NO];
    }
    if(image) {
        _leftStandingImage.image = image;
        [self.backgroundView addSubview: _leftStandingImage];
        
        CGRect frame = _leftStandingImage.frame;
        
        CGSize imageSize = _leftStandingImage.image.size;
        if(imageSize.height != 265.0) {
            imageSize.width /= imageSize.height / 265.0;
            imageSize.height /= imageSize.height / 265.0;
        }
        
        frame.origin.x = -imageSize.width;
        frame.size.width = imageSize.width;
        frame.size.height = imageSize.height;
        _leftStandingImage.frame = frame;
        
        [UIView animateWithDuration: animated ? kJusikViewFadeTime : 0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect frame = _leftStandingImage.frame;
                             frame.origin.x = 20;
                             _leftStandingImage.frame = frame;
                         }
                         completion: nil];
        _showingLeftStandingImage = YES;
    }
}

- (void)_hideLeftStandingImageAnimated: (BOOL)animated {
    if(_showingLeftStandingImage) {
        [UIView animateWithDuration: animated ? kJusikViewFadeTime : 0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect frame = _leftStandingImage.frame;
                             frame.origin.x = -frame.size.width;
                             _leftStandingImage.frame = frame;
                         } 
                         completion: ^(BOOL completed) {
                         }];
        _showingLeftStandingImage = NO;
    }
}

- (void)_showRightStandingImageWithImage: (UIImage *)image animated: (BOOL)animated {
    if(_showingRightStandingImage) {
        [self _hideRightStandingImageAnimated: NO];
    }
    if(image) {
        _rightStandingImage.image = image;
        [self.backgroundView addSubview: _rightStandingImage];
        
        CGRect frame = _rightStandingImage.frame;
        
        CGSize imageSize = _rightStandingImage.image.size;
        if(imageSize.height != 265.0) {
            imageSize.width /= imageSize.height / 265.0;
            imageSize.height /= imageSize.height / 265.0;
        }
        
        frame.size.width = imageSize.width;
        frame.size.height = imageSize.height;
        _rightStandingImage.frame = frame;
        
        [UIView animateWithDuration: animated ? kJusikViewFadeTime : 0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect frame = _rightStandingImage.frame;
                             frame.origin.x = self.view.frame.size.width - frame.size.width - 20;
                             _rightStandingImage.frame = frame;
                         }
                         completion: nil];
        _showingRightStandingImage = YES;
    }
}

- (void)_hideRightStandingImageAnimated: (BOOL)animated {
    if(_showingRightStandingImage) {
        [UIView animateWithDuration: animated ? kJusikViewFadeTime : 0
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect frame = _rightStandingImage.frame;
                             frame.origin.x = self.view.frame.size.width;
                             _rightStandingImage.frame = frame;
                         } 
                         completion: ^(BOOL completed) {
                         }];
        _showingRightStandingImage = NO;
    }
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_leftStandingImage release];
    [_rightStandingImage release];
    [_script release];
    
    [super dealloc];
}

@end
