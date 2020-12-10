# 概述

- 缓存是本地数据存储，存储方式主要包含两种：磁盘储存和内存存储。
- 磁盘缓存：磁盘是程序的存储空间，磁盘缓存容量大速度慢，是永久存储东西的。
- iOS 为不同数据管理对存储路径做了规范如下：
  - 每一个应用程序都会拥有一个应用程序沙盒。

  - 应用程序沙盒就是一个文件系统目录。

  - 沙盒根目录结构：Documents、Library、temp。
- 磁盘存储方式主要有文件管理和数据库。
- 内存缓存：内存是当前程序的运行空间，内存缓存速度快容量小，供 cpu 直接读取，比如打开一个程序，它是运行在内存中的，关闭程序后内存又会释放。
- iOS 内存分为 5 个区：栈区，堆区，全局区，常量区，代码区。
  - **栈区 stack**：该区域由系统管理，主要存一些局部变量，以及函数跳转时的现场保护。因此大量的局部变量，深递归，函数循环调用都可能导致内存耗尽而运行崩溃；
  - **堆区 heap：**与栈区相对，这一块一般由开发者管理，比如 `alloc`，`free` 的操作，存储一些自己创建的对象；
  - **全局区（静态区 static）：**存储全局变量和静态变量，已经初始化的和没有初始化的会分开存储在相邻的区域，程序结束后系统会释放；
  - **常量区：**存储常量字符串和 `const` 常量；
  - **代码区：**存储代码。
- 在程序中声明的容器（数组 、字典）都可看做内存中存储。

# SQLite

- 为什么要用 SQLite
  - 不需要一个单独的服务器进程或操作的系统（无服务器的）。

  - SQLite 不需要配置，这意味着不需要安装或管理。

  - 一个完整的 SQLite 数据库是存储在一个单一的跨平台的磁盘文件。

  - SQLite 是非常小的，是轻量级的，完全配置时小于 400KiB，省略可选功能配置时小于250KiB。

  - SQLite 是自给自足的，这意味着不需要任何外部的依赖。

  - SQLite 事务是完全兼容 ACID 的，允许从多个进程或线程安全访问。

  - SQLite 支持 SQL92（SQL2）标准的大多数查询语言的功能。

  - SQLite 使用 ANSI-C 编写的，并提供了简单和易于使用的 API。

  - SQLite 可在 UNIX（Linux, Mac OS-X, Android, iOS）和 Windows（Win32, WinCE, WinRT）中运行。

## 命令

  - DDL - 数据定义语言
    - **CREATE**：创建一个新的表，一个表的视图，或者数据库中的其他对象。
    - **ALTER**：修改数据库中的某个已有的数据库对象，比如一个表。
    - **DROP**：删除整个表，或者表的视图，或者数据库中的其他对象。

  - DML - 数据操作语言
    - **INSERT**：创建一条记录。
    - **UPDATE**：修改记录。
    - **DELETE**：删除记录。

  - DQL - 数据查询语言

    - **SELECT**：从一个或多个表中检索记录。

## 类型

  - **NULL**：值是一个 NULL 值。
  - **INTEGER**：值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。可以附带 **AUTOINCREMENT** 关键字实现自增。
  - **REAL**：值是一个浮点值，存储为 8 字节的 IEEE 浮点数字。
  - **TEXT**：值是一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
  - **BLOB**：值是一个 blob 数据，完全根据它的输入存储。

## 约束

- 约束是在表的数据列上强制执行的规则，用来限制可以插入到表中的数据类型，确保数据库中数据的准确性和可靠性。

- 约束可以是列级或表级。列级约束仅适用于列，表级约束被应用到整个表。

- 以下是在 SQLite 中常用的约束。

  - **NOT NULL**：确保某列不能有 NULL 值。
  - **DEFAULT**：当某列没有指定值时，为该列提供默认值。
  - **UNIQUE**：确保某列中的所有值是不同的。
  - **PRIMARY KEY**：**主键**，唯一标识数据库表中的各行/记录。
  - **CHECK**：确保某列中的所有值满足一定条件。

  ```sqlite
  CREATE TABLE company(
     id 						INT 		PRIMARY KEY     NOT NULL,
     name           TEXT    NOT NULL,
     age            INT     NOT NULL,
     address        CHAR(50),
     salary         REAL    CHECK(salary > 0)    DEFAULT 50000.00
  );
  ```

## 索引

- 索引（Index）是一种特殊的查找表，数据库搜索引擎用来加快数据检索。

- 索引有助于加快 SELECT 查询和 WHERE 子句，但它会减慢使用 UPDATE 和 INSERT 语句时的数据输入。

- 索引可以创建或删除，但不会影响数据。

- SQLite 的 **CREATE INDEX** 语句用于建立索引。

  ```sqlite
  // 单列索引
  CREATE INDEX salary_index ON company (salary);
  // 唯一索引
  CREATE UNIQUE INDEX address_index ON company (address);
  // 组合索引
  CREATE UNIQUE INDEX com_index ON company (salary, address);
  ```

## 子句

- **WHERE** 子句指定获取数据的条件，可用于 SELECT、UPDATE、DELETE 语句中。

  ```sqlite
  SELECT * FROM table_name WHERE [condition]
  ```

- **LIKE** 子句匹配通配符指定模式的文本值，通配符包括：百分号 `%` 代表零个、一个或多个数字或字符；下划线 `_` 代表一个单一的数字或字符。

- **GLOB** 子句匹配通配符指定模式的文本值，通配符包括：星号 `*` 代表零个、一个或多个数字或字符；问号 `?` 代表一个单一的数字或字符。

-  **LIMIT** 子句限制由 SELECT 语句返回的数据数量。

  ```sqlite
  SELECT * FROM table_name LIMIT N
  ```

- **ORDER BY** 子句基于一个或多个列按升序或降序顺序排列数据。

  ```sqlite
  SELECT * FROM table_name ORDER BY column [ASC | DESC]
  ```

- **GROUP BY** 子句对数据进行分组，该子句放在 WHERE 子句之后，放在 ORDER BY 子句之前。

  ```sqlite
  SELECT * FROM table_name GROUP BY column 
  ```

# iOS & SQLite3

- 在 iOS 中使用 SQLite3，需要添加库文件 **libsqlite3.tbd**，并导入头文件 `#import <sqlite3.h>`
- 对于 SQlite3，所有的 API 函数都有一个前缀：**sqlite3_**，表明这些函数由 SQlite 数据库产品提供，3代表版本。

## 打开数据库

- 建立并保存句柄 db，db就是数据库的象征，任何对数据库的操作，都是对这个句柄进行操作。

  ```objective-c
  @property (nonatomic) sqlite3 *db;
  ```

- 设置数据库路径并打开，如果数据库文件不存在，那么该函数会自动创建数据库文件。

  ```objective-c
  NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/stone.sqlite"];
  int result = sqlite3_open(path.UTF8String, &_db);
  if (result == SQLITE_OK) {
      NSLog(@"打开数据库成功");
  }
  else {
      NSLog(@"打开数据库失败");
  }
  ```

- SQLite3 提供了3套接口用于打开数据库：

  - 对于 `sqlite3_open` 和 `sqlite3_open16` 函数，如果可能将以可读可写的方式打开数据库，否则以只读的方式打开数据库。如果要打开的数据库文件不存在，就新建一个。
  - `sqlite3_open_v2` 可以对打开数据库的方式进行控制，如只读 `SQLITE_OPEN_READONLY`，可读可写 `SQLITE_OPEN_READWRITE`，不存在则建立 `SQLITE_OPEN_CREATE` 等。此外，还允许命名一个虚拟文件系统（Virtual File System）模块，用来与数据库连接。VFS 作为 SQlite library 和底层存储系统（如某个文件系统）之间的一个抽象层，通常可以简单的给该参数传递一个NULL指针，以使用默认的 VFS 模块。
  - `sqlite3_open` 和 `sqlite3_open_v2` 使用 UTF-8 编码，`sqlite3_open16` 使用 UTF-16 编码。

- 打开数据库通常不需要关闭，但也可以调用 `sqlite3_close` 或 `sqlite3_close_v2` 进行手动关闭。
  - `sqlite3_close` 关闭时，如果存在某些没有完成的（nonfinalized）SQL 语句等情况，函数将会返回SQLITE_BUSY 错误。需要调用 `sqlite3_finalize` 完结所有的预处理语句之后再次调用 `sqlite3_close`。
  - `sqlite3_close_v2` 关闭时，以上情况下会直接返回 SQLITE_OK，会等待未完成语句完成后自动释放连接，非常适用于具有垃圾回收机制的语言。

## 执行 SQL

### 便捷函数

- SQlite 拥有很多早期遗留下来的便捷函数，其优缺点十分明显：
  - 优点：使用方便。
  - 缺点：便捷函数的性能并不优秀，其内部调用 `sqlite3_prepare_xxx`、`sqlite3_step`、`sqlite3_finalize` 等函数来完成一站式功能。在这样的函数内部往往存在很多额外的类型转换，所以这些函数很可能会比主动调用对应的函数执行的更慢一些。
  - 缺点：便捷函数不支持参数绑定，更容易遭到”SQL注入攻击”，安全性更差。

- 便捷函数 **`sqlite3_exec`** 可以一次性预处理并执行一条或多条 SQL 语句（多条以分号隔开），若执行过程中没有遇到任何错误，最后函数将返回 SQLITE_OK。

  ```c++
  int sqlite3_exec(
    sqlite3*,                                  // 有效的数据库连接
    const char *sql,                           // UTF-8编码的SQL语句
    int (*callback)(void*,int,char**,char**),  // 指向回调函数的指针，可传递NULL
    void *,                                    // 传递给回调函数的参数指针
    char **errmsg                              // 错误
  );
  
  // 回调函数类型
  // 第1个参数对应于sqlite3_exec函数的第4个参数，用于传递用户数据；第2个参数指明结果集中一共有多少列；第3个参数保存当前数据行的数据，第4个参数保存当前数据行所属列的列名。
  // 正常情况下，回调函数应该返回0，如果它返回一个非0值，则sqlite3_exec函数将终止执行，并返回SQLITE_ABORT错误码。
  typedef int (*sqlite3_callback)(void*,int,char**, char**);
  ```

- 便捷函数 **`sqlite3_get_table`** 在 SQL 命令字符串执行完成之后，返回全部的结果数据。是专门针对 SELECT 语句设计的。

  ```objective-c
  SQLITE_API int sqlite3_get_table(
    sqlite3 *db,          // 有效的数据库连接
    const char *zSql,     // UTF-8编码的SQL语句
    char ***pazResult,    // SQL语句执行结果，包含pnColumn*(pnRow+1)个数据项。其中多出来的一行是列名，剩下的pnColumn*pnRow项是数据
    int *pnRow,           // 查询到的数据项的行数
    int *pnColumn,        // 查询到的数据项的列数
    char **pzErrmsg       // 错误
  );
  
  
  const char *sql = "select * from t_student";
      
  int pnRow = 0;
  int pnColumn = 0;
  char *error = NULL;
  char **pazResult;
  if(sqlite3_get_table(_db, sql,&pazResult, &pnRow, &pnColumn, &error) == SQLITE_OK) {
      for(int i = 0; i < pnRow; i++) {
          for(int j = 0; j < pnColumn; j++) { 
              NSLog(@"%s = %s", pazResult[j], pazResult[pnColumn + i * pnColumn + j]);
          }
      }
  }
  // 由sqlite3_get_table函数返回的结果集，所占用的内存，需要由sqlite3_free_table函数来释放。
  sqlite3_free_table(pazResult);
  ```

### 预处理和参数绑定

- 一般情况下，除了表操作，其他 SQL 语句推荐使用 `sqlite3_prepare_v2`  和 `sqlite3_step` 进行操作。

  ```c++
  /* create a statement from an SQL string */
  sqlite3_stmt *stmt = NULL;
  if (sqlite3_prepare_v2(db, sql_str, sql_str_len, &stmt, NULL) != SQLITE_OK) {
    	// SQL string has error
  		return
  }
   
  /* use the statement as many times as required */
  while(...) {
      /* bind any parameter values */
      sqlite3_bind_xxx( stmt, param_idx, param_value... );
      ...
      /* execute statement and step over each row of the result set */
      while (sqlite3_step(stmt) == SQLITE_ROW) {
          /* extract column values from the current result row */
          col_val = sqlite3_column_xxx(stmt, col_index);
          ...
      }
   
      /* reset the statement so it may be used again */
      sqlite3_reset(stmt);
      sqlite3_clear_bindings(stmt);  /* optional */
  }
   
  /* destroy and release the statement */
  sqlite3_finalize(stmt);
  stmt = NULL;
  ```

- 预处理函数 **`sqlite3_prepare_v2`** 将 SQL 命令字符串转换为 prepared 语句。

  ```c++
  SQLITE_API sqlite3_prepare_v2(
    sqlite3 *db,            // 有效的数据库连接
    const char *zSql,       // UTF-8编码的SQL语句
    int nByte,              // 如果nByte为负，则取出zSql从开始到终止符的内容，如果nByte非负，则取出对应的字节数
    sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
    const char **pzTail     // zSql在遇到终止符或者是达到设定的nByte之后结束，假如zSql还有剩余的内容，剩余的内容被存放到pZtail中,不包括终止符
  );
  ```

- 绑定参数：语句参数（*statement parameters*）是指插入到 SQL 命令字符串中的特殊字符，他们作为临时占位符。当一条语句在 prepare 之后，尚未执行之前，可以给这些占位符绑定指定的值。

  - 参数符号 **?\<index>** `INSERT INTO people (id, name) VALUES (?1, ?2)`

  - 绑定值：

    - 第1个参数是指向 `sqlite3_stmt` 结构体的指针；

    - 第2个参数是要绑定的参数索引值，索引值是从1（而不是0）开始的；

    - 第3个参数（如果有的话）是要赋值给参数的绑定值；

    - 第4个参数（如果有的话）是绑定值的字节长度，可以传递-1；

    - 第5个参数（如果有的话）是一个指向内存管理回调函数的指针。

      - 传递 NULL 或者 SQLITE_STATIC 常量，则 SQlite 会假定这块 buffer 是静态内存，或者客户应用程序会小心的管理和释放 buffer，所以 SQlite 放手不管。
      - 传递 SQLITE_TRANSIENT 常量，则 SQlite 会在内部复制这块 buffer 的内容。这就允许客户应用程序在调用完 bind 函数之后，立刻释放buffer（或者是一块栈上的 buffer 在离开作用域之后自动销毁）。SQlite 会自动在合适的时机释放它内部复制的 buffer。
      - 传递一个有效的 `void mem_callback(void *ptr)` 函数指针。当 SQlite 使用完这块 buffer 并打算释放它的时候，指针所指向的函数将会被调用。比如这块 buffer 是由 `sqlite3_malloc` 或 `sqlite3_realloc` 函数分配的，则可以直接传递 `sqlite3_free` 函数指针。如果是由其它系列的内存管理函数分配的内存，则应该传递其相应的内存释放函数。

  ```c
  // 整型值
  SQLITE_API int sqlite3_bind_int(sqlite3_stmt*, int, int);
  // 浮点值 
  SQLITE_API int sqlite3_bind_double(sqlite3_stmt*, int, double);
  // 文本值
  SQLITE_API int sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
  // NULL
  SQLITE_API int sqlite3_bind_null(sqlite3_stmt*, int);
  // BLOB类型
  SQLITE_API int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
  // ...
  ```

- 步进函数 **`sqlite3_step`** 执行 prepared 语句被传送到 SQlite3 的虚拟数据库引擎（VDBE：Virtual Database Engine）后的处理。

  - 返回 SQLITE_ROW，表示获得了有效数据行；
  - 返回 SQLITE_DONE，表示已经执行到终点；
  - 返回 SQLITE_BUSY，表示无法获取执行任务所需的数据库锁；
  - 返回 SQLITE_ERROR，表示执行过程中发生错误。
  - 返回 SQLITE_MISUSE，表示调用时机不正确，如已经被 finalize 。

  ```c
  SQLITE_API int sqlite3_stmt_busy(sqlite3_stmt*);
  ```

- 返回结果

  ```c
  // 获取列的数目
  SQLITE_API int sqlite3_column_count(sqlite3_stmt *pStmt);
  // 获取第N列的名称
  SQLITE_API const char *sqlite3_column_name(sqlite3_stmt*, int N);
  
  // 针对当前操作行，从给定列获取对应的存储数据
  SQLITE_API int sqlite3_column_int(sqlite3_stmt*, int iCol);
  //...
  ```

- 完成和重置：

  - 当 `sqlite3_step` 函数调用返回 SQLITE_DONE 时，则代表这条语句已经完成执行，这时如果还想重用这条 prepared 语句，就需要调用 `sqlite3_reset` 函数进行重置。
  - 在关闭数据库连接之前，对于不再使用的 prepared 语句，调用 `sqlite3_finalize` 函数进行销毁。

- 状态的转化

  - 一条语句可以处于不同状态：
    - ready：已经准备好执行，但还没有开始执行；
    - running：已经开始执行，但还没有完成；
    - done：已经执行完成。
  - 对于有些函数，只能在某条语句处于特定状态下才可以执行，比如 sqlite3_bind_xxx 函数，只有在一条语句处于“ready”状态时才可以被调用，否则函数将会返回 SQLITE_MISUSE 错误码。
    ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkl6ze7kb3j30r00e245p.jpg)

## 表

### 创建表

- SQLite 的 **CREATE TABLE** 语句用于在任何给定的数据库创建一个新表。

- 创建基本表，涉及到命名表、定义列及每一列的数据类型。

  ```objective-c
  const char *sql = "CREATE TABLE IF NOT EXISTS t_student (id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER NOT NULL)";
  char *error = NULL;
  int result = sqlite3_exec(_db, sql, NULL, NULL, &error);
  if (result == SQLITE_OK) {
      NSLog(@"创建表成功");
  }
  else {
      NSLog(@"创建表失败 %d %s", result, error);
  }
  ```

### 删除表

- SQLite 的 **DROP TABLE** 语句用来删除表定义及其所有相关数据、索引、触发器、约束和该表的权限规范。

  ```objective-c
  const char *sql = "DROP TABLE t_student";
  sqlite3_exec(_db, sql, NULL, NULL, NULL);
  ```

### 修改表

- SQLite 的 **ALTER TABLE** 语句用来修改已有的表，包括重命名表和在已有的表中添加额外的列。

  ```objective-c
  const char *sql = "ALTER TABLE t_student RENAME TO new_t_student";
  sqlite3_exec(_db, sql, NULL, NULL, NULL);
  
  const char *sql = "ALTER TABLE t_student ADD COLUMN sex char(1)";
  sqlite3_exec(_db, sql, NULL, NULL, NULL);
  ```
  
## 操作

### 插入数据

- SQLite 的 **INSERT INTO** 语句用于向数据库的某个表中添加新的数据行。

  ```objective-c
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
  ```

### 删除数据

- SQLite 的 **DELETE** 查询用于删除表中已有的记录。可以使用带有 WHERE 子句的 DELETE 查询来删除选定行，否则所有的记录都会被删除。

  ```objective-c
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
  ```

### 更新数据

- SQLite 的 **UPDATE** 查询用于修改表中已有的记录。可以使用带有 WHERE 子句的 UPDATE 查询来更新选定行，否则所有的行都会被更新。

  ```objective-c
  const char *sql = "UPDATE t_student SET name = ?1 WHERE age = ?2";
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
  ```

- SQLite 的 **SELECT** 语句用于从 SQLite 数据库表中获取数据，以结果表的形式返回数据。这些结果表也被称为结果集。

  ```objective-c
  const char *sql = "SELECT * FROM t_student";
  sqlite3_stmt *stmt = NULL;
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
  ```

# YYCache

- 优秀的缓存应该具备哪些特质？

  - 内存缓存和磁盘缓存
  - 线程安全：`YYMemoryCache` 使用了 `pthread_mutex` 线程锁来确保线程安全，而 `YYDiskCache` 则选择了更适合它的 `dispatch_semaphore`
  - 缓存清除策略：cost、count、age多维度
  - 缓存命中率：LRU
  - 性能：异步释放对象，锁的选择，缓存类对象，使用 CoreFoundation 框架
- **YYCache** 是由 `YYMemoryCache` 与 `YYDiskCache` 两部分组成的。
  - `YYMemoryCache` 提供容量小的内存缓存接口。
    - `_YYLinkedMap`：双向链表类，负责管理链表的增删改查。
    - `_YYLinkedMapNode`：链表的一个节点，存储缓存内容的 key，value，以及指向上一个节点和下一个节点的指针等
  - `YYDiskCache` 提供容量大的磁盘缓存接口。
    - `YYKVStorage`：磁盘缓存底层实现类，封装了增删改查给 `YYDiskCache` 层调用。
    - `YYKVStorageItem`：磁盘存储的缓存对象。
      ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkl6ze27dnj30gs09kweh.jpg)

## YYMemoryCache

- `YYMemoryCache` 负责处理容量小，相对高速的内存缓存。主要包括以下两个特点：

  - 使用 `CFMutableDictionaryRef _dic` 缓存数据，操作类似于 `NSCache`。

  - 从三个维度 count（缓存数量），cost（开销），age（距上一次的访问时间）上进行数据的清理策略，并在**双向链表**上实现 **LRU** 算法来淘汰（清理）使用频率较低的缓存。而 `NSCache` 的清除方式是非确定性的。

- 使用 `CFMutableDictionaryRef` 能避免 key 的 copy。而 `NSMutableDictionary` 的 key 会强制进行 copy，性能会有些损耗。

## YYDiskCache

- `YYDiskCache` 负责处理容量大，相对低速的磁盘缓存。主要包括以下两个特点：

  - 根据缓存数据的大小来采取不同的形式的缓存：
    - 数据库 sqlite：针对小容量缓存，缓存的 data 和元数据都保存在数据库里。
    - 文件+数据库的形式: 针对大容量缓存，缓存的 data 写在文件系统里，其元数据保存在数据库里。
  - 除了 cost，count 和 age 三个维度之外，还添加了一个磁盘容量的维度。

# 缓存淘汰策略

## LRU

- LRU（Least Recently Used，最近最久未使用）算法根据数据的历史访问**时间记录**来进行淘汰数据，其核心思想是“**如果数据最近被访问过，那么将来被访问的几率也更高**”。

  ![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkl6zedcbcj30l30g1dgi.jpg)
  

1. 最开始时，内存空间是空的，因此依次进入A、B、C是没有问题的。
2. 当加入D时，就出现了问题，内存空间不够了，因此根据LRU算法，内存空间中A待的时间最为久远，选择A将其淘汰。
3. 当再次引用B时，内存空间中的B又处于活跃状态，而C则变成了内存空间中近段时间最久未使用的。
4. 当再次向内存空间加入E时，这时内存空间又不足了，选择在内存空间中待的最久的C将其淘汰出内存，这时的内存空间存放的对象就是E->B->D。

- 最常见的实现是使用双向链表和哈希表保存缓存数据，哈希表用于快速获取数据，链表保证数据可按时间顺序快速遍历：

  - 新数据插入到链表头部；
  - 每当缓存命中（即缓存数据被访问），则将数据移到链表头部；
  - 当链表满的时候，将链表尾部的数据丢弃。
  
- LRU 对于循环出现的数据，缓存命中不高。比如这样的数据：1，1，1，2，2，2，3，4，1，1，1，2，2，2…..。当走到3，4的时候，1，2会被淘汰掉，但是后面还有很多1，2。

> 最近最常使用算法（MRU）：最近最常使用的项先被移除。

## LFU

- LFU（Least Frequently Used，最近最久未使用）算法根据数据的历史访问**次数记录**来进行淘汰数据，其核心思想是“**如果数据最近访问次数很少，那么将来被访问的几率也很小**”。

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkm718mrdhj30v00jydfy.jpg)

- 基于双向链表和哈希表的实现，设置和获取缓存的时间复杂度都是 O(n)，改进算法使用双哈希表实现。
  - 一个哈希表存储 key 和缓存，用于设置和获取数据。
  - 一个哈希表存储 count 和双向链表。

![](https://tva1.sinaimg.cn/large/0081Kckwgy1gkm74yjuyij30fc07rwf2.jpg)

- LFU对于交替出现的数据，缓存命中不高。比如这样的数据：1，1，1，2，2，3，4，3，4，3，4，3，4，3，4，3，4……。当走到3或4的时候，4或3会被淘汰掉，但是后面还有很多3，4。