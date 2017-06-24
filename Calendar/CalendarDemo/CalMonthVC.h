//
//  CalMonthVC.h
//  Calendar
//
//  Bhavesh Kumbhani on 03/03/17.
//  Copyright © 2017 Bhavesh Kumbhani. All rights reserved.
//

#import "MGCMonthPlannerViewController.h"
#import "MainViewController.h"
#import "MGCCalendarHeaderView.h"

@interface CalMonthVC : MGCMonthPlannerViewController <CalendarViewControllerNavigation>

@property (nonatomic, weak) id<CalendarViewControllerDelegate> delegate;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) MGCDateRange *visibleMonths;
@property (nonatomic) dispatch_queue_t bgQueue;						// dispatch queue for loading events
@property (nonatomic) NSMutableOrderedSet *datesForMonthsToLoad;
@property (nonatomic) NSCache *cachedMonths;
@property (nonatomic) NSSet *visibleCalendars;
@property (nonatomic) NSDateFormatter *dateFormatter;
- (void)reloadData;
@end
