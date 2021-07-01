//
//  HookBlock.m
//  libffiDemo
//
//  Created by xiemy on 2021/6/30.
//

#import "HookBlock.h"

@implementation HookBlock

/// 参考 [https://juejin.cn/post/6844904177609490440]
+ (void)hookBlock:(id)targetBlock mode:(JBlockHookMode)mode handleBlock:(id)handleBlock {
    struct JBlockLiteral *blockRef = (__bridge struct JBlockLiteral*)targetBlock;
    void *originalInvoke = blockRef->invoke;
    
    // 获取block签名
    NSMethodSignature *signature = SignatureForBlock(targetBlock);
    NSUInteger arguments = signature.numberOfArguments;
    
    // 设置参数
    ffi_type **argTypes = malloc(sizeof(ffi_type *) * arguments);
    argTypes[0] = &ffi_type_pointer; // 第一个参数为block本身
    for (int i = 1; i < arguments; i++) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        argTypes[i] = [Util _ffi_typeForTypeEncoding:argType];
    }
    
    // 设置返回值类型
    const char *retTypeEncoding = signature.methodReturnType;
    ffi_type *retType = [Util _ffi_typeForTypeEncoding:retTypeEncoding];
    
    // 设置cif模板
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, (int)arguments, retType, argTypes);
    if (status != FFI_OK) {
        return;
    }
    
    // 方法绑定
    void *newInvoke;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), &newInvoke);
    NSDictionary *params = @{@"mode": @(mode), @"handleBlock": handleBlock, @"originInvoke": [NSValue valueWithPointer:originalInvoke]};
//    StoreData *storeData = [[StoreData alloc] init];
//    storeData.mode = mode;
//    storeData.handleBlock = handleBlock;
//    storeData.invokeFunc = originalInvoke;
    status = ffi_prep_closure_loc(closure, cif, newInvokeMethod, (__bridge_retained void *)params, newInvoke);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure_loc return %u", status);
        return;
    }
    blockRef->invoke = newInvoke;
}

void newInvokeMethod(ffi_cif *cif, void *ret, void **args, void *userdata) {
    
    NSDictionary *params = (__bridge_transfer NSDictionary*)userdata;
    
    JBlockHookMode mode = (JBlockHookMode)[params[@"mode"] intValue];
    id handleBlock = params[@"handleBlock"];
    void *invoke = [(NSValue *)(params[@"originInvoke"]) pointerValue];
    
//    StoreData *storeData = (__bridge_transfer id)userdata;
//    JBlockHookMode mode = storeData.mode;
//    id handleBlock = storeData.handleBlock;
////    void *invoke = (__bridge void *)(params[@"originInvoke"]);
//    void *invoke = storeData.invokeFunc;
    
    switch (mode) {
        case JBlockHookModeBefore:
        {
            invokeHandleBlock(handleBlock, args, YES);
            invokeOriginalBlockOrMethod(cif, ret, args, invoke);
        }
            break;
        case JBlockHookModeInstead:
        {
            invokeHandleBlock(handleBlock, args, YES);
        }
            break;
        case JBlockHookModeAfter:
        {
            invokeOriginalBlockOrMethod(cif, ret, args, invoke);
            invokeHandleBlock(handleBlock, args, YES);
        }
            break;
        default:
            break;
    }
}

@end
