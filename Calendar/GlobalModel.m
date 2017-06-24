//
//  GlobalModel.m
//  Aviation
//
//  Created  by BhaveshKumbhani on 11/01/17.
//  Copyright (c) 2017 Aviation, LLC. All rights reserved.
//

#import "GlobalModel.h"
#import "DataModel.h"

@implementation GlobalModel

+ (GlobalModel*)shared{
   static GlobalModel *objGM;
    if (objGM==nil) {
        objGM=[[[self class] alloc]init];
    }
    return objGM;
}
- (NSArray*)numberOfEventAtDate:(NSDate*)date{
    if (self.objectList.count>0) {
        NSString *current = [self stringWithFormat:@"MM/dd/yyyy" Date:date];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.start = %@", current];
        NSArray *tmp = [self.objectList filteredArrayUsingPredicate:predicate];
        return tmp != nil ? tmp : @[];
    }else{
        return @[];
    }
}
- (NSString *) stringWithFormat: (NSString *) format Date:(NSDate*)date
    {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setTimeZone: [NSTimeZone localTimeZone]];
        formatter.dateFormat = format;
        return [formatter stringFromDate:date];
    }
    

@end
