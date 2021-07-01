//
//  HookMethod.m
//  libffiDemo
//
//  Created by xiemy on 2021/6/30.
//

#import "HookMethod.h"
#import <objc/runtime.h>

@implementation HookMethod

/// 参考 [https://juejin.cn/post/6844904177609490440]
+ (void)hookMethod:(Class)cls Sel:(SEL)sel mode:(JBlockHookMode)mode handleBlock:(id)handleBlock {
    
    // 获取方法签名
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) {
        return;
    }
    
    const char *methodTypeEncoding = method_getTypeEncoding(method);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:methodTypeEncoding];
    NSUInteger argumentsNum = signature.numberOfArguments;
    
    // 设置参数
    ffi_type **argTypes = malloc(sizeof(ffi_type *) * argumentsNum);
    argTypes[0] = &ffi_type_pointer;  // 方法第一个参数为self
    argTypes[1] = &ffi_type_pointer;  // 方法第二个参数为SEL
    for (int i = 2; i < argumentsNum; i++) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        argTypes[i] = [Util _ffi_typeForTypeEncoding:argType];
    }
    ffi_type *retType = [Util _ffi_typeForTypeEncoding:signature.methodReturnType];
    
    // 设置cif模板
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, (int)argumentsNum, retType, argTypes);
    if (status != FFI_OK) {
        return;
    }
    
    // 方法绑定
    void *methodInvoke;
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), &methodInvoke);
    
    IMP originIMP = method_getImplementation(method);
    IMP replaceIMP = methodInvoke;
    
    NSDictionary *params = @{@"mode": @(mode), @"handleBlock": handleBlock, @"originInvoke": [NSValue valueWithPointer:originIMP]};
    status = ffi_prep_closure_loc(closure, cif, methodInvokeFunc, (__bridge_retained void *)params, methodInvoke);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure_loc return %u", status);
        return;
    }
    
    if (!class_addMethod(cls, sel, replaceIMP, methodTypeEncoding)) {
        class_replaceMethod(cls, sel, replaceIMP, methodTypeEncoding);
    }
}

//void (*fun)(ffi_cif*,void*,void**,void*)
void methodInvokeFunc(ffi_cif *cif, void *ret, void **args, void *userdata) {
    NSDictionary *params = (__bridge_transfer NSDictionary*)userdata;
    
    JBlockHookMode mode = (JBlockHookMode)[params[@"mode"] intValue];
    id handleBlock = params[@"handleBlock"];
    IMP originIMP = [(NSValue *)(params[@"originInvoke"]) pointerValue];
    
    switch (mode) {
        case JBlockHookModeBefore:
        {
            invokeHandleBlock(handleBlock, args, NO);
            invokeOriginalBlockOrMethod(cif, ret, args, originIMP);
        }
            break;
        case JBlockHookModeInstead:
        {
            invokeHandleBlock(handleBlock, args, NO);
        }
            break;
        case JBlockHookModeAfter:
        {
            invokeOriginalBlockOrMethod(cif, ret, args, originIMP);
            invokeHandleBlock(handleBlock, args, NO);
        }
            break;
        default:
            break;
    }
}

@end
