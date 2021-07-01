//
//  HookMethod.h
//  libffiDemo
//
//  Created by xiemy on 2021/6/30.
//

#import <Foundation/Foundation.h>
#import "Util.h"

NS_ASSUME_NONNULL_BEGIN

@interface HookMethod : NSObject

+ (void)hookMethod:(Class)cls Sel:(SEL)sel mode:(JBlockHookMode)mode handleBlock:(id)handleBlock;

@end

NS_ASSUME_NONNULL_END
