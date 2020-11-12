//
//  ViewController.m
//  LRU
//
//  Created by stone on 2020/10/27.
//

#import "ViewController.h"

@interface Node : NSObject
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) Node *prev;
@property (nonatomic, strong) Node *next;
@property (nonatomic) NSInteger count;
@end
@implementation Node
@end

@interface ViewController ()

@property (nonatomic, strong) Node *head;
@property (nonatomic, strong) Node *tail;

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dict = [NSMutableDictionary dictionary];
}

#pragma mark - LRU

- (IBAction)check:(id)sender {
    NSLog(@"开始查询");
    Node *node = _head;
    while (node) {
        NSLog(@"%@-%@-%@", node.prev.value, node.value, node.next.value);
        node = node.next;
    }
}

static int v = 0;
- (IBAction)insert:(id)sender {
    NSString *key = [NSString stringWithFormat:@"%d", v++];
    Node *node = [[Node alloc] init];
    node.value = key;
    [self insertNode:node];
    _dict[key] = node;
}

- (void)insertNode:(Node *)node {
    // 当前是否存在head
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

- (IBAction)update:(id)sender {
    Node *node = _dict[@"3"];
    if (node) {
        // 头部node
        if (_head == node) {
            return;
        }
        // 尾部node
        if (_tail == node) {
            _tail = node.prev;
            _tail.next = nil;
        }
        else {
            node.prev.next = node.next;
            node.next.prev = node.prev;
        }
        node.next = _head;
        node.prev = nil;
        _head.prev = node;
        _head = node;
    }
}

- (IBAction)delete:(id)sender {
    Node *node = _dict[@"5"];
    if (_head == node) {
        _head = node.next;
    }
    if (_tail == node) {
        _tail = node.prev;
    }
    if (node.next) {
        node.next.prev = node.prev;
    }
    if (node.prev) {
        node.prev.next = node.next;
    }
}

- (IBAction)lfu_check:(id)sender {
    NSLog(@"开始查询");
    Node *node = _head;
    while (node) {
        NSLog(@"%@,%@", node.value, @(node.count));
        node = node.next;
    }
}

- (IBAction)lfu_insert:(id)sender {
    NSArray *list = @[@(26),@(32),@(30),@(26),@(25)];
    
    NSString *key = [NSString stringWithFormat:@"%d", v];
    Node *node = [[Node alloc] init];
    node.value = key;
    node.count = [list[v] integerValue];
    v++;
    [self lfu_insertNode:node];
    _dict[key] = node;
}

- (void)lfu_insertNode:(Node *)node {
    // 当前是否存在head
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

- (IBAction)lfu_update:(id)sender {
    
}
- (IBAction)lfu_delete:(id)sender {
    
}

@end
