//
//  ViewController.m
//  libffiDemo
//
//  Created by xiemy on 2021/6/30.
//

#import "ViewController.h"
#import "HookBlock.h"
#import "HookMethod.h"
#import "HookC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testHookBlock];
    [self testHookMethod];
    [self testHookC];
}

- (void)testHookBlock {
    NSString* (^block)(int, int) = ^(int a, int b) {
        NSString *ret = [NSString stringWithFormat:@"block执行: %d", a + b];
        NSLog(@"%@", ret);
        return ret;
    };
    
    [HookBlock hookBlock:block mode:JBlockHookModeBefore handleBlock:^(int a, int b) {
        NSLog(@"%@", [NSString stringWithFormat:@"hook block执行: %d %d", a, b]);
    }];
    
    block(2, 3);
}

- (void)testHookMethod {
    
    [HookMethod hookMethod:self.class Sel:@selector(sum:and:) mode:JBlockHookModeBefore handleBlock:^(int a, int b) {
        NSLog(@"hook method call: %d, %d", a, b);
    }];
    
    [self sum:10 and:20];
}

- (void)testHookC {
    
    [HookC callCFunc:10 b:2];
    [HookC callUserDefinedCFuncWith:3 b:2 c:1];
}

- (IBAction)run:(UIButton *)sender {
    
}

- (int)sum:(int)a and:(int)b
{
    NSLog(@"执行sum方法: %d, %d", a, b);
    return a + b;
}

@end
