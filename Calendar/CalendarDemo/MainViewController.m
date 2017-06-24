//
//  MainViewController.m
//  CalendarDemo - Graphical Calendars Library for iOS
//
//  Copyright (c) 2014-2015 Julien Martin. All rights reserved.
//

#import "MainViewController.h"
//#import "WeekViewController.h"
//#import "MonthViewController.h"
#import "YearViewController.h"
//#import "DayViewController.h"
#import "CalDayVC.h"
#import "CalWeekVC.h"
#import "CalMonthVC.h"
#import "NSCalendar+MGCAdditions.h"
#import "WeekSettingsViewController.h"
#import "MonthSettingsViewController.h"
#import "GlobalModel.h"
#import "DataModel.h"

//typedef enum : NSUInteger
//{
//
//    CalendarViewDayType  = 0,
//    CalendarViewWeekType = 1,
//    CalendarViewMonthType = 2,
//    CalendarViewYearType
//
//} CalendarViewType;


@interface MainViewController ()<YearViewControllerDelegate, WeekViewControllerDelegate, DayViewControllerDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) EKCalendarChooser *calendarChooser;
@property (nonatomic) BOOL firstTimeAppears;

@property (nonatomic) CalDayVC *dayViewController;
@property (nonatomic) CalWeekVC *weekViewController;
@property (nonatomic) CalMonthVC *monthViewController;
@property (nonatomic) YearViewController *yearViewController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barSegmentContiner;
@property (nonatomic) NSDate *selectedDate;
@end


@implementation MainViewController

#pragma mark - UIViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _eventStore = [[EKEventStore alloc]init];
    }
    return self;
}
- (void)reloadData{
    NSLog(@"Reload xxxxxxxxxxxxxxxxx");
    if ([self.dayViewController respondsToSelector:@selector(reloadData)]) {
        [self.dayViewController reloadData];
    }
    if ([self.weekViewController respondsToSelector:@selector(reloadData)]) {
        [self.weekViewController reloadData];
    }
    if ([self.monthViewController respondsToSelector:@selector(reloadData)]) {
        [self.monthViewController reloadData];
    }
    
}
- (IBAction)btnTodayClick:(UIBarButtonItem *)sender {
    [self showToday:sender];
}


- (void)testDataLoad{

    NSMutableArray *testList = [NSMutableArray new];
    
    DataModel *model;
    for (int i =0; i<10; i++) {
        
        model = [DataModel new];
        NSDate *dt = [NSDate date];
        model.title = [NSString stringWithFormat:@"Test Data %i",i];
        model.sDate = [dt dateByAddingHours:1];
        model.eDate = [dt dateByAddingHours:5];
        model.start = [model.sDate stringWithFormat:@"MM/dd/yyyy"];
        model.end = [model.eDate stringWithFormat:@"MM/dd/yyyy"];
        model.sTimeInterval = model.sDate.timeIntervalSince1970;
        [testList addObject:model];
    }
    GlobalModel.shared.objectList = testList;
    
    NSLog(@"Data  Count: %lu",(unsigned long)GlobalModel.shared.objectList.count);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // test data
    [self testDataLoad];
    
    
    
    NSString *calID = [[NSUserDefaults standardUserDefaults]stringForKey:@"calendarIdentifier"];
    self.calendar = [NSCalendar mgc_calendarFromPreferenceString:calID];
    
    NSUInteger firstWeekday = [[NSUserDefaults standardUserDefaults]integerForKey:@"firstDay"];
    if (firstWeekday != 0) {
        self.calendar.firstWeekday = firstWeekday;
    } else {
        [[NSUserDefaults standardUserDefaults]registerDefaults:@{ @"firstDay" : @(self.calendar.firstWeekday) }];
    }
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.calendar = self.calendar;
    
    self.navigationItem.leftBarButtonItem.customView = self.currentDateLabel;
    
	   
    
    self.currentDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    self.currentDateLabel.font = [UIFont systemFontOfSize:13];
    self.currentDateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *itemLable = [[UIBarButtonItem alloc]initWithCustomView:self.currentDateLabel];
    
    UIBarButtonItem *flaxibleSpace1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSMutableArray *segmentItems = [NSMutableArray new];
    
    [segmentItems addObject:@"Day"];
    [segmentItems addObject:@"Week"];
     [segmentItems addObject:@"Month"];
   
    UIBarButtonItem *itemSegment = nil;
    UIBarButtonItem *flaxibleSpace2 = nil;
    
    if (segmentItems.count > 0) {
        CalendarViewController *controller = [self controllerForViewType:segmentItems[0]];
        [self addChildViewController:controller];
        [self.containerView addSubview:controller.view];
        controller.view.frame = self.containerView.bounds;
        [controller didMoveToParentViewController:self];
        
        self.selectedDate = [NSDate date];
        self.calendarViewController = controller;
        self.firstTimeAppears = YES;
        
        
        if (segmentItems.count > 1) {
            self.viewChooser = [[UISegmentedControl alloc] initWithItems:segmentItems];
            self.viewChooser.selectedSegmentIndex = 0;
            [self.viewChooser addTarget:self action:@selector(switchControllers:) forControlEvents:UIControlEventValueChanged];
            itemSegment = [[UIBarButtonItem alloc]initWithCustomView:self.viewChooser];
            flaxibleSpace2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        }
        
    }else{
        self.view.hidden = YES;
    }
    
    UIBarButtonItem *itemToday = [[UIBarButtonItem alloc]initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(btnTodayClick:)];
    UIBarButtonItem *flaxibleSpace3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *itemPrev = [[UIBarButtonItem alloc]initWithTitle:@"<<" style:UIBarButtonItemStylePlain target:self action:@selector(previousPage:)];
    UIBarButtonItem *flaxibleSpace4 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *itemNext = [[UIBarButtonItem alloc]initWithTitle:@">>" style:UIBarButtonItemStylePlain target:self action:@selector(nextPage:)];
    
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.tintColor = [UIColor redColor];
    
    if (itemSegment == nil) {
        toolbar.items = @[itemLable,flaxibleSpace1,itemToday,flaxibleSpace3,itemPrev,flaxibleSpace4,itemNext];
    }else{
        toolbar.items = @[itemLable,flaxibleSpace1,itemSegment,flaxibleSpace2,itemToday,flaxibleSpace3,itemPrev,flaxibleSpace4,itemNext];
    }    
    [self.view addSubview:toolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppears) {
        //NSDate *date = [self.calendar mgc_startOfWeekForDate:[NSDate date]];
        [self.calendarViewController moveToDate:self.selectedDate animated:NO];
        self.firstTimeAppears = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    UINavigationController *nc = (UINavigationController*)[segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"dayPlannerSettingsSegue"]) {
        WeekSettingsViewController *settingsViewController = (WeekSettingsViewController*)nc.topViewController;
        WeekViewController *weekController = (WeekViewController*)self.calendarViewController;
        settingsViewController.weekViewController = weekController;
    }
    else if ([segue.identifier isEqualToString:@"monthPlannerSettingsSegue"]) {
        MonthSettingsViewController *settingsViewController = (MonthSettingsViewController*)nc.topViewController;
        CalMonthVC *monthController = (CalMonthVC*)self.calendarViewController;
        settingsViewController.monthPlannerView = monthController.monthPlannerView;
    }
    
    BOOL doneButton = (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassRegular || self.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClassRegular);
    if (doneButton) {
        nc.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings:)];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UINavigationController *nc = (UINavigationController*)self.presentedViewController;
    if (nc) {
        BOOL hide = (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular);
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissSettings:)];
        nc.topViewController.navigationItem.rightBarButtonItem = hide ? nil : doneButton;
    }
}

#pragma mark - Private

- (CalDayVC*)dayViewController
{
    if (_dayViewController == nil) {
        _dayViewController = [[CalDayVC alloc]init];
        _dayViewController.calendar = self.calendar;
        _dayViewController.showsWeekHeaderView = YES;
        _dayViewController.delegate = self;
        _dayViewController.dayPlannerView.eventCoveringType = MGCDayPlannerCoveringTypeComplex;
    }
    return _dayViewController;
}

- (CalWeekVC*)weekViewController
{
    if (_weekViewController == nil) {
        _weekViewController = [[CalWeekVC alloc]init];
        //_weekViewController.showsWeekHeaderView = YES;
        _weekViewController.calendar = self.calendar;
        _weekViewController.delegate = self;
    }
    return _weekViewController;
}

- (CalMonthVC*)monthViewController
{
    if (_monthViewController == nil) {
        _monthViewController = [[CalMonthVC alloc]init];
        _monthViewController.calendar = self.calendar;
        _monthViewController.delegate = self;
    }
    return _monthViewController;
}

- (YearViewController*)yearViewController
{
    if (_yearViewController == nil) {
        _yearViewController = [[YearViewController alloc]init];
        _yearViewController.calendar = self.calendar;
        _yearViewController.delegate = self;
    }
    return _yearViewController;
}

- (CalendarViewController*)controllerForViewType:(NSString*)type
{
    
    if ([type isEqualToString:@"Day"]) {
        return self.dayViewController;
    }else if ([type isEqualToString:@"Week"]) {
        return self.weekViewController;
    }else if ([type isEqualToString:@"Month"]) {
        return self.monthViewController;
    }
    
    //    switch (type)
    //    {
    //        case CalendarViewDayType:  return self.dayViewController;
    //        case CalendarViewWeekType:  return self.weekViewController;
    //        case CalendarViewMonthType: return self.monthViewController;
    //        case CalendarViewYearType:  return self.yearViewController;
    //    }
    return nil;
}

-(void)moveToNewController:(CalendarViewController*)newController atDate:(NSDate*)date
{
    if (self.isAnimating) {
        NSLog(@"isAnimating");
        return;
    }
    self.isAnimating = YES;
    if (date == nil) {
        date = NSDate.date;
    }
    
    @try {
        NSLog(@"@Try In");
        self.viewChooser.enabled = NO;
        [self.calendarViewController willMoveToParentViewController:nil];
        [self addChildViewController:newController];
        
        [self transitionFromViewController:self.calendarViewController toViewController:newController duration:.5 options:UIViewAnimationOptionShowHideTransitionViews animations:^
         {
             newController.view.frame = self.containerView.bounds;
             newController.view.hidden = YES;
         } completion:^(BOOL finished)
         {
             
             [self.calendarViewController removeFromParentViewController];
             [newController didMoveToParentViewController:self];
             self.calendarViewController = newController;
             [newController moveToDate:date animated:NO];
             newController.view.hidden = NO;
             self.isAnimating = NO;
             [self.calendarViewController moveToDate:self.selectedDate animated:NO];
             self.viewChooser.enabled = YES;
         }];
        
    } @catch (NSException *exception) {
        NSLog(@"@exception %@",exception.description);
    } @finally {
        NSLog(@"@finally");
    }
    
}

- (void)moveToDate{
    
}

#pragma mark - Actions

-(IBAction)switchControllers:(UISegmentedControl*)sender
{
    NSString *title = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    NSDate *date = [self.calendarViewController centerDate];
    CalendarViewController *controller = [self controllerForViewType:title];
    [self moveToNewController:controller atDate:date];
}

- (IBAction)showToday:(id)sender
{
    
    [self.calendarViewController moveToDate:[NSDate date] animated:YES];
}

- (IBAction)nextPage:(id)sender
{
    [self.calendarViewController moveToNextPageAnimated:YES];
}

- (IBAction)previousPage:(id)sender
{
    [self.calendarViewController moveToPreviousPageAnimated:YES];
}

- (IBAction)showCalendars:(id)sender
{
    if ([self.calendarViewController respondsToSelector:@selector(visibleCalendars)]) {
        self.calendarChooser = [[EKCalendarChooser alloc]initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple displayStyle:EKCalendarChooserDisplayAllCalendars eventStore:self.eventStore];
        self.calendarChooser.delegate = self;
        self.calendarChooser.showsDoneButton = YES;
        self.calendarChooser.selectedCalendars = self.calendarViewController.visibleCalendars;
    }
    
    if (self.calendarChooser) {
        UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:self.calendarChooser];
        self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(calendarChooserStartEdit)];
        nc.modalPresentationStyle = UIModalPresentationPopover;
        
        [self showDetailViewController:nc sender:self];
        
        UIPopoverPresentationController *popController = nc.popoverPresentationController;
        popController.barButtonItem = (UIBarButtonItem*)sender;
    }
}

- (IBAction)showSettings:(id)sender
{
    if ([self.calendarViewController isKindOfClass:WeekViewController.class]) {
        [self performSegueWithIdentifier:@"dayPlannerSettingsSegue" sender:nil];
    }
    else if ([self.calendarViewController isKindOfClass:CalMonthVC.class]) {
        [self performSegueWithIdentifier:@"monthPlannerSettingsSegue" sender:nil];
    }
}

- (void)dismissSettings:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserStartEdit
{
    self.calendarChooser.editing = YES;
    self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(calendarChooserEndEdit)];
}

- (void)calendarChooserEndEdit
{
    self.calendarChooser.editing = NO;
    self.calendarChooser.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(calendarChooserStartEdit)];
}

#pragma mark - YearViewControllerDelegate

- (void)yearViewController:(YearViewController*)controller didSelectMonthAtDate:(NSDate*)date
{
    //CalendarViewController *controllerNew = [self controllerForViewType:CalendarViewMonthType];
    //[self moveToNewController:controllerNew atDate:date];
    //self.viewChooser.selectedSegmentIndex = CalendarViewMonthType;
}

#pragma mark - CalendarViewControllerDelegate

- (void)calendarViewController:(CalendarViewController*)controller didShowDate:(NSDate*)date
{
    if (controller.class == YearViewController.class)
        [self.dateFormatter setDateFormat:@"yyyy"];
    else
        [self.dateFormatter setDateFormat:@"MMM yyyy"];
    
    self.selectedDate = date;
    NSString *str = [self.dateFormatter stringFromDate:date];
    self.currentDateLabel.text = str;
    
}

- (void)calendarViewController:(CalendarViewController*)controller didSelectEvent:(EKEvent*)event
{
    NSLog(@"calendarViewController:didSelectEvent");
}

#pragma mark - MGCDayPlannerEKViewControllerDelegate

- (UINavigationController*)navigationControllerForEKEventViewController
{
    //    if (!isiPad) {
    //        return self.navigationController;
    //    }
    return nil;
}


#pragma mark - EKCalendarChooserDelegate

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser*)calendarChooser
{
    if ([self.calendarViewController respondsToSelector:@selector(setVisibleCalendars:)]) {
        self.calendarViewController.visibleCalendars = calendarChooser.selectedCalendars;
    }
}

- (void)calendarChooserDidFinish:(EKCalendarChooser*)calendarChooser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
