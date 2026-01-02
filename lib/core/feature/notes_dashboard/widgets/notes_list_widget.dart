import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import './empty_state_widget.dart';
import './note_card_widget.dart';

class NotesListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final bool isLoading;
  final bool isSearching;
  final String searchQuery;
  final VoidCallback onRefresh;
  final VoidCallback onCreateNote;
  final Function(Map<String, dynamic>) onNoteTap;
  final Function(Map<String, dynamic>) onNoteEdit;
  final Function(Map<String, dynamic>) onNoteShare;
  final Function(Map<String, dynamic>) onNoteArchive;
  final Function(Map<String, dynamic>) onNoteDelete;
  final Function(Map<String, dynamic>) onNoteDuplicate;
  final Function(Map<String, dynamic>) onNoteMoveToCategory;
  final Function(Map<String, dynamic>) onNoteExport;

  const NotesListWidget({
    Key? key,
    required this.notes,
    required this.isLoading,
    required this.isSearching,
    required this.searchQuery,
    required this.onRefresh,
    required this.onCreateNote,
    required this.onNoteTap,
    required this.onNoteEdit,
    required this.onNoteShare,
    required this.onNoteArchive,
    required this.onNoteDelete,
    required this.onNoteDuplicate,
    required this.onNoteMoveToCategory,
    required this.onNoteExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (notes.isEmpty) {
      return EmptyStateWidget(
        onCreateNote: onCreateNote,
        isSearching: isSearching,
        searchQuery: searchQuery,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCardWidget(
            note: note,
            onTap: () => onNoteTap(note),
            onEdit: () => onNoteEdit(note),
            onShare: () => onNoteShare(note),
            onArchive: () => onNoteArchive(note),
            onDelete: () => onNoteDelete(note),
            onDuplicate: () => onNoteDuplicate(note),
            onMoveToCategory: () => onNoteMoveToCategory(note),
            onExport: () => onNoteExport(note),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 6.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: 1.5.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    height: 1.5.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 20.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      Container(
                        width: 15.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
