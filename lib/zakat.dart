import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sadaat_pos/profit.dart';
import 'package:sadaat_pos/totalstock.dart';
import 'Dbhelper.dart';

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  DBHelper dbHelper = DBHelper();

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
      ),
      body: Column(
        children: [
          Container(
            width: 300,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TotalItemsPage()),
                );
              },
              child: Text('Total Stock'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TypeAheadFormField<Item?>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search for items',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                final items = await dbHelper.queryAllItems();
                return items
                    .where((item) =>
                    item.name.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion!.name),
                  subtitle: Text('Quantity: ${suggestion.quantity}'),
                  trailing: Text('Price: ${suggestion.buyPrice}'),
                );
              },
              onSuggestionSelected: (suggestion) {
                _searchController.text = suggestion!.name;
                _showItemDetailsPopup(suggestion);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: dbHelper.queryAllItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No items found'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Item item = snapshot.data![index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          onTap: () => _showItemDetailsPopup(item),
                          title: Text(
                            item.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text('Price: ${item.buyPrice}'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetailsPopup(Item item) {
    TextEditingController nameController = TextEditingController(text: item.name);
    TextEditingController quantityController =
    TextEditingController(text: item.quantity.toString());
    TextEditingController buyPriceController =
    TextEditingController(text: item.buyPrice.toString());
    TextEditingController sellingPriceController =
    TextEditingController(text: item.sellingPrice.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Item Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Name:'),
                TextField(
                  controller: nameController,
                ),
                Text('Quantity:'),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                ),
                Text('Buy Price:'),
                TextField(
                  controller: buyPriceController,
                  keyboardType: TextInputType.number,
                ),
                Text('Selling Price:'),
                TextField(
                  controller: sellingPriceController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Item updatedItem = Item(
                    id: item.id,
                    name: nameController.text,
                    quantity: double.parse(quantityController.text),
                    buyPrice: double.parse(buyPriceController.text),
                    sellingPrice: double.parse(sellingPriceController.text),
                    profit: item.profit,
                  );
                  await dbHelper.updateItem(updatedItem);
                  Navigator.pop(context);
                  Flushbar(
                    message: 'is updated',
                    title: nameController.text,
                    duration: Duration(seconds: 4),
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                },
                child: Text('Update'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await dbHelper.deleteItem(item.id!);
                  Navigator.pop(context);
                  Flushbar(
                    message: 'is deleted',
                    title: nameController.text,
                    duration: Duration(seconds: 4),
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text('Delete'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ItemListScreen(),
  ));
}
