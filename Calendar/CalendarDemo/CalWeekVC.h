//
//  CalWeekVC.h
//  Calendar
//
//  Bhavesh Kumbhani on 03/03/17.
//  Copyright © 2017 Bhavesh Kumbhani. All rights reserved.
//

#import "MGCDayPlannerViewController.h"
#import "MainViewController.h"
#import "Constant.h"
#import "MGCCalendarHeaderView.h"

@protocol WeekViewControllerDelegate <MGCDayPlannerViewDelegate, CalendarViewControllerDelegate, UIViewControllerTransitioningDelegate>

@end

@interface CalWeekVC : MGCDayPlannerViewController <CalendarViewControllerNavigation>

@property (nonatomic, weak) id<WeekViewControllerDelegate> delegate;
@property (nonatomic) BOOL showDimmedTimeRanges;
- (void)reloadData;
@end
