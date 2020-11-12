//
//  ViewController.m
//  SQLite
//
//  Created by stone on 2020/10/19.
//

#import "ViewController.h"
#import <sqlite3.h>

static int callback(void *data, int argc, char **argv, char **azColName) {
    NSLog(@"%s", (const char*)data);
    //sleep(4);
    for(int i = 0; i < argc; i++) {
      NSLog(@"%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    return 0;
}

@interface ViewController ()

// 结构体
@property (nonatomic) sqlite3 *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self openDB];
}

- (void)openDB {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/stone.sqlite"];
    NSLog(@"%@",path);
    int result = sqlite3_open(path.UTF8String, &_db);
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功");
        [self createTable:nil];
    }
    else {
        NSLog(@"打开数据库失败");
    }
}

- (IBAction)createTable:(id)sender {
    const char *sql = "CREATE TABLE IF NOT EXISTS t_student (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER NOT NULL); CREATE INDEX name_index ON t_student (name);";
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"创建表成功");
    }
    else {
        NSLog(@"创建表失败 %d %s", result, error);
    }
}

- (IBAction)dropTable:(id)sender {
    const char *sql = "DROP TABLE t_student";
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除表成功");
    }
    else {
        NSLog(@"删除表失败 %d %s", result, error);
    }
}
- (IBAction)alertTable1:(id)sender {
    const char *sql = "ALTER TABLE t_student RENAME TO new_t_student";
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"修改表成功");
    }
    else {
        NSLog(@"修改表失败 %d %s", result, error);
    }
}

- (IBAction)alertTable2:(id)sender {
    const char *sql = "ALTER TABLE t_student ADD COLUMN sex char(1)";
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"修改表成功");
    }
    else {
        NSLog(@"修改表失败 %d %s", result, error);
    }
}


- (IBAction)insertData1:(id)sender {
    for (int i = 0; i < 1; i++) {
        NSString *name = [NSString stringWithFormat:@"stone%d",i];
        int age = 100 + i;
        
        NSString *sql = [NSString stringWithFormat:@"insert into t_student (id, name, age) values (%d, '%@', %d)", i, name, age];
        char *error = NULL;
        int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
        if (result == SQLITE_OK) {
            NSLog(@"插入数据成功");
        }
        else {
            NSLog(@"插入数据失败 %d %s", result, error);
        }
    }
}

- (IBAction)insertData2:(id)sender {
    const char *sql = "INSERT OR REPLACE INTO t_student (id, name, age) VALUES (?1, ?2, ?3)";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"sql语句有问题");
        return;
    }
    for (int i = 0; i < 10; i++) {
        NSString *name = [NSString stringWithFormat:@"stone_%d",i];
        int age = 100 + i;
        
        sqlite3_bind_int(stmt, 1, i);
        sqlite3_bind_text(stmt, 2, name.UTF8String, -1, NULL);
        sqlite3_bind_int(stmt, 3, age);
        
        int result = sqlite3_step(stmt);
        if (result == SQLITE_DONE) {
            NSLog(@"插入数据成功");
        }
        else {
            NSLog(@"插入数据失败 %d", result);
        }
        sqlite3_reset(stmt);
        sqlite3_clear_bindings(stmt);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
}

- (IBAction)selectData1:(id)sender {
    const char *sql = "select * from t_student";

    char *error = NULL;
    const char *data = "Callback function called";
    int result = sqlite3_exec(_db, sql, callback, (void*)data, &error);
    if (result == SQLITE_OK) {
        NSLog(@"查询表成功");
    }
    else {
        NSLog(@"查询表失败 %d %s", result, error);
    }
}

- (IBAction)selectData2:(id)sender {
    const char *sql = "select * from t_student";
    
    int pnRow = 0;
    int pnColumn = 0;
    char *error = NULL;
    char **pazResult;
    int rc = sqlite3_get_table(_db, sql,&pazResult, &pnRow, &pnColumn, &error);
    if(rc == SQLITE_OK) {
        for(int i = 0; i < pnRow; i++) {
            for(int j = 0; j < pnColumn; j++) { //pn
                //函数执行完成返回的结果集中，包含（pnColumn * (pnRow + 1)）个数据项。其中多出来的一行是列名，剩下的pnColumn*pnRow项是数据。
                NSLog(@"%d--%s : %s\n", i, pazResult[j], pazResult[pnColumn + i * pnColumn + j]);
            }
        }
    }
    sqlite3_free_table(pazResult);
}

- (IBAction)selectData3:(id)sender {
    // sql语句
    const char *sql = "SELECT * FROM t_student";
    sqlite3_stmt *stmt = NULL;
    
    // 进行查询前的准备工作
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"sql语句有问题");
        return;
    }

    int count = sqlite3_column_count(stmt);
    for (int i = 0; i < count; i++) {
        const char *name = sqlite3_column_name(stmt, i);
        NSLog(@"列名：%s", name);
    }
    
    // 每调用一次sqlite3_step函数，stmt就会指向下一条记录
    while (sqlite3_step(stmt) == SQLITE_ROW) {  // 找到一条记录
        // 取出数据
        int ID = sqlite3_column_int(stmt, 0);// 取出第0列字段的值
        const unsigned char *name = sqlite3_column_text(stmt, 1);// 取出第1列字段的值
        int nameLenth = sqlite3_column_bytes(stmt, 1); // 获取字节长度
        int age = sqlite3_column_int(stmt, 2);// 取出第2列字段的值
        
        NSLog(@"数据：%d %s %d", ID, name, age);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
}

- (IBAction)updateData1:(id)sender {
    const char *sql = "update t_student set name = 'new_stone0' where name = 'stone_0'";
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"更新成功");
    }
    else {
        NSLog(@"更新失败 %d %s", result, error);
    }
}

- (IBAction)updateData2:(id)sender {
    const char *sql = "UPDATE t_student SET name = ?1 WHERE age = ?2;";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"sql语句有问题");
        return;
    }
    sqlite3_bind_int(stmt, 2, 101);
    sqlite3_bind_text(stmt, 1, "new_stone1", -1, NULL);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) {
        NSLog(@"更新成功");
    }
    else {
        NSLog(@"更新失败 %d", result);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
}

- (IBAction)deleteData1:(id)sender {
    const char *sql = "delete from t_student where name = 'stone_2'";
    
    char *error = NULL;
    int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败 %d %s", result, error);
    }
}

- (IBAction)deleteData2:(id)sender {
    const char *sql = "DELETE FROM t_student WHERE age > ?1";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"sql语句有问题");
        return;
    }
    sqlite3_bind_int(stmt, 1, 104);
    int result = sqlite3_step(stmt);
    if (result == SQLITE_DONE) {
        NSLog(@"删除成功");
    }
    else {
        NSLog(@"删除失败 %d", result);
    }
    sqlite3_finalize(stmt);
    stmt = NULL;
}

@end
