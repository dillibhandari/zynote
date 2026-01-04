import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:html/parser.dart';
import 'package:my_secure_note_app/core/feature/note_editor/repository/note_editor.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../model/note_model.dart';
import 'package:html/dom.dart' as dom;

class NoteEditorState {
  final String title;
  final String category;
  final String htmlContent;
  final String preview;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final DateTime? lastSaved;
  final QuillController? controller;

  const NoteEditorState({
    this.title = '',
    this.category = 'Personal',
    this.htmlContent = '',
    this.preview = '',
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.lastSaved,
    this.controller,
  });

  NoteEditorState copyWith({
    String? title,
    String? category,
    String? htmlContent,
    String? preview,
    bool? isSaving,
    bool? hasUnsavedChanges,
    DateTime? lastSaved,
    QuillController? controller,
  }) {
    return NoteEditorState(
      title: title ?? this.title,
      category: category ?? this.category,
      htmlContent: htmlContent ?? this.htmlContent,
      preview: preview ?? this.preview,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      lastSaved: lastSaved ?? this.lastSaved,
      controller: controller ?? this.controller,
    );
  }
}

final noteEditorProvider =
    StateNotifierProvider.family<
      NoteEditorNotifier,
      NoteEditorState,
      Map<String, dynamic>?
    >((ref, existingNote) {
      final repository = ref.read(notesRepositoryProvider);
      return NoteEditorNotifier(existingNote, repository);
    });

class NoteEditorNotifier extends StateNotifier<NoteEditorState> {
  final NotesRepository _repository;
  final Map<String, dynamic>? existingNote;

  NoteEditorNotifier(this.existingNote, this._repository)
    : super(
        NoteEditorState(
          title: existingNote?['note_title'] ?? '',
          category: existingNote?['note_category'] ?? 'Personal',
          htmlContent: existingNote?['note_description'] ?? '',
          preview: existingNote?['preview'] ?? '',
        ),
      );

  QuillController initializeQuillController({String? html}) {
    if (state.controller != null) return state.controller!;

    late final Document document;

    if (html != null && html.trim().isNotEmpty) {
      final delta = htmlToQuillDelta(html);
      document = Document.fromDelta(delta);
    } else {
      document = Document();
    }

    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    controller.addListener(() {
      final delta = controller.document.toDelta();
      final htmlConverter = QuillDeltaToHtmlConverter(delta.toJson()).convert();

      state = state.copyWith(
        hasUnsavedChanges: true,
        htmlContent: htmlConverter,
      );
    });

    state = state.copyWith(controller: controller);
    return controller;
  }

  Delta htmlToQuillDelta(String html) {
    final delta = Delta();
    final document = parse(html);

    void parseNode(
      dom.Node node,
      Map<String, dynamic> parentAttributes, {
      String? listType,
      String? blockType,
    }) {
      if (node is dom.Element) {
        final attrs = Map<String, dynamic>.from(parentAttributes);

        switch (node.localName) {
          case 'strong':
          case 'b':
            attrs['bold'] = true;
            break;
          case 'em':
          case 'i':
            attrs['italic'] = true;
            break;
          case 'u':
            attrs['underline'] = true;
            break;
          case 's':
          case 'strike':
            attrs['strike'] = true;
            break;
          case 'a':
            final href = node.attributes['href'];
            if (href != null) attrs['link'] = href;
            break;
          case 'span':
            final style = node.attributes['style'];
            if (style != null) {
              final colorMatch = RegExp(
                r'color\s*:\s*(#[0-9a-fA-F]+)',
              ).firstMatch(style);
              if (colorMatch != null) attrs['color'] = colorMatch.group(1);
              final bgMatch = RegExp(
                r'background-color\s*:\s*(#[0-9a-fA-F]+)',
              ).firstMatch(style);
              if (bgMatch != null) attrs['background'] = bgMatch.group(1);
            }
            break;
        }

        if (node.localName == 'br') {
          delta.insert('\n', {});
          return;
        } else if (node.localName == 'p' || node.localName == 'div') {
          for (final child in node.nodes) {
            parseNode(child, attrs);
          }
          delta.insert('\n', {});
          return;
        } else if (node.localName == 'blockquote') {
          for (final child in node.nodes) {
            parseNode(child, attrs);
          }
          delta.insert('\n', {'block': 'quote'});
          return;
        } else if (node.localName == 'ul') {
          for (final li in node.children) {
            parseNode(li, attrs, listType: 'bullet');
          }
          return;
        } else if (node.localName == 'ol') {
          for (final li in node.children) {
            parseNode(li, attrs, listType: 'ordered');
          }
          return;
        } else if (node.localName == 'li') {
          for (final child in node.nodes) {
            parseNode(child, attrs);
          }
          delta.insert('\n', listType != null ? {'list': listType} : {});
          return;
        }

        for (final child in node.nodes) {
          parseNode(child, attrs, listType: listType, blockType: blockType);
        }
      } else if (node is dom.Text) {
        if (node.text.isNotEmpty) delta.insert(node.text, parentAttributes);
      }
    }

    for (final node in document.body?.nodes ?? []) {
      parseNode(node, {});
    }

    // Ensure the last line ends with a newline to avoid Quill errors
    if (delta.isNotEmpty) {
      final lastOp = delta.last;
      if (lastOp.data is String && !(lastOp.data as String).endsWith('\n')) {
        delta.insert('\n', {});
      }
    }

    return delta;
  }

  void updateTitle(String value) {
    if (value == state.title) return;
    state = state.copyWith(title: value, hasUnsavedChanges: true);
  }

  /// Update category
  void updateCategory(String value) {
    if (value == state.category) return;
    state = state.copyWith(category: value, hasUnsavedChanges: true);
  }

  void onEditorChanged(QuillController controller) {
    final delta = controller.document.toDelta();

    final converter = QuillDeltaToHtmlConverter(delta.toJson());

    final html = converter.convert();
    String notePreview = controller.document.toPlainText().length > 320
        ? controller.document.toPlainText().substring(0, 320)
        : controller.document.toPlainText();

    state = state.copyWith(
      hasUnsavedChanges: true,
      htmlContent: html,
      preview: notePreview,
    );
  }

  Future<bool> saveNote() async {
    if (state.title.trim().isEmpty && state.controller!.document.isEmpty()) {
      return false;
    }

    state = state.copyWith(isSaving: true);
    String recentlyAddedNoteId = AppSettings().recentlyAddedNoteId;
    String noteId = recentlyAddedNoteId.isEmpty
        ? Uuid().v1()
        : recentlyAddedNoteId;

    final note = NoteModel(
      noteId: noteId,
      noteTitle: state.title,
      noteCategory: state.category,
      noteDescription: state.htmlContent,
      status: NoteStatus.active,
      deletedAt: '',
      createdAt: existingNote?['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      pinned: existingNote?['pinned'] == 1,
      preview: state.preview,
    );

    try {
      AppSettings().recentlyAddedNoteId = noteId;
      if (recentlyAddedNoteId.isNotEmpty) {
        await _repository.updateNote(note);
      } else {
        await _repository.createNote(note);
      }

      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
        lastSaved: DateTime.now(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  /// Called when app goes to background
  void onAppPaused() {
    if (state.hasUnsavedChanges) {
      saveNote();
    }
  }

  /// Format last saved time
  String formatLastSaved() {
    if (state.lastSaved == null) return '';
    final dt = state.lastSaved!;
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Get content for sharing
  String getShareContent() {
    return state.htmlContent;
  }
}
