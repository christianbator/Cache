//
//  NSKeyedUnarchiver+Safe.h
//  Cache
//
//  Created by Christian Bator on 8/28/16.
//  Copyright © 2016 jcbator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (Safe)

+ (NSObject * _Nullable)safelyUnarchiveObjectAtPath:(NSString * _Nonnull)path;

@end
