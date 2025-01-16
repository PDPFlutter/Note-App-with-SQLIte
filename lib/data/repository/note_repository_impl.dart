import 'package:sqflite/sqflite.dart';

import '../../domain/models/note.dart';
import '../../domain/repository/note_repository.dart';
import '../database/database_helper.dart';

class NoteRepositoryImpl implements NoteRepository {
  final DatabaseDataSource dbHelper;
  const NoteRepositoryImpl({required this.dbHelper});

  @override
  Future<int> insertNote(Note note) async {
    try {
      final db = await dbHelper.database;
      return await db.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting note: $e');
      rethrow;
    }
  }

  @override
  Future<List<Note>> getUserNotes(int userId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, Object?>> maps = await db.query(
        'notes',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return Note.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting user notes: $e');
      rethrow;
    }
  }

  @override
  Future<int> updateNote(Note note) async {
    try {
      final db = await dbHelper.database;
      return await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  @override
  Future<int> deleteNote(int id) async {
    try {
      final db = await dbHelper.database;
      return await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  @override
  Future<void> insertMultipleNotes(List<Note> notes) async {
    try {
      final db = await dbHelper.database;
      final batch = db.batch();

      for (var note in notes) {
        batch.insert('notes', note.toMap());
      }

      await batch.commit();
    } catch (e) {
      print('Error in batch operation: $e');
      rethrow;
    }
  }

  @override
  Future<void> transferNotes(int fromUserId, int toUserId) async {
    try {
      final db = await dbHelper.database;

      await db.transaction((txn) async {
        // Update notes
        await txn.update(
          'notes',
          {'user_id': toUserId},
          where: 'user_id = ?',
          whereArgs: [fromUserId],
        );

        // Update user statistics or other related data
        await txn.update(
          'users',
          {'notes_count': 0},
          where: 'id = ?',
          whereArgs: [fromUserId],
        );
      });
    } catch (e) {
      print('Error in transaction: $e');
      rethrow;
    }
  }
}