import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sadaat_pos/profit.dart';
import 'Dbhelper.dart';

class ProfitPage extends StatefulWidget {
  final DateTimeRange selectedDateRange;

  ProfitPage({required this.selectedDateRange});

  @override
  _ProfitPageState createState() => _ProfitPageState();
}

class _ProfitPageState extends State<ProfitPage> {
  DBHelper dbHelper = DBHelper();
  double totalProfit = 0;
  double totalSalesAmount = 0;

  @override
  void initState() {
    super.initState();
    loadTotalProfitAndSales(widget.selectedDateRange);
  }

  void loadTotalProfitAndSales(DateTimeRange dateRange) async {
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(dateRange.start);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(dateRange.end);
    List<Sale> sales = await dbHelper.getSalesBetweenDates(formattedStartDate, formattedEndDate);

    double totalProfits = 0;
    double totalAmount = 0;

    for (Sale sale in sales) {
      totalProfits += (sale.prof ?? 0) * sale.quantitySold;
      totalAmount += sale.soldprice * sale.quantitySold;
    }

    setState(() {
      totalProfit = totalProfits;
      totalSalesAmount = totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Profit and Sales Amount'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Profit and Sales Amount for ${DateFormat('yyyy-MM-dd').format(widget.selectedDateRange.start)} to ${DateFormat('yyyy-MM-dd').format(widget.selectedDateRange.end)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Profit: $totalProfit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Total Sales Amount: $totalSalesAmount',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
