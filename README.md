# Custom-Calendar
Display own events in app, without reflect native calendar in IOS. Ref. https://stackoverflow.com/questions/42435753/want-to-display-own-event-schedule-on-calendar-without-reflect-in-native-calenda?noredirect=1#comment76081230_42435753


Event provider, subclass one of MGCDayPlannerViewController or MGCMonthPlannerViewController and implement the data source protocol methods.

Custom event cell, subclass MGCEventView or MGCStandardEventView and register the class with the day / month planner view.

Reference from http://cocoadocs.org/docsets/CalendarLib/2.0/
