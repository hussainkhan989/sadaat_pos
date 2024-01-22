import 'package:flutter/material.dart';
import 'Dbhelper.dart';
import 'lowstock.dart';

class TotalItemsPage extends StatefulWidget {
  @override
  _TotalItemsPageState createState() => _TotalItemsPageState();
}

class _TotalItemsPageState extends State<TotalItemsPage> {
  DBHelper dbHelper = DBHelper();
  double totalItems = 0;
  double totalStockPrice = 0;
  int numberOfUniqueItems = 0;
  double zakatAmount = 0.0;
  List<Item> lowStockItems = []; // Added this list

  @override
  void initState() {
    super.initState();
    loadTotalItems();
  }

  void loadTotalItems() async {
    List<Item> items = await dbHelper.queryAllItems();

    double itemCount = 0;
    double stockPrice = 0;

    Set<String> uniqueItemNames = Set();

    for (Item item in items) {
      itemCount += item.quantity;
      stockPrice += (item.quantity * item.buyPrice);
      uniqueItemNames.add(item.name);

      // Check for low stock items (customize the threshold as needed)
      if (item.quantity == 0) {
        lowStockItems.add(item);
      }
    }

    zakatAmount = stockPrice * 0.025;

    setState(() {
      totalItems = itemCount;
      totalStockPrice = stockPrice;
      numberOfUniqueItems = uniqueItemNames.length;
    });
  }

  void navigateToLowStockPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LowStockPage(lowStockItems: lowStockItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Items, Stock Price, and Zakat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Items, Stock Price, and Zakat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Number of Items: $totalItems',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Total Number of Unique Items: $numberOfUniqueItems',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Total Stock Price: $totalStockPrice',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Zakat Amount: ${zakatAmount.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToLowStockPage,
              child: Text('Low Stock Items'),
            ),
          ],
        ),
      ),
    );
  }
}
