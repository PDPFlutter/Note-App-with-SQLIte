import 'package:sqflite/sqflite.dart';
import '../../domain/models/user.dart';
import '../../domain/repository/user_repository.dart';
import '../database/database_helper.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseDataSource dbHelper;

  const UserRepositoryImpl({required this.dbHelper});

  @override
  Future<int> insertUser(User user) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting user: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, Object?>> maps = await db.query('users');

      return List.generate(maps.length, (i) {
        return User.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting users: $e');
      rethrow;
    }
  }

  @override
  Future<int> updateUser(User user) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  @override
  Future<int> deleteUser(int id) async {
    try {
      final db = await dbHelper.database;
      // Foreign key constraint tufayli related noteslar ham o'chiriladi
      return await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
