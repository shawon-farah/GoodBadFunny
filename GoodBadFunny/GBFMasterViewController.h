//
//  GBFMasterViewController.h
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/15/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GBFDetailViewController;

@interface GBFMasterViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *weekDates;
@property (nonatomic, retain) IBOutlet UILabel *firstUser;
@property (nonatomic, retain) IBOutlet UILabel *secondUser;

@property (nonatomic, retain) IBOutlet UIView *dashboardView;
@property (nonatomic, retain) IBOutlet UIView *calendarView1;
@property (nonatomic, retain) IBOutlet UIView *calendarView2;

@property (strong, nonatomic) GBFDetailViewController *detailViewController;

- (IBAction)gotoDayView:(id)sender;
- (void)gotoDayViewForToday;

@end
