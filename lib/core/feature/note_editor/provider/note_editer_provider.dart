// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/quill_delta.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/repository/note_editor.dart';
// import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

// // Models
// class NoteEditorState {
//   final String title;
//   final String category;
//   final String htmlContent;
//   final bool isSaving;
//   final bool hasUnsavedChanges;
//   final DateTime? lastSaved;
//   final QuillController? controller;

//   const NoteEditorState({
//     this.title = '',
//     this.category = 'Personal',
//     this.htmlContent = '',
//     this.isSaving = false,
//     this.hasUnsavedChanges = false,
//     this.lastSaved,
//     this.controller,
//   });

//   NoteEditorState copyWith({
//     String? title,
//     String? category,
//     String? htmlContent,
//     bool? isSaving,
//     bool? hasUnsavedChanges,
//     DateTime? lastSaved,
//     QuillController? controller,
//   }) {
//     return NoteEditorState(
//       title: title ?? this.title,
//       category: category ?? this.category,
//       htmlContent: htmlContent ?? this.htmlContent,
//       isSaving: isSaving ?? this.isSaving,
//       hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
//       lastSaved: lastSaved ?? this.lastSaved,
//       controller: controller ?? this.controller,
//     );
//   }
// }

// final notesRepositoryProvider = Provider<NotesRepository>((ref) {
//   return NotesRepositoryImpl();
// });

// // Notifier
// class NoteEditorNotifier extends StateNotifier<NoteEditorState> {
//   Timer? _autoSaveTimer;
//   Timer? _debounceTimer;
//   final Map<String, dynamic>? existingNote;
//   final NotesRepository? repository;

//   NoteEditorNotifier({this.existingNote, this.repository})
//     : super(const NoteEditorState()) {
//     _initialize();
//   }

//   void _initialize() {
//     final title = existingNote?['title'] ?? '';
//     final category = existingNote?['category'] ?? 'Personal';
//     final htmlContent = existingNote?['content'] ?? '';
//     // notesDatabase = NotesDatabase.instance;
//     state = state.copyWith(
//       title: title,
//       category: category,
//       htmlContent: htmlContent,
//     );

//     _setupAutoSave();
//   }

//   QuillController initializeQuillController(String htmlContent) {
//     final delta =
//         htmlContent.isNotEmpty ? _convertHtmlToDelta(htmlContent) : Delta()
//           ..insert('\n');

//     final controller = QuillController(
//       document: Document.fromDelta(delta),
//       selection: const TextSelection.collapsed(offset: 0),
//     );

//     state = state.copyWith(controller: controller);
//     return controller;
//   }

//   Delta _convertHtmlToDelta(String html) {
//     // You'll need to implement this based on your HtmlToDelta converter
//     // This is a placeholder
//     return Delta()..insert(html);
//   }

//   void _setupAutoSave() {
//     _autoSaveTimer?.cancel();
//     _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (state.hasUnsavedChanges && !state.isSaving) {
//         autoSave();
//       }
//     });
//   }

//   void updateTitle(String title) {
//     if (state.title != title) {
//       state = state.copyWith(title: title, hasUnsavedChanges: true);
//     }
//   }

//   void updateCategory(String category) {
//     if (state.category != category) {
//       state = state.copyWith(category: category, hasUnsavedChanges: true);
//     }
//   }

//   void onEditorChanged(QuillController controller) {
//     if (!state.hasUnsavedChanges) {
//       state = state.copyWith(hasUnsavedChanges: true);
//     }

//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       _updateHtmlContent(controller);
//     });
//   }

//   void _updateHtmlContent(QuillController controller) {
//     final deltaJson = controller.document.toDelta().toJson();
//     final html = QuillDeltaToHtmlConverter(deltaJson).convert();
//     state = state.copyWith(htmlContent: html);
//   }

//   Future<void> autoSave() async {
//     if (!state.hasUnsavedChanges || state.isSaving) return;

//     state = state.copyWith(isSaving: true);

//     final controller = state.controller;
//     if (controller != null) {
//       final deltaJson = controller.document.toDelta().toJson();
//       final htmlContent = QuillDeltaToHtmlConverter(deltaJson).convert();

//       // Simulate encryption and saving process
//       await Future.delayed(const Duration(milliseconds: 800));
//       // Here you would call your actual save service
//       // await _noteService.saveNote(state.title, htmlContent, state.category);
//       if (AppSettings().recentlyAddedNoteId.isEmpty) {
//         if (state.title.isNotEmpty &&
//             state.category.isNotEmpty &&
//             htmlContent != "<p><br/></p>") {
//           String noteId = Uuid().v1();
//           repository?.createNote(
//             NoteModel(
//               noteId: noteId,
//               noteTitle: state.title,
//               noteCategory: state.category,
//               noteDescription: htmlContent,
//               preview: htmlContent,
//               createdAt: DateTime.now(),
//               updatedAt: DateTime.now(),
//             ),
//           );
//           // notesRepositoryProvider ?.insertNote(
//           //   NoteModel(
//           //     noteId: noteId,
//           //     noteTitle: state.title,
//           //     noteCategory: state.category,
//           //     noteDescription: htmlContent,
//           //     preview: htmlContent,
//           //     createdAt: DateTime.now(),
//           //     updatedAt: DateTime.now(),
//           //   ),
//           // );
//           AppSettings().recentlyAddedNoteId = noteId;
//         }
//       } else {
//         repository?.updateNote(
//           NoteModel(
//             noteId: AppSettings().recentlyAddedNoteId,
//             noteTitle: state.title,
//             noteCategory: state.category,
//             noteDescription: htmlContent,
//             preview: htmlContent,
//             createdAt: DateTime.now(),
//             updatedAt: DateTime.now(),
//           ),
//         );
//       }

//       state = state.copyWith(
//         isSaving: false,
//         hasUnsavedChanges: false,
//         lastSaved: DateTime.now(),
//         htmlContent: htmlContent,
//       );
//     } else {
//       state = state.copyWith(isSaving: false);
//     }
//   }

//   Future<bool> saveNote() async {
//     final controller = state.controller;
//     if (controller == null) return false;

//     final deltaJson = controller.document.toDelta().toJson();
//     final htmlContent = QuillDeltaToHtmlConverter(deltaJson).convert();

//     if (state.title.trim().isEmpty && htmlContent.trim().isEmpty) {
//       return false;
//     }

//     state = state.copyWith(isSaving: true);

//     await Future.delayed(const Duration(milliseconds: 1200));

//     state = state.copyWith(
//       isSaving: false,
//       hasUnsavedChanges: false,
//       lastSaved: DateTime.now(),
//       htmlContent: htmlContent,
//     );

//     return true;
//   }

//   String getShareContent() {
//     final controller = state.controller;
//     if (controller != null) {
//       final deltaJson = controller.document.toDelta().toJson();
//       return QuillDeltaToHtmlConverter(deltaJson).convert();
//     }
//     return state.htmlContent;
//   }

//   String formatLastSaved() {
//     final lastSaved = state.lastSaved;
//     if (lastSaved == null) return '';

//     final now = DateTime.now();
//     final difference = now.difference(lastSaved);

//     if (difference.inMinutes < 1) return 'Just now';
//     if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
//     if (difference.inHours < 24) return '${difference.inHours}h ago';
//     return '${difference.inDays}d ago';
//   }

//   void onAppPaused() {
//     if (state.hasUnsavedChanges) {
//       autoSave();
//     }
//   }

//   @override
//   void dispose() {
//     _autoSaveTimer?.cancel();
//     _debounceTimer?.cancel();
//     state.controller?.dispose();
//     super.dispose();
//   }
// }

// final noteEditorProvider = StateNotifierProvider.autoDispose
//     .family<NoteEditorNotifier, NoteEditorState, Map<String, dynamic>?>((
//       ref,
//       existingNote,
//     ) {
//       return NoteEditorNotifier(existingNote: existingNote);
//     });

// final noteEditorCategoryProvider =
//     Provider.family<String, Map<String, dynamic>?>((ref, existingNote) {
//       return ref.watch(
//         noteEditorProvider(existingNote).select((state) => state.category),
//       );
//     });
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
import 'package:my_secure_note_app/core/feature/note_editor/repository/note_editor.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// =======================
/// STATE
/// =======================
class NoteEditorState {
  final String title;
  final String category;
  final String htmlContent;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final DateTime? lastSaved;
  final QuillController? controller;

  const NoteEditorState({
    this.title = '',
    this.category = 'Personal',
    this.htmlContent = '',
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.lastSaved,
    this.controller,
  });

  NoteEditorState copyWith({
    String? title,
    String? category,
    String? htmlContent,
    bool? isSaving,
    bool? hasUnsavedChanges,
    DateTime? lastSaved,
    QuillController? controller,
  }) {
    return NoteEditorState(
      title: title ?? this.title,
      category: category ?? this.category,
      htmlContent: htmlContent ?? this.htmlContent,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSaved: lastSaved ?? this.lastSaved,
      controller: controller ?? this.controller,
    );
  }
}

/// =======================
/// REPOSITORY PROVIDER
/// =======================
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

/// =======================
/// NOTIFIER
/// =======================
class NoteEditorNotifier extends StateNotifier<NoteEditorState> {
  final Map<String, dynamic>? existingNote;
  final NotesRepository repository;

  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  NoteEditorNotifier({required this.repository, this.existingNote})
    : super(const NoteEditorState()) {
    _initialize();
  }

  void _initialize() {
    state = state.copyWith(
      title: existingNote?['title'] ?? '',
      category: existingNote?['category'] ?? 'Personal',
      htmlContent: existingNote?['content'] ?? '',
    );

    _setupAutoSave();
  }

  /// =======================
  /// QUILL
  /// =======================
  QuillController initializeQuillController(String htmlContent) {
    final document = Document()..insert(0, '\n');

    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    state = state.copyWith(controller: controller);
    return controller;
  }

  /// =======================
  /// AUTO SAVE
  /// =======================
  void _setupAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => autoSave(),
    );
  }

  /// =======================
  /// UPDATERS
  /// =======================
  void updateTitle(String title) {
    if (state.title != title) {
      state = state.copyWith(title: title, hasUnsavedChanges: true);
    }
  }

  void updateCategory(String category) {
    if (state.category != category) {
      state = state.copyWith(category: category, hasUnsavedChanges: true);
    }
  }

  void onEditorChanged(QuillController controller) {
    state = state.copyWith(hasUnsavedChanges: true);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final delta = controller.document.toDelta().toJson();
      final html = QuillDeltaToHtmlConverter(delta).convert();
      state = state.copyWith(htmlContent: html);
    });
  }

  /// =======================
  /// SAVE
  /// =======================
  Future<void> autoSave() async {
    if (!state.hasUnsavedChanges || state.isSaving) return;
    await _persist();
  }

  Future<bool> saveNote() async {
    if (state.title.trim().isEmpty && state.htmlContent.trim().isEmpty) {
      return false;
    }
    await _persist();
    return true;
  }

  Future<void> _persist() async {
    state = state.copyWith(isSaving: true);

    final noteId = AppSettings().recentlyAddedNoteId.isEmpty
        ? const Uuid().v4()
        : AppSettings().recentlyAddedNoteId;

    final note = NoteModel(
      noteId: noteId,
      noteTitle: state.title,
      noteCategory: state.category,
      noteDescription: state.htmlContent,
      preview: state.htmlContent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (AppSettings().recentlyAddedNoteId.isEmpty) {
      repository.createNote(note);
      AppSettings().recentlyAddedNoteId = noteId;
    } else {
      repository.updateNote(note);
    }

    state = state.copyWith(
      isSaving: false,
      hasUnsavedChanges: false,
      lastSaved: DateTime.now(),
    );
  }

  /// =======================
  /// HELPERS
  /// =======================
  String getShareContent() => state.htmlContent;

  String formatLastSaved() {
    if (state.lastSaved == null) return '';
    final diff = DateTime.now().difference(state.lastSaved!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void onAppPaused() {
    if (state.hasUnsavedChanges) autoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    state.controller?.dispose();
    super.dispose();
  }
}

/// =======================
/// PROVIDER
/// =======================
final noteEditorProvider = StateNotifierProvider.autoDispose
    .family<NoteEditorNotifier, NoteEditorState, Map<String, dynamic>?>((
      ref,
      existingNote,
    ) {
      return NoteEditorNotifier(
        repository: ref.read(notesRepositoryProvider),
        existingNote: existingNote,
      );
    });
