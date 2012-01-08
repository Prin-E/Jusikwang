//
//  JusikGameController.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JusikGameController <NSObject>

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

@end
