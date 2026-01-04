import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
import 'package:my_secure_note_app/core/feature/note_editor/repository/note_editor.dart';
 
/// State
class NotesState {
  final List<NoteModel> allNotes;
  final List<NoteModel> filteredNotes;
  final bool isLoading;
  final String searchQuery;
  final String selectedCategory;
  final String selectedView;
  final String sortBy;

  const NotesState({
    required this.allNotes,
    required this.filteredNotes,
    required this.isLoading,
    required this.searchQuery,
    required this.selectedCategory,
    required this.selectedView,
    required this.sortBy,
  });

  NotesState copyWith({
    List<NoteModel>? allNotes,
    List<NoteModel>? filteredNotes,
    bool? isLoading,
    String? searchQuery,
    String? selectedCategory,
    String? selectedView,
    String? sortBy,
  }) {
    return NotesState(
      allNotes: allNotes ?? this.allNotes,
      filteredNotes: filteredNotes ?? this.filteredNotes,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedView: selectedView ?? this.selectedView,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  factory NotesState.initial() {
    return const NotesState(
      allNotes: [],
      filteredNotes: [],
      isLoading: false,
      searchQuery: '',
      selectedCategory: 'All Notes',
      selectedView: 'grid',
      sortBy: 'newest',
    );
  }
}

/// Notes repository provider
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});

/// Notes provider
final notesListProvider = StateNotifierProvider<NotesNotifier, NotesState>(
    (ref) {
  final repository = ref.read(notesRepositoryProvider);
  return NotesNotifier(repository);
});

/// Notifier
class NotesNotifier extends StateNotifier<NotesState> {
  final NotesRepository _repository;

  NotesNotifier(this._repository) : super(NotesState.initial()) {
    loadNotes(); // load notes when provider initializes
  }

  /// Load notes from repository
  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final notes = await _repository.getAllNotes();
      state = state.copyWith(allNotes: notes, isLoading: false);
      _applyFiltersAndSort();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error loading notes: $e');
    }
  }

  /// Search
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  /// Category filter
  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFiltersAndSort();
  }

  /// Toggle view
  void toggleView() {
    final newView = state.selectedView == 'grid' ? 'list' : 'grid';
    state = state.copyWith(selectedView: newView);
  }

  /// Update sort
  void updateSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFiltersAndSort();
  }

  /// Toggle pin
  Future<void> togglePin(String noteId) async {
    final updatedNotes = state.allNotes.map((note) {
      if (note.noteId == noteId) {
        final updatedNote = note.copyWith(pinned: !note.pinned);
        _repository.updateNote(updatedNote); // update in DB
        return updatedNote;
      }
      return note;
    }).toList();

    state = state.copyWith(allNotes: updatedNotes);
    _applyFiltersAndSort();
  }

  /// Delete note
  Future<void> deleteNote(String noteId) async {
    await _repository.softDeleteNote(noteId);
    await loadNotes();
  }

  /// Apply search, category filter, and sort
  void _applyFiltersAndSort() {
    var filtered = state.allNotes.where((note) {
      final query = state.searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty || note.noteTitle.toLowerCase().contains(query) || note.noteDescription.toLowerCase().contains(query);
      final matchesCategory = state.selectedCategory == 'All Notes' ||
          note.noteCategory == state.selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    filtered = _sortNotes(filtered);
    filtered = _organizePinnedNotes(filtered);

    state = state.copyWith(filteredNotes: filtered);
  }

  List<NoteModel> _sortNotes(List<NoteModel> notes) {
    final sorted = List<NoteModel>.from(notes);

    switch (state.sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'title':
        sorted.sort((a, b) => a.noteTitle.compareTo(b.noteTitle));
        break;
      case 'category':
        sorted.sort((a, b) => a.noteCategory.compareTo(b.noteCategory));
        break;
    }

    return sorted;
  }

  List<NoteModel> _organizePinnedNotes(List<NoteModel> notes) {
    final pinned = notes.where((n) => n.pinned).toList();
    final unpinned = notes.where((n) => !n.pinned).toList();
    return [...pinned, ...unpinned];
  }
}

/// Computed providers
final filteredNotesProvider = Provider<List<NoteModel>>((ref) {
  return ref.watch(notesListProvider).filteredNotes;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notesListProvider).isLoading;
});

final selectedViewProvider = Provider<String>((ref) {
  return ref.watch(notesListProvider).selectedView;
});

final selectedCategoryProvider = Provider<String>((ref) {
  return ref.watch(notesListProvider).selectedCategory;
});

final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(notesListProvider).searchQuery;
});

final sortByProvider = Provider<String>((ref) {
  return ref.watch(notesListProvider).sortBy;
});

final hasNotesProvider = Provider<bool>((ref) {
  return ref.watch(filteredNotesProvider).isNotEmpty;
});

final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchQueryProvider).isNotEmpty;
});


// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';

// class NotesState {
//   final List<Map<String, dynamic>> allNotes;
//   final List<Map<String, dynamic>> filteredNotes;
//   final bool isLoading;
//   final String searchQuery;
//   final String selectedCategory;
//   final String selectedView;
//   final String sortBy;

//   const NotesState({
//     required this.allNotes,
//     required this.filteredNotes,
//     required this.isLoading,
//     required this.searchQuery,
//     required this.selectedCategory,
//     required this.selectedView,
//     required this.sortBy,
//   });

//   NotesState copyWith({
//     List<Map<String, dynamic>>? allNotes,
//     List<Map<String, dynamic>>? filteredNotes,
//     bool? isLoading,
//     String? searchQuery,
//     String? selectedCategory,
//     String? selectedView,
//     String? sortBy,
//   }) {
//     return NotesState(
//       allNotes: allNotes ?? this.allNotes,
//       filteredNotes: filteredNotes ?? this.filteredNotes,
//       isLoading: isLoading ?? this.isLoading,
//       searchQuery: searchQuery ?? this.searchQuery,
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//       selectedView: selectedView ?? this.selectedView,
//       sortBy: sortBy ?? this.sortBy,
//     );
//   }

//   factory NotesState.initial() {
//     return const NotesState(
//       allNotes: [],
//       filteredNotes: [],
//       isLoading: false,
//       searchQuery: '',
//       selectedCategory: 'All Notes',
//       selectedView: 'grid',
//       sortBy: 'newest',
//     );
//   }
// }

// class NotesNotifier extends StateNotifier<NotesState> {
//   NotesNotifier() : super(NotesState.initial());

//   Future<void> initialize() async {
//     await loadNotes();
//   }

//   // Load notes from data source
//   Future<void> loadNotes() async {
//     state = state.copyWith(isLoading: true);

//     await Future.delayed(const Duration(milliseconds: 500));

//     final notes = List<Map<String, dynamic>>.from(NoteData.mockNotes);

//     state = state.copyWith(allNotes: notes, isLoading: false);

//     _applyFiltersAndSort();
//   }

//   // Search functionality
//   void updateSearchQuery(String query) {
//     state = state.copyWith(searchQuery: query);
//     _applyFiltersAndSort();
//   }

//   // Category filter
//   void updateCategory(String category) {
//     state = state.copyWith(selectedCategory: category);
//     _applyFiltersAndSort();
//   }

//   // Toggle view (grid/list)
//   void toggleView() {
//     final newView = state.selectedView == 'grid' ? 'list' : 'grid';
//     state = state.copyWith(selectedView: newView);
//   }

//   // Update sort option
//   void updateSortBy(String sortBy) {
//     state = state.copyWith(sortBy: sortBy);
//     _applyFiltersAndSort();
//   }

//   // Toggle pin status
//   void togglePin(String noteId) {
//     final updatedNotes = state.allNotes.map((note) {
//       if (note['id'] == noteId) {
//         return {...note, 'isPinned': !(note['isPinned'] ?? false)};
//       }
//       return note;
//     }).toList();

//     state = state.copyWith(allNotes: updatedNotes);
//     _applyFiltersAndSort();
//   }

//   // Refresh notes
//   Future<void> refresh() async {
//     await loadNotes();
//   }

//   void _applyFiltersAndSort() {
//     var filtered = state.allNotes.where((note) {
//       return _matchesFilters(note);
//     }).toList();

//     filtered = _sortNotes(filtered);
//     filtered = _organizePinnedNotes(filtered);

//     state = state.copyWith(filteredNotes: filtered);
//   }

//   bool _matchesFilters(Map<String, dynamic> note) {
//     final query = state.searchQuery.toLowerCase();

//     final matchesSearch =
//         query.isEmpty ||
//         note['title'].toLowerCase().contains(query) ||
//         note['preview'].toLowerCase().contains(query) ||
//         (note['tags'] as List).any((tag) => tag.toLowerCase().contains(query));

//     final matchesCategory =
//         state.selectedCategory == 'All Notes' ||
//         note['category'] == state.selectedCategory;

//     return matchesSearch && matchesCategory;
//   }

//   List<Map<String, dynamic>> _sortNotes(List<Map<String, dynamic>> notes) {
//     final sorted = List<Map<String, dynamic>>.from(notes);

//     switch (state.sortBy) {
//       case 'newest':
//         sorted.sort(
//           (a, b) => (b['createdAt'] as DateTime).compareTo(
//             a['createdAt'] as DateTime,
//           ),
//         );
//         break;
//       case 'oldest':
//         sorted.sort(
//           (a, b) => (a['createdAt'] as DateTime).compareTo(
//             b['createdAt'] as DateTime,
//           ),
//         );
//         break;
//       case 'title':
//         sorted.sort(
//           (a, b) => (a['title'] as String).compareTo(b['title'] as String),
//         );
//         break;
//       case 'category':
//         sorted.sort(
//           (a, b) =>
//               (a['category'] as String).compareTo(b['category'] as String),
//         );
//         break;
//     }

//     return sorted;
//   }

//   List<Map<String, dynamic>> _organizePinnedNotes(
//     List<Map<String, dynamic>> notes,
//   ) {
//     final pinned = notes.where((n) => n['isPinned'] == true).toList();
//     final unpinned = notes.where((n) => n['isPinned'] != true).toList();
//     return [...pinned, ...unpinned];
//   }
// }

// // Main notes provider
// final notesListProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
//   return NotesNotifier();
// });

// // Computed providers for specific state slices
// final filterednotesListProvider = Provider<List<Map<String, dynamic>>>((ref) {
//   return ref.watch(notesListProvider).filteredNotes;
// });

// final isLoadingProvider = Provider<bool>((ref) {
//   return ref.watch(notesListProvider).isLoading;
// });

// final selectedViewProvider = Provider<String>((ref) {
//   return ref.watch(notesListProvider).selectedView;
// });

// final selectedCategoryProvider = Provider<String>((ref) {
//   return ref.watch(notesListProvider).selectedCategory;
// });

// final searchQueryProvider = Provider<String>((ref) {
//   return ref.watch(notesListProvider).searchQuery;
// });

// final sortByProvider = Provider<String>((ref) {
//   return ref.watch(notesListProvider).sortBy;
// });

// final hasnotesListProvider = Provider<bool>((ref) {
//   final notes = ref.watch(filterednotesListProvider);
//   return notes.isNotEmpty;
// });

// final isSearchingProvider = Provider<bool>((ref) {
//   final query = ref.watch(searchQueryProvider);
//   return query.isNotEmpty;
// });

// // class NoteData {
// //   static final List<Map<String, dynamic>> mockNotes = [
// //     {
// //       'id': 1,
// //       'title': "Meeting Notes - Q4 Strategy",
// //       'preview':
// //           "Discussed quarterly goals, budget allocation for new projects, and team expansion plans.",
// //       'content': "Full encrypted content would be here after decryption",
// //       'category': "Work",
// //       'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
// //       'isEncrypted': true,
// //       'tags': ["meeting", "strategy", "q4"],
// //       'isPinned': false,
// //     },
// //     {
// //       'id': 2,
// //       'title': "Personal Journal Entry",
// //       'preview':
// //           "Today was a productive day. Managed to complete the security audit for the new application.",
// //       'content': "Full encrypted personal thoughts",
// //       'category': "Personal",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 1)),
// //       'isEncrypted': true,
// //       'tags': ["journal", "personal", "thoughts"],
// //       'isPinned': true,
// //     },
// //     {
// //       'id': 3,
// //       'title': "Investment Portfolio Review",
// //       'preview':
// //           "Current portfolio performance analysis. Tech stocks showing strong growth.",
// //       'content': "Encrypted financial data and analysis",
// //       'category': "Finance",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 2)),
// //       'isEncrypted': true,
// //       'tags': ["investment", "portfolio", "finance"],
// //       'isPinned': false,
// //     },
// //     {
// //       'id': 4,
// //       'title': "App Development Ideas",
// //       'preview':
// //           "New feature concepts for the secure notes app: voice-to-text encryption.",
// //       'content': "Detailed feature specifications and technical requirements",
// //       'category': "Ideas",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 3)),
// //       'isEncrypted': true,
// //       'tags': ["development", "features", "innovation"],
// //       'isPinned': false,
// //     },
// //     {
// //       'id': 5,
// //       'title': "Medical Records Summary",
// //       'preview':
// //           "Annual checkup results, vaccination records, and medication list.",
// //       'content': "Encrypted medical information and health data",
// //       'category': "Health",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 5)),
// //       'isEncrypted': true,
// //       'tags': ["medical", "health", "records"],
// //       'isPinned': false,
// //     },
// //     {
// //       'id': 6,
// //       'title': "Secure Password Vault",
// //       'preview':
// //           "Banking credentials, social media accounts, and work-related login information.",
// //       'content': "Encrypted password database",
// //       'category': "Passwords",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 7)),
// //       'isEncrypted': true,
// //       'tags': ["passwords", "security", "credentials"],
// //       'isPinned': true,
// //     },
// //     {
// //       'id': 7,
// //       'title': "Emergency Contact Information",
// //       'preview':
// //           "Important phone numbers, addresses, and emergency procedures.",
// //       'content': "Encrypted emergency contact details",
// //       'category': "Important",
// //       'createdAt': DateTime.now().subtract(const Duration(days: 10)),
// //       'isEncrypted': true,
// //       'tags': ["emergency", "contacts", "important"],
// //       'isPinned': false,
// //     },
// //   ];
// // }
