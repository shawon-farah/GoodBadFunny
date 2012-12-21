//
//  GBFMasterViewController.m
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/15/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "GBFMasterViewController.h"
#import "GBFDetailViewController.h"
#import "GBFCommon.h"
#import "MBProgressHUD.h"

@interface GBFMasterViewController () 

@end

@implementation GBFMasterViewController

@synthesize firstUser, secondUser, weekDates, dashboardView, calendarView1, calendarView2, nextButton;

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
    [_currentStartDate release];
    [firstUser release];
    [secondUser release];
    [dashboardView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.loginView.layer.cornerRadius = 10.0f;
    self.loginView.layer.masksToBounds = YES;
    self.loginView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginView.layer.borderWidth = 2.0f;
    
    self.currentStartDate = [NSDate date];
    self.nextButton.enabled = false;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"GBF", @"Dashboard")];
    
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 6; i++) {
        [self.dataArray addObject:[NSMutableDictionary dictionary]];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:USER_ID_KEY] intValue] > 0) {
        self.dashboardView.hidden = FALSE;
        self.loginView.hidden = TRUE;
        [self addNavigationItems];
    } else {
        [self showLogin];
    }
    
    self.weekDates.text = [GBFCommon getWeekStringStartingFrom:self.currentStartDate];
    [self drawHeaderView];
    [self drawCalendarViews];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandler:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [self.dashboardView addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandler:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    [self.dashboardView addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.usersScrollView.contentSize = CGSizeMake(self.view.frame.size.width, 410);
    
    if (!dashboardView.hidden) {
        [self fetchData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLogin
{    
    self.loginView.hidden = false;
    self.dashboardView.hidden = true;
}

- (IBAction)logout:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:NULL forKey:USER_NAME_KEY];
    [userDefaults setValue:[NSNumber numberWithInt:0] forKey:USER_ID_KEY];
    
    [self removeNavigationItems];
    [self showLogin];
}

- (void)drawHeaderView
{
    for (int i = 0; i < 7; i++) {
        double interval = self.currentStartDate.timeIntervalSince1970 - (DAY_IN_SECONDS * i);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(((6*i) + (36*i)), 2, 36, 36)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        label.textAlignment = UITextAlignmentCenter;
        label.text = [GBFCommon getShortDayStringFromInterval:interval];
        [self.calendarHeaderView addSubview:label];
    }
}

- (void)drawCalendarViews
{
    for (UIView *view in self.usersScrollView.subviews) {
        if (![view isKindOfClass:[UILabel class]] && ![view isKindOfClass:[UIImageView class]]) {
            for (int i = 0; i < 7; i++) {
                UIButton *aButton = [[UIButton alloc] init];
                aButton.frame = CGRectMake(((6*i) + (36*i)), 2, 36, 36);
                double interval = self.currentStartDate.timeIntervalSince1970 - (DAY_IN_SECONDS * i);
                aButton.tag = interval;
                [aButton addTarget:self action:@selector(gotoDayView:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:aButton];
            }
        }
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
                int userId = [[object objectForKey:@"user_id"] intValue];
                self.dataArray[userId-1][dateString] = object;
            }
        }

        [self configureCalendarViews];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    }];
    
}

- (void)configureCalendarViews
{
    for (UIView *view in self.usersScrollView.subviews) {
        if (![view isKindOfClass:[UILabel class]] && ![view isKindOfClass:[UIImageView class]]) {
            for (UIButton *aButton in [view subviews]) {
                NSString *buttonDay = [GBFCommon getStandardDateStringFromInterval:aButton.tag];
                if (self.dataArray[view.tag-1][buttonDay] != nil) {
                    aButton.backgroundColor = [UIColor greenColor];
                } else {
                    if ([GBFCommon isToday:[NSDate dateWithTimeIntervalSince1970:aButton.tag]]) {
                        aButton.backgroundColor = [UIColor whiteColor];
                    } else {
                        aButton.backgroundColor = [UIColor redColor];
                    }
                }
            }
        }
    }
}

- (void)addNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(fetchData)];
}

- (void)removeNavigationItems
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
}

- (IBAction)loginUser:(id)sender
{
    self.loginView.hidden = true;
    self.dashboardView.hidden = false;
    
    UIButton *button = (UIButton*)sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:button.titleLabel.text forKey:USER_NAME_KEY];
    [userDefaults setValue:[NSNumber numberWithInt:button.tag] forKey:USER_ID_KEY];
    
    [self addNavigationItems];
    [self fetchData];
}

- (IBAction)goNextWeek:(id)sender
{
    double interval = self.currentStartDate.timeIntervalSince1970 + (DAY_IN_SECONDS * 7);
    self.currentStartDate = [GBFCommon getNextWeekDayWithInterval:interval];
    self.weekDates.text = [GBFCommon getWeekStringStartingFrom:self.currentStartDate];
    [self drawCalendarViews];
    [self configureCalendarViews];

    if ([GBFCommon isToday:self.currentStartDate]) {
        self.nextButton.enabled = false;
    }
}

- (IBAction)goPreviousWeek:(id)sender
{
    double interval = self.currentStartDate.timeIntervalSince1970 - (DAY_IN_SECONDS * 7);
    self.currentStartDate = [NSDate dateWithTimeIntervalSince1970:interval];
    self.weekDates.text = [GBFCommon getWeekStringStartingFrom:self.currentStartDate];
    [self drawCalendarViews];
    [self configureCalendarViews];
    self.nextButton.enabled = true;
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
    self.detailViewController.currentUserData = self.dataArray[view.tag - 1];
    if (self.dataArray[view.tag-1][dateString])
        self.detailViewController.detailItem = self.dataArray[view.tag-1][dateString];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void)gotoDayViewForToday
{
    self.detailViewController = [[GBFDetailViewController alloc] initWithNibName:@"GBFDetailViewController" bundle:nil];
    self.detailViewController.currentDate = [NSDate date];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_ID_KEY];
    self.detailViewController.selectedUser = userId;
    self.detailViewController.currentUserData = self.dataArray[userId.intValue - 1];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

- (void)leftSwipeHandler:(id)sender
{
    [self goPreviousWeek:nil];
}

- (void)rightSwipeHandler:(id)sender
{
    if ([self.nextButton isEnabled]) {
        [self goNextWeek:nil];
    }
}

@end
