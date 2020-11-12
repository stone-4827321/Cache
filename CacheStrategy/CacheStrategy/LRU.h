//
//  LRU.h
//  CacheStrategy
//
//  Created by stone on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRU : NSObject

- (instancetype)initWithCapacity:(NSInteger)capacity;

- (void)setObject:(NSString *)object forKey:(NSString *)key;

- (NSString *)objectForKey:(NSString *)key;

- (NSString *)removeObjectForKey:(NSString *)key;

- (void)readAll;
- (void)readAllReversion;

@end

NS_ASSUME_NONNULL_END
