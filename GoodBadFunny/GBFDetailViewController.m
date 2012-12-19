//
//  GBFDetailViewController.m
//  GoodBadFunny
//
//  Created by Abdullah Farah on 12/15/12.
//  Copyright (c) 2012 Satnford, CA. All rights reserved.
//

#import "GBFDetailViewController.h"
#import "GBFCommon.h"
#import "MBProgressHUD.h"

#define SCROLLVIEW_CONTENT_WIDTH 320
#define SCROLLVIEW_CONTENT_HEIGHT 420

@interface GBFDetailViewController ()
{
    NSUserDefaults *userDefaults;
}

- (void)configureView;

@end

@implementation GBFDetailViewController

- (void)dealloc
{
    [_detailItem release];
    [_good release];
    [_bad release];
    [_funny release];
    [_share release];
    [_cancel release];
    [_scrollView release];
    [_dateLabel release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.good.layer.cornerRadius = 6.0;
    self.good.clipsToBounds = YES;
    self.bad.layer.cornerRadius = 6.0;
    self.bad.clipsToBounds = YES;
    self.funny.layer.cornerRadius = 6.0;
    self.funny.clipsToBounds = YES;
    
    if (self.selectedUser != [userDefaults valueForKey:USER_ID_KEY]) {
        self.good.editable = false;
        self.bad.editable = false;
        self.funny.editable = false;
        self.share.hidden = true;
        self.cancel.hidden = true;
    }
    
    // Update the user interface for the detail item.
    self.dateLabel.text = [GBFCommon getLongDateStringFromInterval:self.currentDate.timeIntervalSince1970];
    
    if (self.detailItem) {
        self.good.text = [self.detailItem objectForKey:@"good"];
        self.bad.text = [self.detailItem objectForKey:@"bad"];
        self.funny.text = [self.detailItem objectForKey:@"funny"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    UITapGestureRecognizer *_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:_recognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, SCROLLVIEW_CONTENT_HEIGHT);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

- (void)hideKeyboard
{
    [_good resignFirstResponder];
    [_bad resignFirstResponder];
    [_funny resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (void)handleTap:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self hideKeyboard];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag == 1) 
        [self.scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
    else if (textView.tag == 2)
        [self.scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
    else
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)shareOnParse:(id)sender
{
    PFObject *object = nil;
    MBProgressHUD *progress = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:progress];
    progress.delegate = self;
    progress.labelText = @"Saving..";
    [progress show:YES];
    if (self.detailItem) {
        object = self.detailItem;
        [object setObject:self.good.text forKey:@"good"];
        [object setObject:self.bad.text forKey:@"bad"];
        [object setObject:self.funny.text forKey:@"funny"];
    
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [progress hide:YES];
            if (succeeded) {
                [GBFCommon showNotificationWithTitle:@"Updated Successfully" message:@"Your entry was updated to Parse.com successfully." delegate:self tag:999];
            } else {
                [GBFCommon showNotificationWithTitle:@"Update Failed" message:error.localizedDescription delegate:nil tag:0];
            }
        }];
    } else {
        object = [PFObject objectWithClassName:PARSE_CLASS_NAME];
        [object setObject:self.good.text forKey:@"good"];
        [object setObject:self.bad.text forKey:@"bad"];
        [object setObject:self.funny.text forKey:@"funny"];
        [object setObject:self.selectedUser forKey:@"user_id"];
        [object setObject:self.currentDate forKey:@"dateForGBF"];
        
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [progress hide:YES];
            if (succeeded) {
                [GBFCommon showNotificationWithTitle:@"Saved Successfully" message:@"Your entry was saved to Parse.com successfully" delegate:self tag:999];
            } else {
                [GBFCommon showNotificationWithTitle:@"Save Failed" message:error.localizedDescription delegate:self tag:0];
            }
        }];
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [hud release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999) {
        [self goBack];
    }
}
							
@end