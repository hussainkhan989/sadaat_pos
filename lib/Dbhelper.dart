import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Sale {
  int? id;
  int itemId;
  double quantitySold;
  String saleDate;
  String itmname;
  double soldprice;
  double prof;

  Sale({
    this.id,
    required this.itemId,
    required this.quantitySold,
    required this.saleDate,
    required this.itmname,
    required this.soldprice,
    required this.prof,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'quantitySold': quantitySold,
      'saleDate': saleDate,
      'itmname' : itmname,
      'soldprice' : soldprice,
      'prof' : prof,
    };
  }

  Sale.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        itemId = map['itemId'],
        quantitySold = map['quantitySold'],
        saleDate = map['saleDate'],
        itmname = map['itmname'],
        soldprice = map['soldprice'],
        prof = map['prof'];

}

class Item {
  int? id;
  String name;
  double quantity;
  double buyPrice;
  double sellingPrice;
  double? profit;

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.buyPrice,
    required this.sellingPrice,
    this.profit,
  });
  Item.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        quantity = map['quantity'],
        buyPrice = map['buyPrice'],
        sellingPrice = map['sellingPrice'],
        profit = map['profit'];
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;


  DBHelper._internal();

  Database? _database;


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final String path = join(await getDatabasesPath(), 'lop.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version to trigger migration
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await migrateTables(db);
        }
      },
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY,profit INTEGER, name TEXT UNIQUE, quantity DOUBLE, buyPrice INTEGER, sellingPrice INTEGER)',
        );
      },
    );
  }

  Future<void> migrateTables(Database db) async {
    // Migrate the items table
    await db.execute('CREATE TABLE items_new(id INTEGER PRIMARY KEY, name TEXT UNIQUE, quantity DOUBLE, buyPrice DOUBLE, sellingPrice DOUBLE, profit DOUBLE)');
    await db.execute('INSERT INTO items_new SELECT id, name, quantity, buyPrice, sellingPrice, profit FROM items');
    await db.execute('DROP TABLE items');
    await db.execute('ALTER TABLE items_new RENAME TO items');

    // Migrate the sales table
    await db.execute('CREATE TABLE sales_new(id INTEGER PRIMARY KEY, itemId INTEGER, quantitySold DOUBLE, saleDate TEXT, itmname TEXT, soldprice DOUBLE, prof DOUBLE)');
    await db.execute('INSERT INTO sales_new SELECT id, itemId, quantitySold, saleDate, itmname, soldprice, prof FROM sales');
    await db.execute('DROP TABLE sales');
    await db.execute('ALTER TABLE sales_new RENAME TO sales');
  }

  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert(
      'items',
      {
        'name': item.name,
        'quantity': item.quantity,
        'buyPrice': item.buyPrice,
        'sellingPrice': item.sellingPrice,
        'profit' : item.profit,
      },
    );
  }
  Future<List<Item>> queryAllItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Item(
        id: maps[i]['id'],
        name: maps[i]['name'],
        quantity: maps[i]['quantity'],
        buyPrice: maps[i]['buyPrice'],
        sellingPrice: maps[i]['sellingPrice'],
        profit: maps[i]['profit'],
      );
    });
  }

  Future<int> updateItem(Item item) async {
    Database db = await database;
    return await db.update(
      'items',
      {
        'name': item.name,
        'quantity': item.quantity,
        'buyPrice': item.buyPrice,
        'sellingPrice': item.sellingPrice,
        'profit' : item.profit,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Item?> getItemByName(String name) async {
    await initDatabase();
    List<Map<String, Object?>>? maps = await _database?.query(
      'items',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps!.isNotEmpty) {
      return Item.fromMap(maps.first);
    }
    return null;
  }

  //from here dailysales table starts


  Future<void> createSalesTable(Database db) async {
    await db.execute(
      'CREATE TABLE sales(id INTEGER PRIMARY KEY, prof INTEGER,soldprice INTEGER, itmname TEXT, itemId INTEGER, quantitySold INTEGER, saleDate DATE)',
    );
  }

  Future<int> insertSale(Sale sale) async {
    Database db = await database;
    //await createSalesTable(db);

    // Format the saleDate to include only the date part
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(sale.saleDate));

    return await db.insert(
      'sales',
      {
        'itemId': sale.itemId,
        'quantitySold': sale.quantitySold,
        'saleDate': formattedDate,
        'itmname' : sale.itmname,
        'soldprice' : sale.soldprice,
        'prof' : sale.prof,
      },
    );
  }


  Future<List<Sale>> queryAllSales() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('sales');
    return List.generate(maps.length, (i) {
      return Sale(
        id: maps[i]['id'],
        itemId: maps[i]['itemId'],
        quantitySold: maps[i]['quantitySold'],
        saleDate: maps[i]['saleDate'],
        itmname: maps[i]['itmname'],
        soldprice: maps[i]['soldprice'],
        prof: maps[i]['prof'],
      );
    });
  }

  Future<List<Sale>> getDailySales(String saleDate) async {
    Database db = await database;

    // Format the saleDate to include only the date part
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(saleDate));

    List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'saleDate = ?',
      whereArgs: [formattedDate],
    );
    return List.generate(maps.length, (i) {
      return Sale(
        id: maps[i]['id'],
        itemId: maps[i]['itemId'],
        quantitySold: maps[i]['quantitySold'],
        saleDate: maps[i]['saleDate'],
        itmname: maps[i]['itmname'],
        soldprice: maps[i]['soldprice'],
        prof: maps[i]['prof'],
      );
    });
  }
  Future<int> deleteSale(int id) async {
    Database db = await database;
    return await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // Add this method to your DBHelper class
  Future<List<Sale>> getSalesBetweenDates(String startDate, String endDate) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'saleDate BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    return List.generate(maps.length, (i) {
      return Sale(
        id: maps[i]['id'],
        itemId: maps[i]['itemId'],
        quantitySold: maps[i]['quantitySold'],
        saleDate: maps[i]['saleDate'],
        itmname: maps[i]['itmname'],
        soldprice: maps[i]['soldprice'],
        prof: maps[i]['prof'],
      );
    });
  }

}

// Ensure to adjust the rest of your DBHelper class and any other parts of your code that interact with the Item class to handle the quantity as a double.
