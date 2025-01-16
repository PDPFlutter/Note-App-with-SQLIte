import 'package:flutter/material.dart';
import 'package:note_app/data/repository/note_repository_impl.dart';
import 'package:note_app/data/repository/user_repository_impl.dart';
import 'package:note_app/domain/repository/note_repository.dart';
import 'package:note_app/presentation/screens/create_user_screen.dart';
import 'package:note_app/presentation/screens/notes_screen.dart';

import 'data/database/database_helper.dart';
import 'domain/models/user.dart';
import 'domain/repository/user_repository.dart';

void main() async {
  // Ensure Flutter bindings are initialized before accessing platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  final UserRepository userRepository = UserRepositoryImpl(dbHelper: dbHelper);
  final NoteRepository noteRepository = NoteRepositoryImpl(dbHelper: dbHelper);

  runApp(
    MyApp(
      userRepository: userRepository,
      noteRepository: noteRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final NoteRepository noteRepository;

  const MyApp({super.key, required this.noteRepository, required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: FutureBuilder<List<User>>(
        future: userRepository.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
          }

          // If no users exist, show user creation screen
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return CreateUserScreen(userRepository: userRepository, noteRepository: noteRepository);
          }

          // If users exist, show notes for the first user
          return NotesScreen(userId: snapshot.data!.first.id!, noteRepository: noteRepository);
        },
      ),
    );
  }
}
