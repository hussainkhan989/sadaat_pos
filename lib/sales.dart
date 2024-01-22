import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sadaat_pos/profit.dart';
import 'Dbhelper.dart';
class sales extends StatefulWidget {
  @override
  State<sales> createState() => _salesState();
}

class _salesState extends State<sales> {
  DBHelper dbHelper = DBHelper();
  List<Sale> sales = [];
  late DateTimeRange selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now(),
    );
    loadSalesData(selectedDateRange);
  }

  void loadSalesData(DateTimeRange dateRange) async {
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(dateRange.start);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(dateRange.end);
    List<Sale> loadedSales = await dbHelper.getSalesBetweenDates(formattedStartDate, formattedEndDate);
    setState(() {
      sales = loadedSales;
    });
  }

  void removeSaleFromList(int saleId) {
    setState(() {
      sales.removeWhere((sale) => sale.id == saleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTimeRange? pickedDateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDateRange: selectedDateRange,
                  );
                  if (pickedDateRange != null && pickedDateRange != selectedDateRange) {
                    setState(() {
                      selectedDateRange = pickedDateRange;
                      loadSalesData(selectedDateRange);
                    });
                  }
                },
                child: Text('Select Date Range'),
              ),
              SizedBox(width: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfitPage(selectedDateRange: selectedDateRange),
                    ),
                  );
                },
                child: Text('Today Profit'),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                return SaleCard(
                  sale: sales[index],
                  onSaleDeleted: () => removeSaleFromList(sales[index].id!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onSaleDeleted;

  SaleCard({required this.sale, required this.onSaleDeleted});

  final DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete this sale?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          ) ?? false;

          if (confirm) {
            Item? item = await dbHelper.getItemByName(sale.itmname);
            if (item != null) {
              item.quantity += sale.quantitySold;
              await dbHelper.updateItem(item);
            }
            if (sale.id != null) {
              await dbHelper.deleteSale(sale.id!);
              onSaleDeleted();
              print('Sale deleted and item quantity updated for ${sale.itmname}');
            }
          }
        },
       // leading: Text(sale.itmname, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        title: Text( sale.itmname , style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold)),
        subtitle: Text('sold price: ${sale.soldprice * sale.quantitySold} \nProfit: ${sale.prof * sale.quantitySold} ' , style: TextStyle(fontSize: 15)),
        trailing: Text('Quantity: ${sale.quantitySold}', style: TextStyle(fontSize: 15)),
      ),
    );
  }
}
