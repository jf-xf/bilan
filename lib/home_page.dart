import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'db_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedType;
  String? selectedShip;
  List<String> shipList = [];

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  // 加载分类
  Future<void> _loadTypes() async {
    final db = DBHelper();
    final types = await db.getData('type_table');
    if (types.isEmpty) {
      // 插入测试数据
      final database = await db.database;
      await database.insert('type_table', {'name': '航空母舰'});
      await database.insert('type_table', {'name': '战列舰'});
      await database.insert('type_table', {'name': '航战'});
    }
    setState(() {});
  }

  // 根据类型加载舰船
  Future<void> _loadShips(String type) async {
    final db = DBHelper();
    List<Map<String, dynamic>> ships = [];
    if (type == '航空母舰') {
      ships = await db.getData('ship_air');
    } else if (type == '战列舰') {
      ships = await db.getData('ship_battle');
    } else if (type == '航战') {
      ships = await db.getData('ship_air_battle');
    }
    setState(() {
      shipList = ships.map((e) => e['name'].toString()).toList();
      selectedShip = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("舰船装备计算器"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("选择舰船类型"),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DBHelper().getData('type_table'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final types = snapshot.data!.map((e) => e['name'].toString()).toList();
                return DropdownSearch<String>(
                  items: types,
                  selectedItem: selectedType,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedType = val;
                      });
                      _loadShips(val);
                    }
                  },
                  popupProps: PopupProps.menu(showSearchBox: true),
                );
              },
            ),
            SizedBox(height: 20),
            Text("选择舰船"),
            DropdownSearch<String>(
              items: shipList,
              selectedItem: selectedShip,
              onChanged: (val) {
                setState(() {
                  selectedShip = val;
                });
              },
              popupProps: PopupProps.menu(showSearchBox: true),
            ),
            SizedBox(height: 20),
            if (selectedShip != null)
              Text("已选择舰船：$selectedShip", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
