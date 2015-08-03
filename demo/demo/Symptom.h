//
//  Symptom.h
//  demo
//
//  Created by xdtc on 15/8/3.
//  Copyright (c) 2015年 xdtc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sickness;

@interface Symptom : NSManagedObject

@property (nonatomic, retain) NSNumber * isMainSymptom;
@property (nonatomic, retain) NSNumber * symptomID;
@property (nonatomic, retain) NSString * symptomName;
@property (nonatomic, retain) Sickness *sickness;

@end
