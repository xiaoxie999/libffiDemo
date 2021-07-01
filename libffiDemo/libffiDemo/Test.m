//
//  Test.m
//  libffiDemo
//
//  Created by xiemy on 2021/6/30.
//

#import "Test.h"
#import "ffi.h"

@implementation Test

+(void)load {
    
    [self libffiTest:2 and:3];
    
    [self libffiBindTest];
}

int fun(int a, int b) {
    return a + b;
}

+ (void)libffiTest:(int)a and:(int)b {
    ffi_type **argTypes = malloc(sizeof(ffi_type *) * 2);
    argTypes[0] = &ffi_type_sint;
    argTypes[1] = &ffi_type_sint;
    
    ffi_type *retType = &ffi_type_sint;
    
    ffi_cif cif;
    ffi_prep_cif(&cif, FFI_DEFAULT_ABI, 2, retType, argTypes);
    
    void **args = malloc(sizeof(void *) * 2);
    args[0] = &a;
    args[1] = &b;
    int ret;
    
    ffi_call(&cif, (void(*)(void))fun, &ret, args);
    
    NSLog(@"libffi return value: %d", ret);
}

void bind_func(ffi_cif *cif, char **ret, int **args, void *userdata) {
    Test *test = (__bridge Test *)userdata;
    NSLog(@"%@", test);
    
    int value1 = 1;
    int value2 = *args[0];
    int value3 = *args[1];
    
    const char *result = [[NSString stringWithFormat:@"str-%d", (value1 + value2 + value3)] UTF8String];
    *ret = (char *)result;
}

+ (void)libffiBindTest {
    ffi_type **argTypes;
    ffi_type *retTypes;
    
    argTypes = malloc(sizeof(ffi_type *) * 2);
    argTypes[0] = &ffi_type_sint;
    argTypes[1] = &ffi_type_sint;
    
    retTypes = malloc(sizeof(ffi_type *));
    retTypes = &ffi_type_pointer;
    
    ffi_cif *cif = malloc(sizeof(ffi_cif));
    ffi_status status = ffi_prep_cif(cif, FFI_DEFAULT_ABI, 2, retTypes, argTypes);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_cif return %u", status);
        return;
    }
    
    char* (*funcInvoke)(int, int);
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void *)&funcInvoke);
    status = ffi_prep_closure_loc(closure, (void *)cif, (void *)bind_func, (__bridge void *)self, funcInvoke);
    if (status != FFI_OK) {
        NSLog(@"ffi_prep_closure_loc return %u", status);
        return;
    }
    
    char *result = funcInvoke(2, 5);
    NSLog(@"libffi return func value: %@", [NSString stringWithUTF8String:result]);
    ffi_closure_free(closure);
}

@end
