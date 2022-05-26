

import 'dart:io';

import 'package:Fiszki/Word.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper{

  static DatabaseHelper databaseHelper;
  static Database _database;

  String myTable = "listOfLists";
  String colId = "id";
  String colEnglishWord = "englishWord";
  String colPolishWord = "polishWord";
  String nameToCreate = "words";

  DatabaseHelper.createInstance();

  factory DatabaseHelper(){
    if(databaseHelper==null){
      databaseHelper = DatabaseHelper.createInstance();
    }

    return databaseHelper;
  }

  Future<Database> get database async{
    _database = await initialiseDatabase();

    return _database;
  }

  Future<Database> initialiseDatabase([name]) async{
    if(name!=null)myTable = name;

    Directory directory = await getApplicationDocumentsDirectory();

    String path = directory.path+'$myTable.db';
    var myDB = await openDatabase(path,version: 1,onCreate: createDB);

    return myDB;
  }

  void createDB(Database db, int newVersion)async{
    print(myTable);

    await db.execute('CREATE TABLE $myTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colEnglishWord TEXT, $colPolishWord TEXT)');

  }

  Future<List<Map<String, dynamic>>> getItemsMapList(String name) async{
    Database db = await this.database;
    var result = await db.query(name);
    return result;
  }

  Future<int> insertItem(Word word, String name)async{
    Database db = await this.database;
    print(word.toMap());
    var result = await db.insert(name, word.toMap());
    return result;
  }

  Future<int> updateItem(Word word, String name)async{
    var db = await this.database;
    var result = await db.update(name, word.toMap(), where: '$colId=?',
        whereArgs: [word.id]);
    return result;
  }

  Future<int> deleteItem(int id, String name)async{
    var db = await this.database;
    var result = await db.delete(name, where: '$colId=$id');
    return result;
  }

  Future<List<Word>> getItemsList(String name) async{
    List<Map<String, dynamic>> itemsMapList = await getItemsMapList(name);
    List<Word> itemsList = List<Word>();
    for(int i=0;i<itemsMapList.length;i++){
      itemsList.add(Word.fromMap(itemsMapList[i]));
    }
    return itemsList;
  }
}