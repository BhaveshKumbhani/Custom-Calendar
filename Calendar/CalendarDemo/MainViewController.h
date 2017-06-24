//
//  MainViewController.h
//  CalendarDemo - Graphical Calendars Library for iOS
//
//  Copyright (c) 2014-2015 Julien Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>
#import "NSDate+Utilities.h"

@protocol CalendarViewControllerNavigation <NSObject>

@property (nonatomic, readonly) NSDate* centerDate;

- (void)moveToDate:(NSDate*)date animated:(BOOL)animated;
- (void)moveToNextPageAnimated:(BOOL)animated;
- (void)moveToPreviousPageAnimated:(BOOL)animated;

@optional

@property (nonatomic) NSSet* visibleCalendars;

@end


typedef  UIViewController<CalendarViewControllerNavigation> CalendarViewController;


@protocol CalendarViewControllerDelegate <NSObject>

@optional

- (void)calendarViewController:(CalendarViewController*)controller didShowDate:(NSDate*)date;
- (void)calendarViewController:(CalendarViewController*)controller didSelectEvent:(EKEvent*)event;

@end



@interface MainViewController : UIViewController<CalendarViewControllerDelegate, EKCalendarChooserDelegate>

@property (nonatomic) CalendarViewController* calendarViewController;

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic) UILabel *currentDateLabel;
@property (nonatomic, strong) UISegmentedControl *viewChooser;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) EKEventStore *eventStore;
- (void)reloadData;
@end
