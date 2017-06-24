//
//  DataModel.h
//  Calendar
//
//  Bhavesh Kumbhani on 24/06/17.
//  Copyright © 2017 Bhavesh Kumbhani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

    @property (nonatomic) NSString *title;
    @property (nonatomic) NSString *subTitle;
    @property (nonatomic) NSDate *sDate;
    @property (nonatomic) NSDate *eDate;
    @property (nonatomic) NSString *start;
    @property (nonatomic) NSString *end;
    @property (nonatomic) double sTimeInterval;

@end
