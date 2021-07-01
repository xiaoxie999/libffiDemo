//
//  Header.h
//  libffiDemo
//
//  Created by xiemy on 2021/7/1.
//

#ifndef Header_h
#define Header_h

typedef enum : int {
    JBlockHookModeBefore,
    JBlockHookModeInstead,
    JBlockHookModeAfter,
} JBlockHookMode;

enum {
    JBLOCK_DEALLOCATING =      (0x0001),  // runtime
    JBLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    JBLOCK_NEEDS_FREE =        (1 << 24), // runtime
    JBLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    JBLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    JBLOCK_IS_GC =             (1 << 27), // runtime
    JBLOCK_IS_GLOBAL =         (1 << 28), // compiler
    JBLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    JBLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    JBLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

struct JBlock_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};
 
struct JBlock_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};
 
struct JBlock_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};

// 定义函数别名
typedef void (*JBlockInvokeFunction)(void *, ...);

// 定义block别名
typedef NSString* (^JOriginBlock)(int, int);
typedef void (^JHandleBlock)(int, int);

struct JBlockLiteral {
    void *isa;
    int flags;
    int reserved;
//    void (*invoke)(void *, ...);
    JBlockInvokeFunction invoke;
    struct JBlock_descriptor_1 *descriptor;
};

#endif /* Header_h */
