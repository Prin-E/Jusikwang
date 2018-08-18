//
//  JusikScript.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 9..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JusikStandingCutPositionNone = 0,
    JusikStandingCutPositionLeft = 1,
    JusikStandingCutPositionRight = 2
} JusikStandingCutPosition;

@interface JusikSpeech : NSObject {
    NSString *_who;
    NSString *_speech;
    NSString *_standingImageNames;
    JusikStandingCutPosition _position;
    NSString *_musicName;
    NSString *_soundEffectName;
    NSString *_backgroundImageName;
}
@property (nonatomic, copy) NSString *who;
@property (nonatomic, copy) NSString *speech;
@property (nonatomic, copy) NSString *standingImageName;
@property (nonatomic) JusikStandingCutPosition position;
@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *soundEffectName;
@property (nonatomic, copy) NSString *backgroundImageName;

@end

@interface JusikScript : NSObject {
    NSArray *_speeches;
}
@property (nonatomic, copy) NSArray *speeches;
@end
