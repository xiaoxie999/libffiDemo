//
//  CallCFunc.h
//  libffiDemo
//
//  Created by xiemy on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallCFunc : NSObject

+ (void)callCFunc:(int)a b:(int)b;
+ (void)callUserDefinedCFuncWith:(int)a b:(int)b c:(int)c;

@end

NS_ASSUME_NONNULL_END
