//
//  LFU2.h
//  CacheStrategy
//
//  Created by stone on 2020/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFU2 : NSObject

- (instancetype)initWithCapacity:(NSInteger)capacity;

- (void)readAll;
- (void)readAllReversion;

- (void)setObject:(NSString *)value forKey:(NSString *)key count:(int)count;
- (NSString *)objectForKey:(NSString *)key;
- (NSString *)removeObjectForKey:(NSString *)key;
- (NSString *)removeObjectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
