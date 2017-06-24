//
//  GlobalModel.h
//  Aviation
//
//  Created  by BhaveshKumbhani on 11/01/17.
//  Copyright (c) 2017 Aviation, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GlobalModel : NSObject
{
    
}
@property (nonatomic, strong) NSMutableArray *objectList;
    
+ (GlobalModel*)shared;
- (NSArray*)numberOfEventAtDate:(NSDate*)date;
@end
