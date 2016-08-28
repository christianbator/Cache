//
//  NSKeyedUnarchiver+Safe.m
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

#import "NSKeyedUnarchiver+Safe.h"

@implementation NSKeyedUnarchiver (Safe)

+ (NSObject * _Nullable)safelyUnarchiveObjectAtPath:(NSString * _Nonnull)path {
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception) {
        NSLog(@"Exeption unarchiving object at path %@: %@", path, exception);
        return nil;
    }
}

@end
