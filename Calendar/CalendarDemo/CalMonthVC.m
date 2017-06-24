//
//  CalMonthVC.m
//  Calendar
//
//  Bhavesh Kumbhani on 03/03/17.
//  Copyright © 2017 Bhavesh Kumbhani. All rights reserved.
//

#import "CalMonthVC.h"
#import "MGCStandardEventView.h"
#import "NSCalendar+MGCAdditions.h"
#import "MGCDateRange.h"
#import "NSAttributedString+MGCAdditions.h"
#import "Constant.h"
#import "OSCache.h"
#import "GlobalModel.h"
#import "DataModel.h"

@interface CalMonthVC ()

@end

@implementation CalMonthVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cachedMonths = [[OSCache alloc]init];
    
    self.bgQueue = dispatch_queue_create("MGCMonthPlannerViewController.bgQueue", NULL);
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateStyle = NSDateFormatterNoStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    self.monthPlannerView.calendar = self.calendar;
    self.monthPlannerView.canMoveEvents = NO;
    self.monthPlannerView.canCreateEvents = YES;
    
   // [self.monthPlannerView registerClass:MGCStandardEventView.class forEventCellReuseIdentifier:EventCellReuseIdentifier];

}

#pragma mark - MGCMonthPlannerViewController

//- (void)monthPlannerViewDidScroll:(MGCMonthPlannerView *)view
//{
//    [super monthPlannerViewDidScroll:view];
//    
//    NSDate *date = [self.monthPlannerView dayAtPoint:self.monthPlannerView.center];
//    if (date && [self.delegate respondsToSelector:@selector(calendarViewController:didShowDate:)]) {
//        [self.delegate calendarViewController:self didShowDate:date];
//    }
//}


- (NSAttributedString*)monthPlannerView:(MGCMonthPlannerView *)view attributedStringForDayHeaderAtDate:(NSDate *)date
{
    //return nil;
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [NSDateFormatter new];
    }
    
    dateFormatter.dateFormat = @"d";
    NSString *dayStr = [dateFormatter stringFromDate:date];
    
    NSString *str = dayStr;
    
    if (dayStr.integerValue == 1) {
        dateFormatter.dateFormat = @"MMM d";
        str = [dateFormatter stringFromDate:date];
    }
    
    UIFont *font = [UIFont systemFontOfSize:isiPad ? 15 : 12];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str attributes:@{ NSFontAttributeName: font }];
    
    if ([self.calendar mgc_isDate:date sameDayAsDate:[NSDate date]]) {
        UIFont *boldFont = [UIFont boldSystemFontOfSize:isiPad ? 15 : 12];
        
        MGCCircleMark *mark = [MGCCircleMark new];
        mark.yOffset = boldFont.descender - mark.margin;
        
        [attrStr addAttributes:@{ NSFontAttributeName: boldFont, NSForegroundColorAttributeName: [UIColor whiteColor], MGCCircleMarkAttributeName: mark} range:[str rangeOfString:dayStr]];
        
        [attrStr processCircleMarksInRange:NSMakeRange(0, attrStr.length)];
    }
    
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    para.alignment = NSTextAlignmentRight;
    para.tailIndent = -6;
    
    [attrStr addAttributes:@{ NSParagraphStyleAttributeName: para } range:NSMakeRange(0, attrStr.length)];
    
    return attrStr;
}

#pragma mark - CalendarViewControllerNavigation

- (NSDate*)centerDate
{
    MGCDateRange *visibleRange = [self.monthPlannerView visibleDays];
    if (visibleRange)
    {
        NSUInteger dayCount = [self.calendar components:NSCalendarUnitDay fromDate:visibleRange.start toDate:visibleRange.end options:0].day;
        NSDateComponents *comp = [NSDateComponents new];
        comp.day = dayCount / 2;
        NSDate *centerDate = [self.calendar dateByAddingComponents:comp toDate:visibleRange.start options:0];
        return [self.calendar mgc_startOfWeekForDate:centerDate];
    }
    return [NSDate date];
}

- (void)moveToDate:(NSDate*)date animated:(BOOL)animated
{
    if (!self.monthPlannerView.dateRange || [self.monthPlannerView.dateRange containsDate:date]) {
        [self.monthPlannerView scrollToDate:date alignment:MGCMonthPlannerScrollAlignmentWeekRow animated:animated];
    }
}

- (void)moveToNextPageAnimated:(BOOL)animated
{
    NSDate *date = [self.calendar mgc_nextStartOfMonthForDate:self.monthPlannerView.visibleDays.start];
    [self moveToDate:date animated:animated];
}

- (void)moveToPreviousPageAnimated:(BOOL)animated
{
    NSDate *date = [self.calendar mgc_startOfMonthForDate:self.monthPlannerView.visibleDays.start];
    if ([self.monthPlannerView.visibleDays.start isEqualToDate:date]) {
        NSDateComponents *comps = [NSDateComponents new];
        comps.month = -1;
        date = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }
    [self moveToDate:date animated:animated];
}


#pragma mark - Data Reload
- (void)reloadData{   
   [self.monthPlannerView reloadEvents];
}

#pragma mark - MGCMonthPlannerViewDataSource

- (NSInteger)monthPlannerView:(MGCMonthPlannerView*)view numberOfEventsAtDate:(NSDate*)date
    {
        return [[[GlobalModel shared] numberOfEventAtDate:date] count];
    }
    
- (MGCEventView*)monthPlannerView:(MGCMonthPlannerView*)view cellForEventAtIndex:(NSUInteger)index date:(NSDate*)date
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
        evCell.color = [UIColor greenColor];
        
        return evCell;
    }
    
- (MGCDateRange*)monthPlannerView:(MGCMonthPlannerView*)view dateRangeForEventAtIndex:(NSUInteger)index date:(NSDate*)date
    {      
        
        NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
        if (list.count==0) {
            return nil;
        }
        DataModel *objSch = [list objectAtIndex:index];
        MGCDateRange *range = [MGCDateRange dateRangeWithStart:objSch.sDate end:objSch.eDate];
        return range;
    }
    



- (BOOL)monthPlannerView:(MGCMonthPlannerView*)view canMoveCellForEventAtIndex:(NSUInteger)index date:(NSDate*)date
{
    NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
    if (list.count==0) {
        return NO;
    }
    return YES;
}

- (MGCEventView*)monthPlannerView:(MGCMonthPlannerView*)view cellForNewEventAtDate:(NSDate*)date
{
    
    MGCStandardEventView *evCell = [MGCStandardEventView new];
    evCell.title = @"New Schedule";
    evCell.color =[UIColor greenColor];
    return evCell;
}

#pragma mark - MGCMonthPlannerViewDelegate

- (void)monthPlannerViewDidScroll:(MGCMonthPlannerView *)view
{
    MGCDateRange *visibleMonths = [self visibleMonthsRange];
    
    if (![visibleMonths isEqual:self.visibleMonths]) {
        self.visibleMonths = visibleMonths;
        [self loadEventsIfNeeded];
    }
    NSDate *date = [self.monthPlannerView dayAtPoint:self.monthPlannerView.center];
    if (date && [self.delegate respondsToSelector:@selector(calendarViewController:didShowDate:)]) {
        [self.delegate calendarViewController:self didShowDate:date];
    }
    
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view didSelectEventAtIndex:(NSUInteger)index date:(NSDate *)date
{
    NSArray *list = [[GlobalModel shared] numberOfEventAtDate:date];
    if (list.count==0) {
        return;
    }
    DataModel *objSch = [list objectAtIndex:index];
    
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view didDeselectEventAtIndex:(NSUInteger)index date:(NSDate *)date
{
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view didSelectDayCellAtDate:(NSDate *)date
{
    NSLog(@"selected day at : %@", date);
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view didShowCell:(MGCEventView*)cell forNewEventAtDate:(NSDate*)date
{
     NSLog(@"create new schedule : %@", date);
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view willStartMovingEventAtIndex:(NSUInteger)index date:(NSDate*)date
{
}

- (void)monthPlannerView:(MGCMonthPlannerView*)view didMoveEventAtIndex:(NSUInteger)index date:(NSDate*)dateOld toDate:(NSDate*)dateNew
{
    NSLog(@"monthPlannerView didMoveEventAtIndex: Old:%@ New%@",dateOld, dateNew);
    }

#pragma mark - Properties


- (void)setCalendar:(NSCalendar *)calendar
{
    _calendar = calendar;
    self.dateFormatter.calendar = calendar;
    self.monthPlannerView.calendar = calendar;
}

- (void)setVisibleCalendars:(NSSet*)visibleCalendars
{
    _visibleCalendars = visibleCalendars;
    [self.monthPlannerView reloadEvents];
}

#pragma mark - Events loading

- (NSArray*)eventsAtDate:(NSDate*)date
{
    NSDate *firstOfMonth = [self.calendar mgc_startOfMonthForDate:date];
    NSMutableDictionary *days = [self.cachedMonths objectForKey:firstOfMonth];
    
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(EKEvent *ev, NSDictionary *bindings) {
        return [self.visibleCalendars containsObject:ev.calendar];
    }];
    
    NSArray *events = [[days objectForKey:date]filteredArrayUsingPredicate:pred];
    
    return events;
}

- (EKEvent*)eventAtIndex:(NSUInteger)index date:(NSDate*)date
{
    NSArray *events = [self eventsAtDate:date];
    EKEvent *ev = [events objectAtIndex:index];
    return ev;
}

- (MGCDateRange*)visibleMonthsRange
{
    MGCDateRange *visibleMonthsRange = nil;
    
    MGCDateRange *visibleDaysRange = [self.monthPlannerView visibleDays];
    if (visibleDaysRange) {
        NSDate *start = [self.calendar mgc_startOfMonthForDate:visibleDaysRange.start];
        NSDate *end = [self.calendar mgc_nextStartOfMonthForDate:visibleDaysRange.end];
        visibleMonthsRange = [MGCDateRange dateRangeWithStart:start end:end];
    }
    
    return visibleMonthsRange;
}

// returns an array of all events happening between startDate and endDate, sorted by start date
- (NSArray*)fetchEventsFrom:(NSDate*)startDate to:(NSDate*)endDate calendars:(NSArray*)calendars
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.sTimeInterval >= %lu AND self.sTimeInterval < %lu",
                              [startDate timeIntervalSince1970],
                              [endDate timeIntervalSince1970]];
  
    return [[GlobalModel shared].objectList filteredArrayUsingPredicate:predicate];

}

- (NSDictionary*)allEventsInDateRange:(MGCDateRange*)range
{
    NSArray *events = [self fetchEventsFrom:range.start to:range.end calendars:nil];
    
    NSUInteger numDaysInRange = [range components:NSCalendarUnitDay forCalendar:self.calendar].day;
    NSMutableDictionary *eventsPerDay = [NSMutableDictionary dictionaryWithCapacity:numDaysInRange];
    
    for (DataModel *ev in events)
    {
        NSDate *start = [self.calendar mgc_startOfDayForDate:ev.sDate];
        MGCDateRange *eventRange = [MGCDateRange dateRangeWithStart:start end:ev.eDate];
        [eventRange intersectDateRange:range];
        
        [eventRange enumerateDaysWithCalendar:self.calendar usingBlock:^(NSDate *date, BOOL *stop){
            NSMutableArray *events = [eventsPerDay objectForKey:date];
            if (!events) {
                events = [NSMutableArray array];
                [eventsPerDay setObject:events forKey:date];
            }
            
            [events addObject:ev];
        }];
    }
    
    return eventsPerDay;
}


- (void)bg_loadMonthStartingAtDate:(NSDate*)date
{
    NSDate *end = [self.calendar mgc_nextStartOfMonthForDate:date];
    MGCDateRange *range = [MGCDateRange dateRangeWithStart:date end:end];
    
    NSDictionary *dic = [self allEventsInDateRange:range];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.cachedMonths setObject:dic forKey:date];
        
        
        NSDate *rangeEnd = [self.calendar mgc_nextStartOfMonthForDate:date];
        MGCDateRange *range = [MGCDateRange dateRangeWithStart:date end:rangeEnd];
        [self.monthPlannerView reloadEventsInRange:range];
     
    });
}

- (void)bg_loadOneMonth
{
    __block NSDate *date;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        date = [self.datesForMonthsToLoad firstObject];
        if (date) {
            [self.datesForMonthsToLoad removeObject:date];
        }
        
        if (![self.monthPlannerView.visibleDays intersectsDateRange:self.visibleMonths]) {
            date = nil;
        }
    });
    
    if (date) {
        [self bg_loadMonthStartingAtDate:date];
    }
}

- (void)addMonthToLoadingQueue:(NSDate*)monthStart
{
    if (!self.datesForMonthsToLoad) {
        self.datesForMonthsToLoad = [NSMutableOrderedSet orderedSet];
    }
    
    [self.datesForMonthsToLoad addObject:monthStart];
    
    dispatch_async(self.bgQueue, ^{ [self bg_loadOneMonth]; });
}

- (void)loadEventsIfNeeded
{
    [self.datesForMonthsToLoad removeAllObjects];
    
    MGCDateRange *visibleRange = [self visibleMonthsRange];
    
    NSUInteger months = [visibleRange components:NSCalendarUnitMonth forCalendar:self.calendar].month;
    
    for (int i = 0; i < months; i++)
    {
        NSDateComponents *dc = [NSDateComponents new];
        dc.month = i;
        NSDate *date = [self.calendar dateByAddingComponents:dc toDate:visibleRange.start options:0];
        
        if (![self.cachedMonths objectForKey:date])
            [self addMonthToLoadingQueue:date];
    }
}



@end
