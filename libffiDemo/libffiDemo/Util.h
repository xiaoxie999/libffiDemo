//
//  Util.h
//  libffiDemo
//
//  Created by xiemy on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "Header.h"
#import "ffi.h"

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject

NSMethodSignature * SignatureForBlock(id block);
void invokeHandleBlock(id handleBlock, void *_Nullable* _Nullable args, BOOL isBlock);
void invokeOriginalBlockOrMethod(ffi_cif *cif, void *ret, void *_Nullable* _Nullable args, void *invoke);

+ (ffi_type *)_ffi_typeForTypeEncoding:(const char *)encoding;

@end

NS_ASSUME_NONNULL_END
