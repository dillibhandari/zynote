import 'dart:convert';
import 'package:my_secure_note_app/core/helper/rsa_services.dart';
import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

enum NoteStatus { active, deleted, favorite }

class NoteModel extends Equatable {
  final String noteId;
  final String noteTitle;
  final String noteCategory;
  final String noteDescription;
  final String preview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pinned;
  final NoteStatus status;
  final DateTime? deletedAt;

  const NoteModel({
    required this.noteId,
    required this.noteTitle,
    required this.noteCategory,
    required this.noteDescription,
    required this.preview,
    required this.createdAt,
    required this.updatedAt,
    this.pinned = false,
    this.status = NoteStatus.active,
    this.deletedAt,
  });

  factory NoteModel.create({
    required String title,
    required String category,
    required String description,
  }) {
    final now = DateTime.now();
    return NoteModel(
      noteId: const Uuid().v4(),
      noteTitle: title,
      noteCategory: category,
      noteDescription: description,
      preview: description.length > 50
          ? description.substring(0, 50)
          : description,
      createdAt: now,
      updatedAt: now,
      pinned: false,
      status: NoteStatus.active,
    );
  }

  NoteModel copyWith({
    String? noteTitle,
    String? noteCategory,
    String? noteDescription,
    String? preview,
    DateTime? updatedAt,
    bool? pinned,
    NoteStatus? status,
    DateTime? deletedAt,
  }) {
    return NoteModel(
      noteId: noteId,
      noteTitle: noteTitle ?? this.noteTitle,
      noteCategory: noteCategory ?? this.noteCategory,
      noteDescription: noteDescription ?? this.noteDescription,
      preview: preview ?? this.preview,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Convert to map (for local storage / Firebase)
  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'note_title': noteTitle,
      'note_category': noteCategory,
      'note_description': noteDescription,
      'preview': preview,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pinned': pinned ? 1 : 0,
      'status': status.name, // enum as string
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      noteId: map['note_id'],
      noteTitle: map['note_title'],
      noteCategory: map['note_category'],
      noteDescription: map['note_description'],
      preview: map['preview'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      pinned: (map['pinned'] as int) == 1,
      status: NoteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NoteStatus.active,
      ),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null,
    );
  }

  /// Encryption helper
  Future<Map<String, dynamic>> toEncryptedMap(RSAService rsaService) async {
    return {
      'note_id': noteId,
      'note_title': await rsaService.encryptData(noteTitle),
      'note_category': await rsaService.encryptData(noteCategory),
      'note_description': await rsaService.encryptData(noteDescription),
      'preview': await rsaService.encryptData(preview),
      'created_at': await rsaService.encryptData(createdAt.toIso8601String()),
      'updated_at': await rsaService.encryptData(updatedAt.toIso8601String()),
      'pinned': pinned ? 1 : 0,
      'status': status.name,
      'deleted_at': deletedAt != null
          ? await rsaService.encryptData(deletedAt!.toIso8601String())
          : null,
    };
  }

  static Future<NoteModel> fromEncryptedMap(
    Map<String, dynamic> map,
    RSAService rsaService,
  ) async {
    return NoteModel(
      noteId: map['note_id'],
      noteTitle: await rsaService.decryptData(map['note_title']),
      noteCategory: await rsaService.decryptData(map['note_category']),
      noteDescription: await rsaService.decryptData(map['note_description']),
      preview: await rsaService.decryptData(map['preview']),
      createdAt: DateTime.parse(
        await rsaService.decryptData(map['created_at']),
      ),
      updatedAt: DateTime.parse(
        await rsaService.decryptData(map['updated_at']),
      ),
      pinned: (map['pinned'] as int) == 1,
      status: NoteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => NoteStatus.active,
      ),
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(await rsaService.decryptData(map['deleted_at']))
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory NoteModel.fromJson(String source) =>
      NoteModel.fromMap(jsonDecode(source));

  @override
  List<Object?> get props => [
    noteId,
    noteTitle,
    noteCategory,
    noteDescription,
    preview,
    createdAt,
    updatedAt,
    pinned,
    status,
    deletedAt,
  ];
}
