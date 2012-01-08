//
//  JusikActivityGameView.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JusikActivityPositionHome,
    JusikActivityPositionOutside
} JusikActivityPosition;

@class JusikPlayer;
@interface JusikActivityGameView : UIView

@property (nonatomic) JusikActivityPosition position;
@property (nonatomic, retain) JusikPlayer *player;

@end
