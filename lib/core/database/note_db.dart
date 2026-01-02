import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
import 'package:my_secure_note_app/core/helper/rsa_services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;
  RSAService rsaService = RSAService();
  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const statusType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';

    await db.execute('''
    CREATE TABLE notes (
      note_id $idType,
      note_title $textType,
      note_category $textType,
      note_description $textType,
      preview $textType,
      created_at $textType,
      updated_at $textType,
      pinned $boolType,
      status $statusType,
      deleted_at $nullableTextType
    )
  ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> insertNote(NoteModel note) async {
    final encryptedMap = await note.toEncryptedMap(rsaService);
    final db = await instance.database;
    await db.insert(
      'notes',
      encryptedMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'status != ?',
      whereArgs: ['deleted'],
      orderBy: 'created_at DESC',
    );

    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<List<NoteModel>> getNotesList() async {
    final List<NoteModel> result = await getNotes();
    return Future.wait(
      result.map((map) => NoteModel.fromEncryptedMap(map.toMap(), rsaService)),
    );
  }

  Future<void> updateNote(NoteModel note) async {
    final db = await instance.database;
    final encryptedMap = await note.toEncryptedMap(rsaService);
    await db.update(
      'notes',
      encryptedMap,
      where: 'note_id = ?',
      whereArgs: [note.noteId],
    );
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final allNotes = await getNotes();
    final lowerQuery = query.toLowerCase();

    return allNotes.where((note) {
      return note.noteTitle.toLowerCase().contains(lowerQuery) ||
          note.noteCategory.toLowerCase().contains(lowerQuery) ||
          note.noteDescription.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> deleteNotePermanently(String noteId) async {
    final db = await instance.database;
    await db.delete('notes', where: 'note_id = ?', whereArgs: [noteId]);
  }

  Future<void> softDeleteNote(String noteId) async {
    final db = await instance.database;

    await db.update(
      'notes',
      {'status': 'deleted', 'deleted_at': DateTime.now().toIso8601String()},
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }
}
