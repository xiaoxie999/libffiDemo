//
//  Util.m
//  libffiDemo
//
//  Created by xiemy on 2021/7/1.
//

#import "Util.h"

@implementation Util

NSMethodSignature * SignatureForBlock(id block) {
    struct JBlockLiteral *blockRef = (__bridge struct JBlockLiteral *)block;
    
    if (!(blockRef->flags & JBLOCK_HAS_SIGNATURE)) {
        return  nil;
    }
    
    void *desc = blockRef->descriptor;
    desc += sizeof(struct JBlock_descriptor_1);
    if (blockRef->flags & JBLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct JBlock_descriptor_2);
    }
    
    struct JBlock_descriptor_3 *desc3 = (struct JBlock_descriptor_3 *)desc;
    const char *signature = desc3->signature;
    
    if (signature) {
        return [NSMethodSignature signatureWithObjCTypes:signature];
    }
    
    return nil;
}

void invokeHandleBlock(id handleBlock, void **args, BOOL isBlock) {
    NSMethodSignature *signature = SignatureForBlock(handleBlock);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    int offset = isBlock ? 1 : 2;
    for (int i = 0; i < signature.numberOfArguments - 1; i++) {
        [invocation setArgument:args[i + offset] atIndex:i + 1];
    }
    [invocation invokeWithTarget:handleBlock];
}

void invokeOriginalBlockOrMethod(ffi_cif *cif, void *ret, void **args, void *invoke) {
    if (invoke) {
        ffi_call(cif, invoke, ret, args);
    }
}

+ (ffi_type *)_ffi_typeForTypeEncoding:(const char *)encoding {
    if (!strcmp(encoding, "c")) {
        return &ffi_type_schar;
    }
    else if (!strcmp(encoding, "i")) {
        return &ffi_type_sint;
    }
    else if (!strcmp(encoding, "@")) {
        return &ffi_type_pointer;
    }else {
        return &ffi_type_pointer;
    }
}

@end
