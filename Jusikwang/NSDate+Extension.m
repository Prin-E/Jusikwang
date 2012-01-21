//
//  NSDate+Extension.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 9..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

- (BOOL)isWeekday {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    
    NSDateComponents *comp = [gregorian components: NSWeekdayCalendarUnit fromDate: self];
    NSLog(@"%d", comp.weekday);
    if(comp.weekday == 7 || comp.weekday == 1) {
        return YES;
    }
    return NO;
}

@end
