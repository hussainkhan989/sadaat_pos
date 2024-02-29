import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sadaat_pos/additem.dart';
import 'package:sadaat_pos/sales.dart';
import 'package:sadaat_pos/zakat.dart';

import 'Dbhelper.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sadaat Autos',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue , foregroundColor: Colors.white),
        primarySwatch: Colors.blue,
        cardColor: Colors.green,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DBHelper dbHelper = DBHelper();

  int _selectedIndex = 0;
  var itemname = TextEditingController();
  var amtrecieved = TextEditingController();
  var q = TextEditingController();
  TextEditingController quantity = TextEditingController();
  var price, sellprice, quan = "";
  var sctitm = "";
  var salee = "";
  double opacity = 1.0;
  Color buttonColor = Colors.green;

  Future<void> handleSoldButtonClick() async {
    String itemName = itemname.text.trim();
    Item? selectedItem = await dbHelper.getItemByName(sctitm);

    if (selectedItem != null && selectedItem.quantity > 0 && amtrecieved.text.toString().isNotEmpty) {
      double profi = double.parse(amtrecieved.text.toString()) - selectedItem.buyPrice;
      print("vaue is $profi");

      salee = "is sold on price of ${amtrecieved.text.toString()}";
      await Flushbar(
        title: sctitm.toString(),
        message: salee,
        duration: Duration(seconds: 3),
      ).show(context);

      setState(() {
        opacity = 0.5;
        buttonColor = Colors.green.withOpacity(0.5);
      });

      await dbHelper.updateItem(
        Item(
          id: selectedItem.id,
          name: selectedItem.name,
          quantity: selectedItem.quantity - double.parse(q.text.toString()),
          buyPrice: selectedItem.buyPrice,
          sellingPrice: selectedItem.sellingPrice,
          profit: profi,
        ),
      );

      DateTime currentDate = DateTime.now();
      String formattedDate = DateTime.now().toString();
      await dbHelper.insertSale(
        Sale(
          itemId: selectedItem.id!,
          quantitySold: double.parse(q.text.toString()),
          saleDate: formattedDate,
          itmname: selectedItem.name,
          soldprice: double.parse(amtrecieved.text.toString()),
          prof: profi,
        ),
      );

      setState(() {
        // Update the UI to reflect the change in item quantity after sale
        price = selectedItem.buyPrice.toString();
        sellprice = selectedItem.sellingPrice.toString();
        quan = selectedItem.quantity.toString();
      });

    } else {
      await Flushbar(
        title: sctitm.toString(),
        message: "is maybe out of Stock or you didnt add Amount received",
        duration: Duration(seconds: 5),
      ).show(context);
    }
  }



  /*Future<void> handleReturnButtonClick() async {
    // Remove the code that checks for today's sales
    Item? selectedItem = await dbHelper.getItemByName(sctitm);

    if (selectedItem != null) {
      await dbHelper.deleteSale(selectedItem.id!);

      await dbHelper.updateItem(
        Item(
          id: selectedItem.id,
          name: selectedItem.name,
          quantity: selectedItem.quantity + int.parse(q.text.toString()),
          buyPrice: selectedItem.buyPrice,
          sellingPrice: selectedItem.sellingPrice,
          profit: selectedItem.profit,
        ),
      );

      await Flushbar(
        title: sctitm.toString(),
        message: "is returned",
        duration: Duration(seconds: 3),
      ).show(context);

      setState(() {
        opacity = 0.5;
        buttonColor = Colors.red.withOpacity(0.5);
      });

      setState(() {
        opacity = 1.0;
        buttonColor = Colors.red;
      });
    } else {
      await Flushbar(
        title: sctitm.toString(),
        message: "cannot be returned as it was not sold today",
        duration: Duration(seconds: 5),
      ).show(context);
    }
  }*/


  /*bool isButtonRed() {
    if (amtrecieved.text.isNotEmpty) {
      int enteredAmount = int.parse(amtrecieved.text);
      int sellingPrice = int.parse(sellprice);
      return enteredAmount < sellingPrice;
    }
    return false;
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShopEase Retail POS'),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                TypeAheadField <Item>(textFieldConfiguration: const TextFieldConfiguration(
                  decoration: InputDecoration(
                    labelText: 'Search for items',
                    border: OutlineInputBorder(),
                  ),
                ),
                  suggestionsCallback: (pattern) async {
                    // Filter items based on the typed text
                    final items = await dbHelper.queryAllItems();
                    return items
                        .where((item) =>
                        item.name.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, Item suggestion) {
                    return ListTile(
                      title: Text(suggestion.name),
                      subtitle: Text('Quantity: ${suggestion.quantity}'),
                      // Add more details as needed
                    );
                  }, onSuggestionSelected: (Item suggestion) async {
                    // String itemNames = itemname.text.trim();
                    Item? selectedItem = await dbHelper.getItemByName(suggestion.name);
                    if (selectedItem != null) {
                      // Do something with the selected item
                      price = selectedItem.buyPrice.toString();
                      sellprice = selectedItem.sellingPrice.toString();
                      quan = selectedItem.quantity.toString();
                      sctitm = selectedItem.name;

                      setState(() {
                        // Update the UI with the selected item's details
                      });
                    } else {
                      // Handle when the item is not found
                    }
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  sctitm,
                  style: const TextStyle(fontSize: 50, color: Colors.blue),
                ),
               // SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: GridView.count(
                    children: [
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: Duration(milliseconds: 500),
                        child: Text('Buying Price: $price', style: TextStyle(color: Colors.green)),
                      ),
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: Duration(milliseconds: 500),
                        child: Text('Selling Price: $sellprice', style: TextStyle(color: Colors.orange)),
                      ),
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: Duration(milliseconds: 500),
                        child: Text('Quantity Available: $quan', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                    crossAxisCount: 3,
                  ),
                ),
               //This line of code is replaced it show code using container
               /* Container(
                  width: double.infinity,
                  height: 150,
                  padding: EdgeInsets.all(10), // Add padding for better layout
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space items evenly in the column
                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start of the column
                    children: <Widget>[
                      Text(
                        'Item: $sctitm',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Price: ${price.toString()}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Selling Price: ${sellprice.toString()}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Quantity: $quan',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),*/

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: TextField(controller:amtrecieved,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              // Update the UI based on the entered amount in real-time
                              // Now, the button color will change as you type in the amount received
                            });
                          },
                          decoration: InputDecoration(
                              label: (const Text("Amount Recieved")),
                              icon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))

                          ),),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                        width: 250,
                        child: TextField(controller:q,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              // Update the UI based on the entered amount in real-time
                              // Now, the button color will change as you type in the amount received
                            });
                          },
                          decoration: InputDecoration(
                              label: (const Text("Quantity")),
                              icon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))

                          ),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 0),
                    SizedBox(
                      height: 80,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Text color
                          elevation: 10, // Shadow elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Button border radius
                          ),),
                        onPressed: handleSoldButtonClick,
                        child: const Text('Sold' , style: TextStyle(fontSize: 15),),
                      ),

                    ),

                    const SizedBox(width: 10),
                   /* Container(
                      height: 80,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: isButtonRed() ? Colors.red : Colors.green,
                        ),
                        onPressed: handleReturnButtonClick,
                        child: Text('Return'),
                      ),
                    ),*/

                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Add Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Sales/profit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility),
            label: 'Inventory',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add your logic based on the selected index here
      switch (index) {
        case 0:
        // Handle Home click
          break;
        case 1:
        // Handle Business click
          Navigator.push(context, MaterialPageRoute(builder: (context) => additem(),));
          break;
        case 2:
        // Handle School click
          Navigator.push(context, MaterialPageRoute(builder: (context) => sales(),));
          break;
        case 3:
        // Handle School click
          Navigator.push(context, MaterialPageRoute(builder: (context) => ItemListScreen(),));
          break;

        //case 3:
        // Handle School click
          //Navigator.push(context, MaterialPageRoute(builder: (context) => SalesList(),));
          //break;
      }
    });
  }


  }

