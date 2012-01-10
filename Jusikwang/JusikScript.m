//
//  JusikScript.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 9..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikScript.h"

@implementation JusikSpeech
@synthesize who = _who;
@synthesize speech = _speech;
@synthesize standingImageName = _standingImageName;
@synthesize position = _position;
@synthesize musicName = _musicName;
@synthesize soundEffectName = _soundEffectName;
@synthesize backgroundImageName = _backgroundImageName;

- (void)dealloc {
    self.who = nil;
    self.speech = nil;
    self.standingImageName = nil;
    self.musicName = nil;
    self.soundEffectName = nil;
    self.backgroundImageName = nil;
    
    [super dealloc];
}

@end

@implementation JusikScript
@synthesize speeches = _speeches;

- (id)init {
    self = [super init];
    if(self) {
        _speeches = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    [_speeches release];
    [super dealloc];
}

@end
