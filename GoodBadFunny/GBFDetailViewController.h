//
//  GBFDetailViewController.h
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/15/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface GBFDetailViewController : UIViewController <UITextViewDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSDate *currentDate;
@property (strong, nonatomic) NSNumber *selectedUser;
@property (strong, nonatomic) NSMutableDictionary *currentUserData;
@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextView *good;
@property (strong, nonatomic) IBOutlet UITextView *bad;
@property (strong, nonatomic) IBOutlet UITextView *funny;

@property (strong, nonatomic) IBOutlet UIButton *share;
@property (strong, nonatomic) IBOutlet UIButton *cancel;
@property (strong, nonatomic) IBOutlet UIButton *next;

@end
