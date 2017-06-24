//
//  WeekSettingsViewController.h
//  CalendarDemo - Graphical Calendars Library for iOS
//
//  Copyright (c) 2014-2015 Bhavesh Kumbhani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeekViewController.h"


@protocol WeekSettingsViewControllerDelegate;


@interface WeekSettingsViewController : UITableViewController

@property (nonatomic) WeekViewController *weekViewController;

@end
