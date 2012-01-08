//
//  JusikActivityGameView.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JusikActivityGameView.h"
#import "JusikPlayer.h"

@implementation JusikActivityGameView {
    CALayer *homeLayer;
}

@synthesize position = _position;
@synthesize player = _player;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        homeLayer = [CALayer layer];
        [self.layer addSublayer: homeLayer];
        homeLayer.bounds = self.layer.bounds;
        homeLayer.contents = (id)[[UIImage imageNamed: @"Images/avtivity_home.png"] CGImage];
    }
    return self;
}



@end
