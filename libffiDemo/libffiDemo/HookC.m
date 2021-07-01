//
//  HookC.m
//  libffiDemo
//
//  Created by xiemy on 2021/7/1.
//

#import "HookC.h"
#import "ffi.h"

int cFunc(int a, int b) {
    NSLog(@"c函数执行");
    return a * b;
}

@implementation HookC

/// 动态调用c函数
+ (void)callCFunc:(int)a b:(int)b {
    
    // 获取c函数指针
    void *funcPtr = &cFunc;
    int argCount = 2;
    
    ffi_type **argTypes = alloca(sizeof(ffi_type *) * argCount);
    argTypes[0] = &ffi_type_sint;
    argTypes[1] = &ffi_type_sint;
    ffi_type *retType = &ffi_type_sint;
    
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, argCount, retType, argTypes);
    if (status != FFI_OK) {
        return;
    }
    
    // 保存函数返回值
    void *retPtr = NULL;
    if (retType -> size) {
        retPtr = alloca(retType -> size);
    }
    
    // 调用函数
    void **args = malloc(sizeof(void *) * 2);
    args[0] = &a;
    args[1] = &b;
    ffi_call(cif, funcPtr, retPtr, args);
    
    // 获取返回值
    int retValue = *(int *)retPtr;
    NSLog(@"libffi 执行函数: %d", retValue);
}

/// 动态定义c函数
+ (void)callUserDefinedCFuncWith:(int)a b:(int)b c:(int)c {
    
    /**
     自定义函数：
     int func(int a, int b, int c) {
        return a * b + c;
     }
     */
    // 自定义函数定义：int (*userDefineFunc)(int a, int b, int c)
    int argCount = 3;
    
    ffi_type **argTypes = alloca(sizeof(ffi_type *) * argCount);
    argTypes[0] = &ffi_type_sint;
    argTypes[1] = &ffi_type_sint;
    argTypes[2] = &ffi_type_sint;
    ffi_type *retType = &ffi_type_sint;
    
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, argCount, retType, argTypes);
    if (status != FFI_OK) {
        return;
    }
    
    // 定义函数
    int (*userDefineFunc)(int, int, int);
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&userDefineFunc);
    status = ffi_prep_closure_loc(closure, (void *)cif, (void *)invokeFunc, NULL, userDefineFunc);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure_loc return %u", status);
        return;
    }
    
    // 调用函数
    int result = userDefineFunc(a, b, c);
    NSLog(@"libffi call userDefined func value: %d", result);
    ffi_closure_free(closure);
}

void invokeFunc(ffi_cif *cif, int *ret, void **args, void *userdata) {
    
    // 获取传参
    int a = *((int *)args[0]);
    int b = *((int *)args[1]);
    int c = *((int *)args[2]);
    
    NSLog(@"参数: %d, %d, %d", a, b, c);
    
    // 函数体逻辑实现
    int result = (a * b + c);
    *ret = result;
}

@end
