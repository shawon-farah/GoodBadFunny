//
//  GBFCommon.m
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/18/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "GBFCommon.h"

@implementation GBFCommon

+ (NSString *)stringFromDate:(NSDate*)aDate withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:aDate];
}

+ (NSString *)getWeekStringStartingFrom:(NSDate*)startDate
{
    double timeInterval = DAY_IN_SECONDS * 6; // 60*60*24 = 86400 (a day in seconds); 6 (is number of days)
//    NSDate *aDate = [[[NSDate alloc] init] autorelease];
    timeInterval = startDate.timeIntervalSince1970 - timeInterval;
    NSDate *beforeWeek = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:startDate];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:beforeWeek];
    
    NSString *string = @"";
    if ([components month] == [components2 month]) {
        string = [NSString stringWithFormat:@"%@ - ", [GBFCommon stringFromDate:startDate withFormat:@"MMM dd"]];
        string = [string stringByAppendingFormat:@"%@", [GBFCommon stringFromDate:beforeWeek withFormat:@"dd, YYYY"]];
    } else {
        if ([components year] == [components2 year]) {
            string = [NSString stringWithFormat:@"%@ - ", [GBFCommon stringFromDate:startDate withFormat:@"MMM dd"]];
            string = [string stringByAppendingFormat:@"%@", [GBFCommon stringFromDate:beforeWeek withFormat:@"MMM dd, YYYY"]];
        } else {
            string = [NSString stringWithFormat:@"%@ - %@", [GBFCommon stringFromDate:startDate withFormat:@"MMM dd, YYYY"], [GBFCommon stringFromDate:beforeWeek withFormat:@"MMM dd, YYYY"]];
        }
    }
    
    return string;
}

+ (NSString *)getShortDayStringFromInterval:(double)interval
{
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:interval];    
    
    return [GBFCommon stringFromDate:aDate withFormat:@"EEE"];
}

+ (NSString *)getStandardDateStringFromInterval:(double)interval
{
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [GBFCommon stringFromDate:aDate withFormat:@"MM-dd-YYYY"];
}

+ (NSString *)getLongDateStringFromInterval:(double)interval
{
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:interval];
    
    return [GBFCommon stringFromDate:aDate withFormat:@"EEEE MMM dd, YYYY"];
}

+ (void)showNotificationWithTitle:(NSString*)_title message:(NSString*)_message delegate:(id)_delegate tag:(int)_tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:_delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alertView.tag = _tag;
    [alertView show];
    [alertView release];
}

@end
