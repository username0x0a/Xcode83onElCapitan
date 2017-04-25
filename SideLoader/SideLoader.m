//
//  SideLoader.m
//  SideLoader
//
//  Created by Michi on 24/04/2017.
//  Copyright © 2017 Michi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <dlfcn.h>
#import <stdio.h>
#import <objc/runtime.h>

#import "SideLoader.h"

void __attribute((constructor))init()
{
#ifdef DEBUG
	NSLog(@"[XXXXXXXXXXXXXX] Sideloader init");
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

	Class c = object_getClass([NSTimer class]);

	// scheduled

	SEL sel = @selector(scheduledTimerWithTimeInterval:repeats:block:);

	Method cm = class_getClassMethod(c, sel);

	if (cm == NULL) {

		Method rm = class_getClassMethod(c, @selector(repl_scheduledTimerWithTimeInterval:repeats:block:));
		IMP imp = method_getImplementation(rm);
		const char *types = method_getTypeEncoding(rm);

		class_addMethod(c, sel, imp, types);
	}

	// regular

	sel = @selector(timerWithTimeInterval:repeats:block:);

	cm = class_getClassMethod(c, sel);

	if (cm == NULL) {

		Method rm = class_getClassMethod(c, @selector(repl_timerWithTimeInterval:repeats:block:));
		IMP imp = method_getImplementation(rm);
		const char *types = method_getTypeEncoding(rm);

		class_addMethod(c, sel, imp, types);
	}

#pragma clang diagnostic pop
}

@implementation NSTimer (Blocks)

+ (NSTimer *)repl_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
	repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull))block
{
    void (^cblock)(NSTimer *) = [block copy];
    id ret = [self scheduledTimerWithTimeInterval:interval target:self
		selector:@selector(sideload_ExecuteSimpleBlock:) userInfo:cblock repeats:repeats];
    return ret;
}

+(id)repl_timerWithTimeInterval:(NSTimeInterval)interval
	repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull))block
{
    void (^cblock)(NSTimer *) = [block copy];
    id ret = [self timerWithTimeInterval:interval target:self
		selector:@selector(sideload_ExecuteSimpleBlock:) userInfo:cblock repeats:repeats];
    return ret;
}

+(void)sideload_ExecuteSimpleBlock:(NSTimer *)inTimer;
{
    if([inTimer userInfo])
    {
        void (^block)(NSTimer *) = (void (^)())[inTimer userInfo];
        block(inTimer);
    }
}

@end


@implementation SideLoader

@end
