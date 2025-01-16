import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseDataSource {
  Future<Database> get database;
}

// TODO: Initialize your DatabaseHelper implementation