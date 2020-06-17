import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/submissionRo.dart'; //repossess order class
import '../models/roCloud.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  //// creating table and column for data to be uploaded ///////
  String subTable = 'submissionRo_table';
  String colSubId = 'subId';
  String colRoCloseCaseStatus = 'closeCaseStatus';
  String colRoIDforeign ='roID';
  ///**** Successful repo columns ****/
  String colDropList1 = 'droplist1';
  String colDropList2 = 'droplist2';
  String colDropList3 = 'droplist3';
  String colComment = 'comment';
  String colImg1 = 'image1';
  String colImg2 = 'image2';
  String colImg3 = 'image3';
  String colImg4 = 'image4';
  String colImg5 = 'image5';

  ///**** Unsuccessful repo columns ****/
  String colCheckBox = 'checkBoxes';
  /*String colCheckBox1 = 'Not_at_address';
  String colCheckBox2 = 'Protected_by_gangster';
  String colCheckBox3 = 'No_such_address';
  String colCheckBox4 = 'Hirer_shifted';
  String colCheckBox5 = 'Stolen';*/

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'repo.db';

    var roDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb);
    return roDatabase;
  }





  //create table function
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $subTable($colSubId INTEGER PRIMARY KEY AUTOINCREMENT, $colDropList1 TEXT, "
            "$colDropList2 TEXT, $colDropList3 TEXT, $colComment TEXT, $colImg1 TEXT, $colImg2 TEXT, $colImg3 TEXT, $colImg4 TEXT, $colImg5 TEXT, "
            "$colCheckBox TEXT,  $colRoCloseCaseStatus TEXT, $colRoIDforeign TEXT)");

    debugPrint('Table created');
  }

  //get repossess order list
  Future<List<Map<String, dynamic>>> getRoMapList() async {
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(subTable);
    return result;
  }

  //insert repossess order function
  Future<int> insertSubRo(submissionRO ro) async {
    Database db = await this.database;
    var result = await db.insert(subTable, ro.toMap());
    debugPrint("insert -->> " + result.toString());
    return result;
  }

  //update repossess order function
  Future<int> updateSubRo(submissionRO ro) async {
    var db = await this.database;
    var result = await db.update(subTable, ro.toMap(),
        where: '$colRoIDforeign = ?', whereArgs: [ro.roID]);
    debugPrint("update -->> " + result.toString());
    return result;
  }

  Future<bool> checkSubRoExist(String caseClose_roID) async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT $colSubId FROM $subTable WHERE $colRoIDforeign = "'+ caseClose_roID +'";');
    debugPrint(result.length.toString());
    debugPrint('RoID: ' + caseClose_roID +",");

    if(result.length != 0)  //found matched ro ID in sqlite table
      return true;
    else                //not found matched ro ID
      return false;

  }

  //delete repossess order function
  Future<int> deleteNote(String roId) async {
    var db = await this.database;
    int result =
    await db.rawDelete('DELETE FROM $subTable WHERE $colRoIDforeign = $roId');
    return result;
  }

  //count number of data function
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $subTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<List<submissionRO>> getSubList() async {
    var roMapList = await getRoMapList();

    int count = roMapList.length;

    List<submissionRO> subList = List<submissionRO>();

    for(int i = 0; i < count; i++) {
      subList.add(submissionRO.fromMapObject(roMapList[i]));
    }

    return subList;

  }




}