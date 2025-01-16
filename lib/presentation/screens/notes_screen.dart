import 'package:flutter/material.dart';
import '../../domain/models/note.dart';
import '../../domain/repository/note_repository.dart';
import '../widgets/note_card.dart';
import 'add_note_screen.dart';
import 'edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  final int userId;
  final NoteRepository noteRepository;

  const NotesScreen({super.key, required this.userId, required this.noteRepository});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    _notesFuture = widget.noteRepository.getUserNotes(widget.userId);
  }

  Future<void> _deleteNote(int noteId) async {
    try {
      await widget.noteRepository.deleteNote(noteId);
      setState(() {
        _loadNotes();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error deleting note')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notes found'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final note = snapshot.data![index];
              return NoteCard(
                note: note,
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditNoteScreen(note: note, noteRepository: widget.noteRepository)));
                  if (result == true) {
                    setState(() {
                      _loadNotes();
                    });
                  }
                },
                onDelete: () => _deleteNote(note.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(
                userId: widget.userId,
                noteRepository: widget.noteRepository,
              ),
            ),
          );
          if (result == true) {
            setState(() {
              _loadNotes();
            });
          }
        },
      ),
    );
  }
}
