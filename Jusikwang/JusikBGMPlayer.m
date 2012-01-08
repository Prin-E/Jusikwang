//
//  JusikBGMPlayer.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikBGMPlayer.h"
#import <AVFoundation/AVFoundation.h>

JusikBGMPlayer *_BGMPlayer = nil;

NSString *const JusikBGMMusicMainMenu = @"BG 1";
NSString *const JusikBGMMusicHappyEnding = @"BG 2";
NSString *const JusikBGMMusicActivity = @"BG 3";
NSString *const JusikBGMMusicNormalEnding = @"BG 4";
NSString *const JusikBGMMusicBadEnding = @"BG 5";

@implementation JusikBGMPlayer {
    NSMutableDictionary *_musics;
    
    AVAudioPlayer *_player;
    NSString *_currentMusic;
    double _volume;
}
@synthesize volume = _volume;

#pragma mark - 초기화 메서드
- (id)init {
    self = [super init];
    if(self) {
        _musics = [NSMutableDictionary new];
        _volume = 1.0;
    }
    return self;
}

+ (id)sharedPlayer {
    if(_BGMPlayer == nil) {
        _BGMPlayer = [[self alloc] init];
    }
    return _BGMPlayer;
}

#pragma mark - 음악 로딩/재생
- (void)loadMusic: (NSString *)musicName {
    if([_musics objectForKey: musicName] == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource: musicName ofType: @"mp3" inDirectory: @"Musics"];
        AVAudioPlayer *audio = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: path] error: nil];
        [_musics setObject: audio forKey: musicName];
        [audio release];
    }
}

- (NSArray *)musics {
    return [NSArray arrayWithObjects: JusikBGMMusicMainMenu, JusikBGMMusicHappyEnding, JusikBGMMusicActivity, JusikBGMMusicNormalEnding, JusikBGMMusicBadEnding, nil];
}

- (void)playMusic:(NSString *)musicName {
    if([_currentMusic isEqualToString: musicName] == NO) {
        [_player stop];
        [_player release];
        _player = nil;
        [_currentMusic release];
        _currentMusic = nil;
    }
    else
        return;
    
    [self loadMusic: musicName];
    _player = [_musics objectForKey: musicName];
    _player.numberOfLoops = 1000000;
    _player.volume = self.volume;
    [_player play];
    [_player retain];
    _currentMusic = [musicName copy];    
}

@end
