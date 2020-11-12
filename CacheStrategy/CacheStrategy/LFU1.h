//
//  LFU1.h
//  CacheStrategy
//
//  Created by stone on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFU1 : NSObject

- (instancetype)initWithCapacity:(NSInteger)capacity;

- (void)setObject:(NSString *)value forKey:(NSString *)key count:(int)count;

- (NSString *)objectForKey:(NSString *)key;

- (NSString *)removeObjectForKey:(NSString *)key;

- (void)readAll;
- (void)readAllReversion;

@end

NS_ASSUME_NONNULL_END
