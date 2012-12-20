//
//  GBFMasterViewController.m
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/15/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <Parse/Parse.h>
#import "GBFMasterViewController.h"
#import "GBFDetailViewController.h"
#import "GBFCommon.h"
#import "MBProgressHUD.h"

@interface GBFMasterViewController () {
    //NSMutableArray *_objects;
    NSDate *currentStartDate;
}

@property (nonatomic, retain) NSMutableDictionary *user1Data;
@property (nonatomic, retain) NSMutableDictionary *user2Data;

@end

@implementation GBFMasterViewController

@synthesize firstUser, secondUser, weekDates, dashboardView, calendarView1, calendarView2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [firstUser release];
    [secondUser release];
    [dashboardView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    currentStartDate = [NSDate date];
    self.title = [NSString stringWithFormat:NSLocalizedString(@"GoodBadFunny", @"Dashboard")];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_ID_KEY] > [NSNumber numberWithInt:-1]) {
        dashboardView.hidden = FALSE;
    } else {
        dashboardView.hidden = TRUE;
        [self showLogin];
    }
    
    self.weekDates.text = [GBFCommon getWeekStringStartingFrom:[NSDate date]];
    [self drawCalendarViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!dashboardView.hidden) {
        [self fetchData];
    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    if (!dashboardView.hidden) {
//        [self fetchData];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLogin
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please identify yourself." delegate:self cancelButtonTitle:nil otherButtonTitles:@"David", @"Jeanette", nil];
    [alertView show];
    [alertView release];
}

- (IBAction)logout:(id)sender
{
    dashboardView.hidden = true;
    [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:USER_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:-1] forKey:USER_ID_KEY];
    [self showLogin];
}

- (void)drawCalendarViews
{
    for (int i = 0; i < 7; i++) {
        UIButton *aButton = [[UIButton alloc] init];
        aButton.frame = CGRectMake(((6*i) + (36*i)), 2, 36, 36);
        double interval = currentStartDate.timeIntervalSince1970 - (DAY_IN_SECONDS * i);
        aButton.tag = interval;
        [aButton setTitle:[GBFCommon getShortDayStringFromInterval:interval] forState:UIControlStateNormal];
        aButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        aButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        aButton.backgroundColor = [UIColor clearColor];
        aButton.titleLabel.textColor = [UIColor clearColor];
        [aButton addTarget:self action:@selector(gotoDayView:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendarView1 addSubview:aButton];
    }
    
    for (int i = 0; i < 7; i++) {
        UIButton *aButton = [[UIButton alloc] init];
        aButton.frame = CGRectMake(((6*i) + (36*i)), 2, 36, 36);
        double interval = currentStartDate.timeIntervalSince1970 - (DAY_IN_SECONDS * i);
        aButton.tag = interval;
        [aButton setTitle:[GBFCommon getShortDayStringFromInterval:interval] forState:UIControlStateNormal];
        aButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        aButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        aButton.backgroundColor = [UIColor clearColor];
        aButton.titleLabel.textColor = [UIColor clearColor];
        [aButton addTarget:self action:@selector(gotoDayView:) forControlEvents:UIControlEventTouchUpInside];
        [self.calendarView2 addSubview:aButton];
    }
}

- (void)fetchData
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_NAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray *arr, NSError *error) {
        if (error == NULL) {
            for (int i = 0; i < arr.count; i++) {
                PFObject *object = [arr objectAtIndex:i];
                NSString *dateString = [GBFCommon getStandardDateStringFromInterval:[(NSDate*)[object objectForKey:@"dateForGBF"] timeIntervalSince1970]];
//                NSLog(@"data date: %@", dateString);
                if ([[object objectForKey:@"user_id"] integerValue] == 1)
                    self.user1Data[dateString] = object;
                else
                    self.user2Data[dateString] = object;
            }
        }
//        [self drawCalendarViews];
        [self configureCalendarViews];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }];
    
}

- (void)configureCalendarViews
{
    NSDate *today = [NSDate date];
    for (UIButton *aButton in [self.calendarView1 subviews]) {
        NSString *buttonDay = [GBFCommon getStandardDateStringFromInterval:aButton.tag];
        if (self.user1Data[buttonDay] != nil) {
            aButton.backgroundColor = [UIColor greenColor];
            aButton.titleLabel.textColor = [UIColor whiteColor];
        } else {
            if ([buttonDay isEqualToString:[GBFCommon getStandardDateStringFromInterval:today.timeIntervalSince1970]]) {
                aButton.backgroundColor = [UIColor whiteColor];
                aButton.titleLabel.textColor = [UIColor blackColor];
            } else {
                aButton.backgroundColor = [UIColor redColor];
                aButton.titleLabel.textColor = [UIColor whiteColor];
            }
        }
    }
    
    for (UIButton *aButton in [self.calendarView2 subviews]) {
        NSString *buttonDay = [GBFCommon getStandardDateStringFromInterval:aButton.tag];
        if (self.user2Data[buttonDay] != nil) {
            aButton.backgroundColor = [UIColor greenColor];
            aButton.titleLabel.textColor = [UIColor whiteColor];
        } else {
            if ([buttonDay isEqualToString:[GBFCommon getStandardDateStringFromInterval:today.timeIntervalSince1970]]) {
                aButton.backgroundColor = [UIColor whiteColor];
                aButton.titleLabel.textColor = [UIColor blackColor];
            } else {
                aButton.backgroundColor = [UIColor redColor];
                aButton.titleLabel.textColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dashboardView.hidden = false;
    self.user1Data = [NSMutableDictionary dictionary];
    self.user2Data = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (buttonIndex == 0) {
        [userDefaults setObject:@"David" forKey:USER_NAME_KEY];
        [userDefaults setValue:[NSNumber numberWithInt:2] forKey:USER_ID_KEY];
    } else {
        [userDefaults setObject:@"Jeanette" forKey:USER_NAME_KEY];
        [userDefaults setValue:[NSNumber numberWithInt:1] forKey:USER_ID_KEY];
    }
    [self fetchData];
}

- (IBAction)gotoDayView:(id)sender
{
    UIButton *aButton = (UIButton*)sender;
    UIView *view = [aButton superview];
    NSLog(@"view tag %d, button title %@", view.tag, aButton.titleLabel.text);
    NSString *dateString = [GBFCommon getStandardDateStringFromInterval:aButton.tag];
    
    self.detailViewController = [[GBFDetailViewController alloc] initWithNibName:@"GBFDetailViewController" bundle:nil];
    self.detailViewController.currentDate = [NSDate dateWithTimeIntervalSince1970:aButton.tag];
    self.detailViewController.selectedUser = [NSNumber numberWithInt:view.tag];
    if (view.tag == 1) {
        if (self.user1Data[dateString]) 
            self.detailViewController.detailItem = self.user1Data[dateString];
//        else
//            self.detailViewController.detailItem = [PFObject objectWithClassName:PARSE_CLASS_NAME];
    } else {
        if (self.user2Data[dateString]) 
            self.detailViewController.detailItem = self.user2Data[dateString];
//        else
//            self.detailViewController.detailItem = [PFObject objectWithClassName:PARSE_CLASS_NAME];
    }
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void)gotoDayViewForToday
{
    self.detailViewController = [[GBFDetailViewController alloc] initWithNibName:@"GBFDetailViewController" bundle:nil];
    self.detailViewController.currentDate = [NSDate date];
    self.detailViewController.selectedUser = [[NSUserDefaults standardUserDefaults] valueForKey:USER_ID_KEY];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
