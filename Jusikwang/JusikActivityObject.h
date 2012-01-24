//
//  JusikActivityObject.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 23..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JusikActivityObject : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, readonly) CALayer *layer;
@property (nonatomic) CGRect area;
@property (nonatomic, retain) UIImage *overImage;

- (id)initWithName: (NSString *)name;

- (void)showNormalState;
- (void)showPressedState;

@end
