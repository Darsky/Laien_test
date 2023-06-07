//
//  DateModel.h
//  oc_teacher_phone
//
//  Created by Darsky on 2023/6/7.
//  Copyright © 2023 朱伟铭. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateModel : NSObject

@property (nonatomic, assign) NSInteger dateId;
@property (nonatomic, strong) NSMutableArray *recordsArray;

@end

NS_ASSUME_NONNULL_END
