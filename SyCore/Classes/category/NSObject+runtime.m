//
//  NSObject+runtime.m
//  runtime
//
//  Created by 肖志强 on 2020/10/22.
//

#import "NSObject+runtime.h"
#import <objc/runtime.h>

@implementation NSObject (runtime)

+ (void)swizzleClassMethod: (Class)class originSelector: (SEL)originSelector otherSelector: (SEL)otherSelector {
    Method otherMethod = class_getClassMethod(class, otherSelector);
    Method originMethod = class_getClassMethod(class, originSelector);
    method_exchangeImplementations(otherMethod, originMethod);
}

+ (void)swizzleInstanceMethod: (Class)class originSelector: (SEL)originSelector otherSelector: (SEL)otherSelector {
    Method otherMethod = class_getInstanceMethod(class, otherSelector);
    Method originMethod = class_getInstanceMethod(class, originSelector);
    method_exchangeImplementations(otherMethod, originMethod);
}

@end

@implementation NSArray (runtime)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayI") originSelector:@selector(objectAtIndex:) otherSelector:@selector(runtime_objectAtIndex:)];
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayI") originSelector:@selector(objectAtIndexedSubscript:) otherSelector:@selector(runtime_objectAtIndexedSubscript:)];
    });
}

- (id)runtime_objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx < self.count) {
        return [self runtime_objectAtIndexedSubscript:idx];
    }else {
        NSAssert(NO, @"数组越界。。。。。。。");
        return nil;
    }
}

- (id)runtime_objectAtIndex: (NSInteger)index {
    if (index < self.count) {
        return [self runtime_objectAtIndex:index];
    }else {
        NSAssert(NO, @"数组越界。。。。。。。");
        return nil;
    }
}

@end

@implementation NSMutableArray (runtime)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(insertObject:atIndex:) otherSelector:@selector(runtime_insertObject:atIndex:)];
        [self swizzleInstanceMethod:NSClassFromString(@"__NSArrayM") originSelector:@selector(objectAtIndex:) otherSelector:@selector(runtime_objectAtIndex:)];
    });
}

- (void)runtime_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject != nil && index<=self.count) {
        [self runtime_insertObject:anObject atIndex:index];
    }else {
        NSAssert(NO, @"可变数组越界。。。。。。。");
    }
}

- (id)runtime_objectAtIndex: (NSInteger)index {
    if (index < self.count) {
        return [self runtime_objectAtIndex:index];
    }else {
        NSAssert(NO, @"数组越界。。。。。。。");
        return nil;
    }
}

@end

@implementation NSDictionary (runtime)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSPlaceholderDictionary") originSelector:@selector(initWithObjects:forKeys:count:) otherSelector:@selector(runtime_initWithObjects:forKeys:count:)];
    });
}

- (instancetype)runtime_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    for (int i=0; i<cnt; i++) {
        if (objects[i] == nil) {
//            [NHCallStackSymbols callStackSymbols:self andObjectValue:[NSString stringWithFormat:@"NSDictionary value: key:"]];
            return nil;
        }
    }
    return [self runtime_initWithObjects:objects forKeys:keys count:cnt];
}

@end

@implementation NSMutableDictionary (runtime)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:NSClassFromString(@"__NSDictionaryM") originSelector:@selector(setObject:forKey:) otherSelector:@selector(runtime_setObject:forKey:)];
    });
}

- (void)runtime_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject!=nil) {
        [self runtime_setObject:anObject forKey:aKey];
    } else {
        NSAssert(NO, @"设置了字典的value为nil");
    }
}


@end

