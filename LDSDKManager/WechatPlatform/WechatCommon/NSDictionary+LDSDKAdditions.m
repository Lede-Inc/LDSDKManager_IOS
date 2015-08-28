//
//  NSDictionary+LDSDKAdditions.m
//  LDSDKCommon
//
//  Created by Zhao Maojia on 7/11/15.
//  Copyright (c) 2015 Lede. All rights reserved.
//

#import "NSDictionary+LDSDKAdditions.h"

@implementation NSDictionary (LDSDKAdditions)

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(boolValue)]) {
        return [(id)object boolValue];
    }
    return defaultValue;
}

- (int)intForKey:(NSString *)key defaultValue:(int)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(intValue)]) {
        return [(id)object intValue];
    }
    return defaultValue;
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(integerValue)]) {
        return [(id)object integerValue];
    }
    return defaultValue;
}

- (long)longForKey:(NSString *)key defaultValue:(long)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(longValue)]) {
        return [(id)object longValue];
    }
    return defaultValue;
}

- (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(doubleValue)]) {
        return [(id)object doubleValue];
    }
    return defaultValue;
}

- (float)floatForKey:(NSString *)key defaultValue:(float)defaultValue
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return defaultValue;
    }

    if ([object respondsToSelector:@selector(floatValue)]) {
        return [(id)object floatValue];
    }
    return defaultValue;
}

- (NSString *)stringForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];

    if (object == nil || object == [NSNull null]) {
        return @"";
    }

    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }
    return [NSString stringWithFormat:@"%@", object];
}

- (id)validObjectForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];

    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    NSObject *object = [self objectForKey:key];

    if ([object isKindOfClass:[NSArray class]]) {
        return (NSArray *)object;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)object allValues];
    }
    return nil;
}

- (NSDate *)dateForKey:(NSString *)key
{
    NSString *object = [self objectForKey:key];

    if ([object isKindOfClass:[NSString class]]) {
        static NSDateFormatter *formater = nil;

        if (!formater) {
            formater = [[NSDateFormatter alloc] init];
            [formater setLocale:[NSLocale currentLocale]];
        }

        if (object.length == @"yyyy-MM-dd HH:mm".length) {
            [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
        } else if (object.length == @"yyyy-MM-dd HH:mm:ss".length) {
            [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }

        return [formater dateFromString:object];
    }

    if ([object isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[object integerValue]];
    }
    return nil;
}

@end

@implementation NSMutableDictionary (LDSDKAdditions)

- (void)setValidObject:(id)anObject forKey:(id)aKey
{
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void)setInteger:(NSInteger)value forKey:(id)key
{
    [self setValue:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(id)key
{
    [self setValue:[NSNumber numberWithDouble:value] forKey:key];
}

@end
