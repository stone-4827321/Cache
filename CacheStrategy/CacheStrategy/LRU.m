//
//  LRU.m
//  CacheStrategy
//
//  Created by stone on 2020/10/30.
//

#import "LRU.h"

@interface LRU_Node : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) LRU_Node *prev;
@property (nonatomic, strong) LRU_Node *next;
@end
@implementation LRU_Node
@end

@interface LRU ()

@property (nonatomic) NSInteger capacity;

@property (nonatomic, strong) LRU_Node *head;
@property (nonatomic, strong) LRU_Node *tail;

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation LRU

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        _capacity = capacity;
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)readAll {
    NSLog(@"readAll");
    LRU_Node *node = _head;
    while (node) {
        NSLog(@"%@", node.value);
        node = node.next;
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

- (void)readAllReversion {
    NSLog(@"readAllReversion");
    LRU_Node *node = _tail;
    while (node) {
        NSLog(@"%@", node.value);
        node = node.prev;
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

#pragma mark -

- (void)setObject:(NSString *)value forKey:(NSString *)key {
    LRU_Node *node = _dict[key];
    if (node) {
        node.value = value;
        // 已经存在的节点直接置于头部
        [self bringNodeToHead:node];
    }
    else {
        if (_dict.count >= self.capacity) {
            LRU_Node *removeNode = [self removeTailNode];
            [_dict removeObjectForKey:removeNode.key];
        }
        
        node = [[LRU_Node alloc] init];
        node.value = value;
        node.key = key;
        _dict[key] = node;
        
        [self insertNodeAtHead:node];
    }
}

- (NSString *)objectForKey:(NSString *)key {
    LRU_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    [self bringNodeToHead:node];
    return node.value;
}

- (NSString *)removeObjectForKey:(NSString *)key {
    LRU_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    [self removeNode:node];
    [_dict removeObjectForKey:node.key];
    return node.value;
}


#pragma mark -

- (void)insertNodeAtHead:(LRU_Node *)node {
    // 当前无任何节点
    if (!_head) {
        _head = node;
        _tail = node;
    }
    else {
        node.next = _head;
        _head.prev = node;
        _head = node;
    }
}

- (void)bringNodeToHead:(LRU_Node *)node {
    // 当前节点已经排在最前
    if (node == _head) {
        return;
    }
    
    // 先移除节点，再插入到头部
    [self removeNode:node];
    [self insertNodeAtHead:node];
}

- (void)removeNode:(LRU_Node *)node {
    node.prev.next = node.next;
    node.next.prev = node.prev;
    // 更新头尾
    if (_head == node) {
        _head = node.next;
    }
    if (_tail == node) {
        _tail = node.prev;
    }
    node.prev = node.next = nil;
}

- (LRU_Node *)removeTailNode {
    if (_head == _tail) {
        _head = nil;
        _tail = nil;
    }
    LRU_Node *node = _tail;
    _tail = node.prev;
    _tail.next = nil;
    return node;
}

@end
