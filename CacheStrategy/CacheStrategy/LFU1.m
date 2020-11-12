//
//  LFU1.m
//  CacheStrategy
//
//  Created by stone on 2020/11/11.
//

#import "LFU1.h"

@interface LFU1_Node : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) LFU1_Node *prev;
@property (nonatomic, strong) LFU1_Node *next;
@property (nonatomic) int count;
@end
@implementation LFU1_Node
@end

@interface LFU1 ()

@property (nonatomic) NSInteger capacity;

@property (nonatomic, strong) LFU1_Node *head;
@property (nonatomic, strong) LFU1_Node *tail;

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation LFU1

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        _capacity = capacity;
        _dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)readAll {
    NSLog(@"readAll");
    LFU1_Node *node = _head;
    while (node) {
        NSLog(@"%@(%d)", node.value, node.count);
        node = node.next;
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

- (void)readAllReversion {
    NSLog(@"readAllReversion");
    LFU1_Node *node = _tail;
    while (node) {
        NSLog(@"%@(%d)", node.value, node.count);
        node = node.prev;
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

#pragma mark -

- (void)setObject:(NSString *)value forKey:(NSString *)key count:(int)count {
    LFU1_Node *node = _dict[key];
    if (node) {
        node.value = value;
        node.count = count;
        [self bringNode:node];
    }
    else {
        if (_dict.count >= self.capacity) {
            LFU1_Node *removeNode = [self removeTailNode];
            [_dict removeObjectForKey:removeNode.key];
        }
        
        node = [[LFU1_Node alloc] init];
        node.value = value;
        node.key = key;
        node.count = count;
        [self insertNode:node];
        _dict[key] = node;
    }
}

- (NSString *)objectForKey:(NSString *)key {
    LFU1_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    node.count ++;
    [self bringNode:node];
    return node.value;
}

- (NSString *)removeObjectForKey:(NSString *)key {
    LFU1_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    [self removeNode:node];
    [_dict removeObjectForKey:node.key];
    return node.value;
}

#pragma mark -

- (void)insertNode:(LFU1_Node *)node {
    // 当前无任何节点
    if (!_head) {
        _head = node;
        _tail = node;
    }
    else {
        LFU1_Node *curNode = _tail;
        while (curNode) {
            if (curNode.count > node.count) {
                break;
            }
            curNode = curNode.prev;
        }
        // 新节点置于尾部
        if (curNode == _tail) {
            _tail.next = node;
            node.prev = _tail;
            _tail = node;
        }
        // 新节点置于头部
        else if (curNode == nil) {
            _head.prev = node;
            node.next = _head;
            _head = node;
        }
        // 新节点置于curNode之后
        else {
            node.next = curNode.next;
            curNode.next.prev = node;
            curNode.next = node;
            node.prev = curNode;
        }
    }
}

- (void)bringNode:(LFU1_Node *)node {
    // 修改count后node位置不变
    if (node == _head && node.next.count <= node.count) {
        return;
    }
    else if (node == _tail && node.prev.count > node.count) {
        return;
    }
    if (node.next.count <= node.count && node.prev.count > node.count) {
        return;
    }
    
    // 将node从链表移除
    [self removeNode:node];
    [self readAll];
    [self insertNode:node];
}

- (void)removeNode:(LFU1_Node *)node {
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

- (LFU1_Node *)removeTailNode {
    if (_head == _tail) {
        _head = nil;
        _tail = nil;
    }
    LFU1_Node *node = _tail;
    _tail = node.prev;
    _tail.next = nil;
    return node;
}
@end
