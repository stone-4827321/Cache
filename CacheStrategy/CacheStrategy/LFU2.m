//
//  LFU2.m
//  CacheStrategy
//
//  Created by stone on 2020/11/11.
//

#import "LFU2.h"

@interface LFU2_Node : NSObject
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) LFU2_Node *prev;
@property (nonatomic, strong) LFU2_Node *next;
@property (nonatomic) int count;
@end
@implementation LFU2_Node
@end

@interface LFU2_List : NSObject

@property (nonatomic, strong) LFU2_Node *head;
@property (nonatomic, strong) LFU2_Node *tail;
@property (nonatomic) int count;

@end

@implementation LFU2_List

- (void)insertNodeAtHead:(LFU2_Node *)node {
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

- (void)bringNodeToHead:(LFU2_Node *)node {
    // 当前节点已经排在最前
    if (node == _head) {
        return;
    }
    
    // 先移除节点，再插入到头部
    [self removeNode:node];
    [self insertNodeAtHead:node];
}

- (void)removeNode:(LFU2_Node *)node {
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

- (LFU2_Node *)removeTailNode {
    if (_head == _tail) {
        _head = nil;
        _tail = nil;
    }
    LFU2_Node *node = _tail;
    _tail = node.prev;
    _tail.next = nil;
    return node;
}

@end


@interface LFU2 ()

@property (nonatomic) NSInteger capacity;

// 记录最小count
@property (nonatomic) int minCount;

@property (nonatomic, strong) NSMutableDictionary *dict;

@property (nonatomic, strong) NSMutableDictionary *listDict;


@end

@implementation LFU2

- (instancetype)initWithCapacity:(NSInteger)capacity {
    if (self = [super init]) {
        _capacity = capacity;
        _dict = [[NSMutableDictionary alloc] init];
        _listDict = [[NSMutableDictionary alloc] init];
        _minCount = 10000;
    }
    return self;
}

- (void)readAll {
    NSLog(@"readAll");
    for (LFU2_List *list in _listDict.allValues) {
        NSLog(@"~~%d",list.count);
        LFU2_Node *node = list.head;
        while (node) {
            NSLog(@"%@(%d)", node.value, node.count);
            node = node.next;
        }
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

- (void)readAllReversion {
    NSLog(@"readAllReversion");
    for (LFU2_List *list in _listDict.allValues) {
        NSLog(@"~~%d",list.count);
        LFU2_Node *node = list.tail;
        while (node) {
            NSLog(@"%@(%d)", node.value, node.count);
            node = node.prev;
        }
    }
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~");
}

#pragma mark -

- (void)setObject:(NSString *)value forKey:(NSString *)key count:(int)count {
    LFU2_Node *node = _dict[key];
    if (node) {
        node.value = value;
        if (node.count == count) {
            [self bringNodeToHeadForSameList:node];
        }
        else {
            [self bringNodeToHeadForDiffList:node newCount:count];
        }
        node.count = count;
    }
    else {
        if (_dict.count >= self.capacity) {
            [self removeTailNode];
        }

        node = [[LFU2_Node alloc] init];
        node.value = value;
        node.key = key;
        node.count = count;
        [self insertNode:node];
        _dict[key] = node;
    }
}

- (NSString *)objectForKey:(NSString *)key {
    LFU2_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    int newCount = node.count + 1;
    [self bringNodeToHeadForDiffList:node newCount:newCount];
    node.count = newCount;
    return node.value;
}

- (NSString *)removeObjectForKey:(NSString *)key {
    LFU2_Node *node = _dict[key];
    if (!node) {
        return nil;
    }
    [self removeNode:node];
    [_dict removeObjectForKey:node.key];
    return node.value;
}


#pragma mark -

- (void)insertNode:(LFU2_Node *)node {
    NSString *count = [NSString stringWithFormat:@"%d",node.count];
    LFU2_List *list = _listDict[count];
    if (!list) {
        list = [[LFU2_List alloc] init];
        list.count = node.count;
        _listDict[count] = list;
        if (list.count < self.minCount) {
            self.minCount = list.count;
        }
    }
    [list insertNodeAtHead:node];
}

- (void)bringNodeToHeadForSameList:(LFU2_Node *)node {
    NSString *count = [NSString stringWithFormat:@"%d",node.count];
    LFU2_List *list = _listDict[count];
    if (!list) {
        list = [[LFU2_List alloc] init];
        list.count = node.count;
        _listDict[count] = list;
        if (list.count < self.minCount) {
            self.minCount = list.count;
        }
    }
    [list bringNodeToHead:node];
}

- (void)bringNodeToHeadForDiffList:(LFU2_Node *)node newCount:(int)newCount {
    [self removeNode:node];
    
    node.count = newCount;
    [self insertNode:node];
}

- (void)removeNode:(LFU2_Node *)node {
    NSString *count = [NSString stringWithFormat:@"%d",node.count];
    LFU2_List *list = _listDict[count];
    [list removeNode:node];
    if (!list.head) {
        [_listDict removeObjectForKey:count];
        if (self.minCount == list.count) {
            // 当不允许设置设置node的count时
            // self.minCount ++;
            
            // 由于可设置node的count，只能用以下方法获取最新的minCount
            self.minCount = 1000;
            for (LFU2_List *list in _listDict.allValues) {
                if (list.count < self.minCount) {
                    self.minCount = list.count;
                }
            }
        }
    }
}

- (LFU2_Node *)removeTailNode {
    NSString *count = [NSString stringWithFormat:@"%d",self.minCount];
    LFU2_List *list = _listDict[count];
    LFU2_Node *node = [list removeTailNode];
    if (!list.head) {
        [_listDict removeObjectForKey:count];
        if (self.minCount == list.count) {
            // 当不允许设置设置node的count时
            // self.minCount ++;
            
            // 由于可设置node的count，只能用以下方法获取最新的minCount
            self.minCount = 1000;
            for (LFU2_List *list in _listDict.allValues) {
                if (list.count < self.minCount) {
                    self.minCount = list.count;
                }
            }
        }
    }
    return node;
}

@end
