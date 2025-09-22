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
  String? selectedStar;
  String? selectedFavor;
  String? selectedBuff;
  String? selectedCat;
  String? selectedAxis;

  int inputLevel = 1;
  double calculatedReload = 0;
  double panelTime = 0;
  double realTime = 0;

  List<Map<String, dynamic>> shipSlots = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('舰船装备计算器'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedType,
              hint: Text('选择类型'),
              items: ['航', '战', '航战']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) async {
                setState(() {
                  selectedType = val;
                  selectedShip = null;
                  shipSlots = [];
                });
              },
            ),
            SizedBox(height: 8),
            DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSearchBox: true,
              label: "船名",
              onFind: (filter) async {
                if (selectedType == null) return [];
                final table = selectedType == '航'
                    ? 'ship_air'
                    : selectedType == '战'
                        ? 'ship_battle'
                        : 'ship_airbattle';
                final rows = await DBHelper().getTable(table);
                return rows
                    .map((e) => e['name'] as String)
                    .where((s) =>
                        s.toLowerCase().contains(filter.toLowerCase()))
                    .toList();
              },
              onChanged: (val) async {
                setState(() {
                  selectedShip = val;
                });
                await loadShipSlots();
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: '等级'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  inputLevel = int.tryParse(val) ?? 1;
                });
                calculateReload();
              },
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedStar,
              hint: Text('星级'),
              items: ['1', '2', '3']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedStar = val),
            ),
            SizedBox(height: 8),
            Text('装填: $calculatedReload'),
            SizedBox(height: 8),
            // 动态装备槽位
            ...shipSlots.map((slot) {
              return DropdownSearch<String>(
                mode: Mode.BOTTOM_SHEET,
                showSearchBox: true,
                label: slot['slot_type'],
                onFind: (filter) async {
                  return await loadEquipOptions(slot['slot_type']);
                },
                onChanged: (val) {},
              );
            }).toList(),
            SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedFavor,
              hint: Text('好感'),
              items: ['爱', '喜欢', '普通']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedFavor = val),
            ),
            DropdownButton<String>(
              value: selectedBuff,
              hint: Text('Buff'),
              items: ['首轮CD减少', '装填增加']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedBuff = val),
            ),
            DropdownButton<String>(
              value: selectedCat,
              hint: Text('猫'),
              items: ['猫A', '猫B', '猫C']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedCat = val),
            ),
            DropdownButton<String>(
              value: selectedAxis,
              hint: Text('轴'),
              items: ['无', '20s', '26s']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedAxis = val),
            ),
            SizedBox(height: 12),
            Text('面板时间: $panelTime'),
            Text('实际时间: $realTime'),
          ],
        ),
      ),
    );
  }

  Future<void> loadShipSlots() async {
    if (selectedType == null || selectedShip == null) return;
    final table = selectedType == '航'
        ? 'ship_air'
        : selectedType == '战'
            ? 'ship_battle'
            : 'ship_airbattle';
    final rows = await DBHelper().getTable(table);
    final ship = rows.firstWhere((e) => e['name'] == selectedShip);
    setState(() {
      shipSlots = [];
      for (var i = 1; i <= 3; i++) {
        if (ship['slot${i}_type'] != null &&
            (ship['slot${i}_type'] as String).isNotEmpty) {
          shipSlots.add({
            'slot_type': ship['slot${i}_type'],
            'slot_count': ship['slot${i}_count']
          });
        }
      }
    });
  }

  Future<List<String>> loadEquipOptions(String slotType) async {
    final db = DBHelper();
    if (slotType == '主炮') {
      final rows = await db.getTable('gun');
      return rows.map((e) => e['name'] as String).toList();
    } else if (slotType.contains('战斗机') ||
        slotType.contains('鱼雷机') ||
        slotType.contains('轰炸机') ||
        slotType == '舰载机' ||
        slotType.contains('+')) {
      final rows = await db.getTable('plane');
      if (slotType == '舰载机') return rows.map((e) => e['name'] as String).toList();
      else if (slotType.contains('+')) {
        final types = slotType.split('+');
        return rows
            .where((e) => types.contains(e['type']))
            .map((e) => e['name'] as String)
            .toList();
      } else {
        return rows
            .where((e) => e['type'] == slotType)
            .map((e) => e['name'] as String)
            .toList();
      }
    }
    return [];
  }

  void calculateReload() {
    // 占位公式：线性插值 + 好感百分比
    if (selectedType == null || selectedShip == null) return;
    final table = selectedType == '航'
        ? 'ship_air'
        : selectedType == '战'
            ? 'ship_battle'
            : 'ship_airbattle';
    DBHelper().getTable(table).then((rows) {
      final ship = rows.firstWhere((e) => e['name'] == selectedShip);
      final levelLow = 1;
      final levelHigh = 100;
      final reloadLow = ship['level1'] ?? 100;
      final reloadHigh = ship['level100'] ?? 120;
      final favorPercent = selectedFavor == '爱'
          ? 0.05
          : selectedFavor == '喜欢'
              ? 0.03
              : 0.0;
      final base = reloadLow + (reloadHigh - reloadLow) * (inputLevel - levelLow) / (levelHigh - levelLow);
      setState(() {
        calculatedReload = base * (1 + favorPercent);
        panelTime = calculatedReload; // 占位
        realTime = panelTime; // 占位
      });
    });
  }
}
