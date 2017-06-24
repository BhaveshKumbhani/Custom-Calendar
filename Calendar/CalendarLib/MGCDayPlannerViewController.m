//
//  MGCDayPlannerViewController.m
//  Graphical Calendars Library for iOS
//
//  Distributed under the MIT License
//  Get the latest version from here:
//
//	https://github.com/jumartin/Calendar
//
//  Copyright (c) 2014-2015 Bhavesh Kumbhani
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "MGCDayPlannerViewController.h"
#import "MGCDateRange.h"
#import "MGCCalendarHeaderView.h"
#import "Constant.h"
#import "MGCStandardEventView.h"
#import "NSCalendar+MGCAdditions.h"
#import "NSAttributedString+MGCAdditions.h"
#import "GlobalModel.h"
#import "DataModel.h"

@interface MGCDayPlannerViewController ()
{
    MGCStandardEventView *newCell;
}
@property (nonatomic, copy) NSDate *firstVisibleDayForRotation;

@end

@implementation MGCDayPlannerViewController

- (MGCDayPlannerView*)dayPlannerView
{
	return (MGCDayPlannerView*)self.view;
}

- (void)setDayPlannerView:(MGCDayPlannerView*)dayPlannerView
{
	[super setView:dayPlannerView];
	
	if (!dayPlannerView.dataSource)
		dayPlannerView.dataSource = self;
	
	if (!dayPlannerView.delegate)
		dayPlannerView.delegate = self;
}

#pragma mark - UIViewController

- (void)loadView
{
	MGCDayPlannerView *dayPlannerView = [[MGCDayPlannerView alloc]initWithFrame:CGRectZero];
	dayPlannerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	self.dayPlannerView = dayPlannerView;
    self.dayPlannerView.autoresizesSubviews = YES;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (!self.headerView && self.showsWeekHeaderView) {
        self.dayPlannerView.numberOfVisibleDays = 1;
        self.dayPlannerView.dayHeaderHeight = 90;
        self.dayPlannerView.visibleDays.start = [NSDate date];
        [self setupHeaderView];
    }
}

- (void)setupHeaderView{
    self.headerView = [[MGCCalendarHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.dayPlannerView.frame.size.width, self.dayPlannerView.dayHeaderHeight) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init] andDayPlannerView:self.dayPlannerView];
    
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.headerView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if (self.headerView) {
            //force to scroll to a correct position after rotation
            [self.headerView didMoveToSuperview];
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MGCDayPlannerViewDataSource

#pragma mark - Data Reload
- (void)reloadData{
    NSLog(@"Reload **************");
    [self.dayPlannerView reloadAllEvents];
}

#pragma mark - MGCDayPlannerViewDataSource

- (NSInteger)dayPlannerView:(MGCDayPlannerView *)view numberOfEventsOfType:(MGCEventType)type atDate:(NSDate *)date
{    
    return [[[GlobalModel shared] numberOfEventAtDate:date] count];
}

- (MGCEventView*)dayPlannerView:(MGCDayPlannerView*)view viewForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    
    MGCStandardEventView *evCell = [MGCStandardEventView new];
    NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
    if (list.count==0) {
        return evCell;
    }
    DataModel *objSch = [list objectAtIndex:index];
    evCell.font = [UIFont systemFontOfSize:11];
    evCell.title = objSch.title;
    evCell.style = MGCStandardEventViewStylePlain|MGCStandardEventViewStyleSubtitle;
    evCell.style |= (type == MGCAllDayEventType) ?: MGCStandardEventViewStyleBorder;
    evCell.color = [UIColor greenColor];
    
    return evCell;
}

- (MGCDateRange*)dayPlannerView:(MGCDayPlannerView*)view dateRangeForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
    if (list.count==0) {
        return nil;
    }
    DataModel *objSch = [list objectAtIndex:index];
    MGCDateRange *range = [MGCDateRange dateRangeWithStart:objSch.sDate end:objSch.eDate];
    return range;
}

#pragma mark - MGCDayPlannerViewDelegate
- (BOOL)dayPlannerView:(MGCDayPlannerView*)view canCreateNewEventOfType:(MGCEventType)type atDate:(NSDate*)date
{
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    return comps.weekday != 1;
}
- (BOOL)dayPlannerView:(MGCDayPlannerView*)view canMoveEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date toType:(MGCEventType)targetType date:(NSDate*)targetDate
{
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitWeekday fromDate:targetDate];
    return  (comps.weekday != 1 && comps.weekday != 7);
}


- (MGCEventView*)dayPlannerView:(MGCDayPlannerView*)view viewForNewEventOfType:(MGCEventType)type atDate:(NSDate*)date
{
    newCell = [MGCStandardEventView new];
    newCell.title = @"New Schedule";
    newCell.color = [UIColor blueColor];
    return newCell;
}


- (void)dayPlannerView:(MGCDayPlannerView*)view willStartMovingCellForEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date
{
    NSLog(@"willStartMovingCellForEventOfType %@, Type: %lu, Index: %lu", date.description,(unsigned long)type,(unsigned long)index);
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didMoveEventToDate:(NSDate*)date type:(MGCEventType)type
{
    
    NSLog(@"didMoveEventToDate %@, Type: %lu", date.description,(unsigned long)type);
}

- (void)dayPlannerView:(MGCDayPlannerView*)view createNewEventOfType:(MGCEventType)type atDate:(NSDate*)date{
     NSLog(@"createNewEventOfType %@,Type: %lu", date.description,(unsigned long)type);
}

- (void)dayPlannerView:(MGCDayPlannerView*)view didSelectEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date{
     NSLog(@"didSelectEventOfType %@,Type: %lu", date.description,(unsigned long)type);
    
    NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
    if (list.count==0) {
        return;
    }
    DataModel *objSch = [list objectAtIndex:index];
    
}
- (void)dayPlannerView:(MGCDayPlannerView*)view didDeselectEventOfType:(MGCEventType)type atIndex:(NSUInteger)index date:(NSDate*)date {
    NSLog(@"didDeselectEventOfType %@,Type: %lu", date.description,(unsigned long)type);
}

//when the user interacts with the bottom part move the header part
- (void)dayPlannerView:(MGCDayPlannerView*)view didEndScrolling:(MGCDayPlannerScrollType)scrollType
{
    NSLog(@"dayPlannerView didEndScrolling");    
    [self.headerView selectDate:view.visibleDays.start];
}

@end
