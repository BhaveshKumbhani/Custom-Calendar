//
//  CalDayVC.h
//  Calendar
//
//  Bhavesh Kumbhani on 01/03/17.
//  Copyright © 2017 Bhavesh Kumbhani. All rights reserved.
//

#import "MGCDayPlannerViewController.h"
#import "MainViewController.h"
#import "Constant.h"
#import "MGCCalendarHeaderView.h"


@protocol DayViewControllerDelegate <MGCDayPlannerViewDelegate, CalendarViewControllerDelegate, UIViewControllerTransitioningDelegate>

@end
@interface CalDayVC : MGCDayPlannerViewController <CalendarViewControllerNavigation>
@property (nonatomic, weak) id<DayViewControllerDelegate> delegate;

- (void)reloadData;
@end
