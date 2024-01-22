// low_stock_page.dart

import 'package:flutter/material.dart';
import 'Dbhelper.dart';

class LowStockPage extends StatelessWidget {
  final List<Item> lowStockItems;

  LowStockPage({required this.lowStockItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Low Stock Items'),
      ),
      body: ListView.builder(
        itemCount: lowStockItems.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3, // Adjust the elevation for a shadow effect
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                lowStockItems[index].name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Quantity: ${lowStockItems[index].quantity}'),
              // Add more details as needed
            ),
          );
        },
      ),
    );
  }
}
