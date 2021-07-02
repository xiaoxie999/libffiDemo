//
//  CallOCFunc.m
//  libffiDemo
//
//  Created by xiemy on 2021/7/2.
//

#import "CallOCFunc.h"
#import "ffi.h"
#import <objc/runtime.h>
#import "Util.h"

@implementation CallOCFunc

+ (float)minus:(float)a b:(float)b c:(int)c {
    float minus = a - b - c;
    return minus;
}

+ (void)libffiCallOCFunc {
    
    SEL selector = @selector(minus:b:c:);
    Method method = class_getClassMethod(CallOCFunc.class, selector);
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
    
    IMP originIMP = method_getImplementation(method);
    
    float a = 12.0;
    float b = 3.0;
    int c = 2;
    void *args[] = {(__bridge void *)(self), selector, &a, &b, &c};
    
    float retValue;
    ffi_call(cif, originIMP, &retValue, args);
    
    NSLog(@"libffi call oc func, retValue: %f", retValue);
}

@end
