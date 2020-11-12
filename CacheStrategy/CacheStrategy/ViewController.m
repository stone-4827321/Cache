//
//  ViewController.m
//  CacheStrategy
//
//  Created by stone on 2020/10/30.
//

#import "ViewController.h"
#import "LRU.h"
#import "LFU1.h"
#import "LFU2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self lfu2];
}

- (void)lru {
    LRU *lru = [[LRU alloc] initWithCapacity:3];
    [lru readAll];
    for (int i = 0; i < 5; i++) {
        [lru setObject:[NSString stringWithFormat:@"value%d",i] forKey:[NSString stringWithFormat:@"key%d",i]];
    };
    [lru readAll];
    [lru readAllReversion];
    
    [lru setObject:@"new_value4" forKey:@"key4"];
    [lru readAll];
    [lru readAllReversion];

    [lru setObject:@"new_value2" forKey:@"key2"];
    [lru readAll];
    [lru readAllReversion];

    [lru setObject:@"new_value0" forKey:@"key0"];
    [lru readAll];
    [lru readAllReversion];
    
    [lru removeObjectForKey:@"key2"];
    [lru readAll];
    [lru readAllReversion];
    
    [lru removeObjectForKey:@"key4"];
    [lru readAll];
    [lru readAllReversion];

    [lru removeObjectForKey:@"key0"];
    [lru readAll];
    [lru readAllReversion];
}

- (void)lfu {
    LFU1 *lfu = [[LFU1 alloc] initWithCapacity:5];
    [lfu setObject:@"value_c" forKey:@"key_c" count:26];
    [lfu setObject:@"value_b" forKey:@"key_b" count:30];
    [lfu setObject:@"value_e" forKey:@"key_e" count:25];
    [lfu setObject:@"value_d" forKey:@"key_d" count:26];
    [lfu setObject:@"value_a" forKey:@"key_a" count:32];
    
    [lfu readAll];
    [lfu readAllReversion];
    
    NSLog(@"%@",[lfu objectForKey:@"key_c"]);
    [lfu readAll];
    [lfu readAllReversion];

    NSLog(@"%@",[lfu objectForKey:@"key_b"]);
    [lfu readAll];
    [lfu readAllReversion];
    
    
    [lfu setObject:@"value_f" forKey:@"key_f" count:1];
    [lfu readAll];
    [lfu readAllReversion];
    
    
    [lfu removeObjectForKey:@"key_b"];
    [lfu readAll];
    [lfu readAllReversion];
}

- (void)lfu2 {
    LFU2 *lfu = [[LFU2 alloc] initWithCapacity:5];
    [lfu setObject:@"value_c" forKey:@"key_c" count:26];
    [lfu setObject:@"value_b" forKey:@"key_b" count:30];
    [lfu setObject:@"value_e" forKey:@"key_e" count:25];
    [lfu setObject:@"value_d" forKey:@"key_d" count:26];
    [lfu setObject:@"value_a" forKey:@"key_a" count:32];
    
    [lfu readAll];
    [lfu readAllReversion];
    
    [lfu setObject:@"value_e" forKey:@"key_e" count:4];
    [lfu readAll];
    [lfu readAllReversion];
    
    NSLog(@"%@",[lfu objectForKey:@"key_c"]);
    [lfu readAll];
    [lfu readAllReversion];

    NSLog(@"%@",[lfu objectForKey:@"key_b"]);
    [lfu readAll];
    [lfu readAllReversion];
    
    [lfu setObject:@"value_e" forKey:@"key_e" count:32];
    [lfu readAll];
    [lfu readAllReversion];
    
    [lfu setObject:@"value_f" forKey:@"key_f" count:1];
    [lfu readAll];
    [lfu readAllReversion];
    
    [lfu setObject:@"value_g" forKey:@"key_g" count:2];
    [lfu readAll];
    [lfu readAllReversion];


    [lfu removeObjectForKey:@"key_b"];
    [lfu readAll];
    [lfu readAllReversion];
    
    [lfu removeObjectForKey:@"key_a"];
    [lfu readAll];
    [lfu readAllReversion];
}

@end
