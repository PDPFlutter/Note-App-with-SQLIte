import '../models/note.dart';

abstract class NoteRepository {
  Future<int> insertNote(Note note);
  Future<List<Note>> getUserNotes(int userId);
  Future<int> updateNote(Note note);
  Future<int> deleteNote(int id);
  Future<void> insertMultipleNotes(List<Note> notes);
  Future<void> transferNotes(int fromUserId, int toUserId);
}