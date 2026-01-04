import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_secure_note_app/core/database/note_db.dart';

import '../model/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

abstract class NotesRepository {
  Future<void> createNote(NoteModel note);

  Future<List<NoteModel>> getAllNotes();

  Future<List<NoteModel>> searchNotes(String query);

  Future<void> updateNote(NoteModel note);

  Future<void> softDeleteNote(String noteId);

  Future<void> deleteNotePermanently(String noteId);
}

class NotesRepositoryImpl implements NotesRepository {
  final NotesDatabase _database;

  NotesRepositoryImpl({NotesDatabase? database})
    : _database = database ?? NotesDatabase.instance;

  @override
  Future<void> createNote(NoteModel note) async {
    await _database.insertNote(note);
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    return await _database.getNotesList();
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final decryptedNotes = await _database.getNotesList();
    final lowerQuery = query.toLowerCase();

    return decryptedNotes.where((note) {
      return note.noteTitle.toLowerCase().contains(lowerQuery) ||
          note.noteCategory.toLowerCase().contains(lowerQuery) ||
          note.noteDescription.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await _database.updateNote(note);
  }

  @override
  Future<void> softDeleteNote(String noteId) async {
    await _database.softDeleteNote(noteId);
  }

  @override
  Future<void> deleteNotePermanently(String noteId) async {
    await _database.deleteNotePermanently(noteId);
  }
}
