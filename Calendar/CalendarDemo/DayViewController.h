//
//  DayViewController.h
//  Calendar
//
//  Copyright © 2016 Bhavesh Kumbhani. All rights reserved.
//

#import "MGCDayPlannerEKViewController.h"
#import "MainViewController.h"


@protocol DayViewControllerDelegate <MGCDayPlannerEKViewControllerDelegate, CalendarViewControllerDelegate, UIViewControllerTransitioningDelegate>

@end


@interface DayViewController : MGCDayPlannerEKViewController <CalendarViewControllerNavigation>

@property (nonatomic, weak) id<DayViewControllerDelegate> delegate;

@end

