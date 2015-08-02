//
//  Sickness.h
//  demo
//
//  Created by xdtc on 15/8/2.
//  Copyright (c) 2015年 xdtc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Symptom;

@interface Sickness : NSManagedObject

@property (nonatomic, retain) NSString * sicknessName;
@property (nonatomic, retain) NSNumber * sicknessID;
@property (nonatomic, retain) NSSet *symptoms;
@end

@interface Sickness (CoreDataGeneratedAccessors)

- (void)addSymptomsObject:(Symptom *)value;
- (void)removeSymptomsObject:(Symptom *)value;
- (void)addSymptoms:(NSSet *)values;
- (void)removeSymptoms:(NSSet *)values;

@end
