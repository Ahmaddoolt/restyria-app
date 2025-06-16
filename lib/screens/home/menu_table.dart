import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gustoro/shared/app_colors.dart';

class MenuTablePage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuTablePage({Key? key, required this.menuItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(menuItems);
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Menu Items'.tr),
        backgroundColor: mainColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use SingleChildScrollView for horizontal scrolling on smaller screens
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                    label: Text(
                  'Image'.tr,
                  style: TextStyle(color: accentColor),
                )),
                DataColumn(
                    label: Text('Name'.tr, style: TextStyle(color: accentColor))),
                DataColumn(
                    label: Text('Price'.tr, style: TextStyle(color: accentColor))),
                DataColumn(
                    label: Text('AfterDis%'.tr, style: TextStyle(color: accentColor))),
              ],
              rows: menuItems.map((item) {
                bool hasDiscount = item['priceAfterDiscount'] != null;

                return DataRow(
                  color: hasDiscount
                      ? MaterialStateProperty.all(accentColor.withOpacity(0.3))
                      : MaterialStateProperty.all(Colors.transparent),
                  cells: [
                    DataCell(
                      item['imageUrl'] != null
                          ? Image.network(item['imageUrl'],
                              height: 40, width: 50, fit: BoxFit.cover)
                          : const Icon(
                              Icons.image,
                              size: 50,
                            ),
                    ),
                    DataCell(Text(item['name'] ?? 'Unknown')),
                    DataCell(Text(item['price']?.toStringAsFixed(1) ?? '0.00')),
                    DataCell(Text(
                        '${item['priceAfterDiscount']?.toStringAsFixed(1) ?? '--------'}')),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
