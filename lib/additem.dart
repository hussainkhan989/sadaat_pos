import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'Dbhelper.dart';

class additem extends StatefulWidget {  @override
  State<additem> createState() => _additemState();
}

class _additemState extends State<additem> {
  var item = TextEditingController();
  var quantity = TextEditingController();
  var buyprice = TextEditingController();
  var sellprice = TextEditingController();
  var toast = "";
  var it;

  DBHelper dbHelper = DBHelper();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Add items'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(toast, style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              Container(
                child: TextField(
                  controller: item,
                  decoration: InputDecoration(
                      label: Text('item Name'),
                      icon: Icon(Icons.add),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: quantity,
                  decoration: InputDecoration(
                      label: Text('item quantity'),
                      icon: Icon(Icons.ad_units),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: buyprice,
                  decoration: InputDecoration(
                      label: Text('buying price'),
                      icon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: sellprice,
                  decoration: InputDecoration(
                      label: Text('Selling price'),
                      icon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      )
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(width:120, height: 80,
                  child: ElevatedButton(onPressed: ()
                  async {
                    try{
                    if(item.text.isNotEmpty && quantity.text.toString().isNotEmpty&& buyprice.text.toString().isNotEmpty && sellprice.text.toString().isNotEmpty){
                    Item newItem = Item(
                      name: item.text.toString(),
                      quantity:double.parse(quantity.text.toString()),
                      buyPrice: double.parse(buyprice.text.toString()),
                      sellingPrice: double.parse(sellprice.text.toString()),
        
                    );
                    int insertedId = await dbHelper.insertItem(newItem);
                    await Flushbar(
        
                      title: item.text.toString() ,
                      message: 'Is Sucessfully added in the database',
                      duration: Duration(seconds: 4),
        
                    ).show(context);
                    print('Inserted Item ID: $insertedId');
                    setState(() {
                      var it = item.text.toString();
                    });}
                    else{
                      await Flushbar(
                        title: 'One of the field is empty',
                        message: ' ',
                        duration: Duration(seconds: 4),
        
                      ).show(context);
                      setState(() {
                      });
                    }
                    }
                    catch (e){
                      if (e is DatabaseException && e.isUniqueConstraintError()) {
                        // Handle the unique constraint violation (e.g., show an error message)
                        await Flushbar(
        
                          title: item.text.toString(),
                          flushbarPosition: FlushbarPosition.TOP,
                          message: 'Item with same name already exist!',
                          duration: Duration(seconds: 4),
                        ).show(context);
                        print('Error: An item with the same name already exists!');
                         // Or any other custom error code
                      } else {
                        // Rethrow the exception if it's not a unique constraint violation
                        rethrow;
                      }
                    }
        
                  }, child: Text('Add to Stock')))
            ],
          ),
        ),
      ),
    );

    }


}