import 'package:flutter/material.dart';
import 'db_helper.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String password = '';
  bool isLoggedIn = false;
  bool isSecondary = false; // 二级密码标识

  final TextEditingController _tableNameController = TextEditingController();
  final TextEditingController _columnNameController = TextEditingController();
  final TextEditingController _columnTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text('设置 - 登录')),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: '输入密码'),
                onChanged: (val) => password = val,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                child: Text('登录'),
                onPressed: () {
                  if (password == '123456') {
                    setState(() {
                      isLoggedIn = true;
                      isSecondary = false;
                    });
                  } else if (password == 'jfxf') {
                    setState(() {
                      isLoggedIn = true;
                      isSecondary = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('密码错误')));
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    // 登录后显示设置页面
    return Scaffold(
      appBar: AppBar(title: Text('设置 - 已登录')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('已登录：${isSecondary ? "二级密码" : "一级密码"}'),
              SizedBox(height: 12),
              if (!isSecondary)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('修改数据库表内容（一级权限）'),
                    // 示例：修改船表的装填
                    TextField(
                      controller: _tableNameController,
                      decoration: InputDecoration(
                          labelText: '表名 (例如 ship_air)'),
                    ),
                    TextField(
                      controller: _columnNameController,
                      decoration: InputDecoration(labelText: '列名 (例如 reload)'),
                    ),
                    TextField(
                      controller: _columnTypeController,
                      decoration: InputDecoration(labelText: '新值'),
                    ),
                    ElevatedButton(
                      child: Text('修改'),
                      onPressed: () async {
                        final table = _tableNameController.text;
                        final column = _columnNameController.text;
                        final value = _columnTypeController.text;
                        final db = await DBHelper().database;
                        await db.rawUpdate(
                            'UPDATE $table SET $column=?', [value]);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('修改完成')));
                      },
                    ),
                  ],
                ),
              if (isSecondary)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('新建表格（含动态列，二级权限）'),
                    TextField(
                      controller: _tableNameController,
                      decoration: InputDecoration(labelText: '新表名'),
                    ),
                    TextField(
                      controller: _columnNameController,
                      decoration: InputDecoration(labelText: '列名1,列名2,...'),
                    ),
                    TextField(
                      controller: _columnTypeController,
                      decoration: InputDecoration(
                          labelText: '列类型1,列类型2,... (TEXT, INTEGER, REAL)'),
                    ),
                    ElevatedButton(
                      child: Text('创建新表'),
                      onPressed: () async {
                        final table = _tableNameController.text;
                        final cols = _columnNameController.text.split(',');
                        final types = _columnTypeController.text.split(',');
                        if (cols.length != types.length) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('列名和列类型数量不匹配')));
                          return;
                        }
                        final colDefs = List.generate(
                            cols.length, (i) => '${cols[i]} ${types[i]}');
                        final sql =
                            'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT, ${colDefs.join(', ')})';
                        final db = await DBHelper().database;
                        await db.execute(sql);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('表 $table 创建完成')));
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
