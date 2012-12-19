//
//  GBFCommon.h
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/18/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DAY_IN_SECONDS      86400
#define USER_ID_KEY         @"user_id"
#define USER_NAME_KEY       @"user_name"
#define PARSE_CLASS_NAME    @"habits"

@interface GBFCommon : NSObject

+ (NSString *)stringFromDate:(NSDate*)aDate withFormat:(NSString*)format;
+ (NSString *)getWeekStringStartingFrom:(NSDate*)startDate;
+ (NSString *)getShortDayStringFromInterval:(double)interval;
+ (NSString *)getStandardDateStringFromInterval:(double)interval;
+ (NSString *)getLongDateStringFromInterval:(double)interval;

+ (void)showNotificationWithTitle:(NSString*)_title message:(NSString*)_message delegate:(id)delegate tag:(int)_tag;

@end
