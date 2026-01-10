// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/provider/dashboard_provider.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/note_grid_loading.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import '../../helper/rsa_services.dart';
import '../../preferances/shared_preferences.dart';

class NotesDashboard extends ConsumerStatefulWidget {
  const NotesDashboard({super.key});

  @override
  ConsumerState<NotesDashboard> createState() => _NotesDashboardState();
}

class _NotesDashboardState extends ConsumerState<NotesDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late RSAService rsaService;
  late FocusNode _searchFocusNode;
  late final StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    rsaService = RSAService();
    _initializeControllers();
    initialKeyBoard();
    // Load notes dynamically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesListProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    _searchFocusNode.dispose();
    _keyboardSubscription.cancel();
    super.dispose();
  }

  void _initializeControllers() {
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _fabAnimationController.forward();
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void initialKeyBoard() {
    _keyboardSubscription = KeyboardVisibilityController().onChange.listen((
      visible,
    ) {
      if (!visible && _searchFocusNode.hasFocus) {
        _searchFocusNode.unfocus();
      }
    });
  }

  void _onSearchChanged() {
    ref
        .read(notesListProvider.notifier)
        .updateSearchQuery(_searchController.text);
  }

  void _toggleView() {
    ref.read(notesListProvider.notifier).toggleView();
    HapticFeedback.lightImpact();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(notesListProvider.notifier).loadNotes();
    Fluttertoast.showToast(
      msg: "Notes refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onCreateNote() {
    HapticFeedback.mediumImpact();
    AppSettings().recentlyAddedNoteId = '';
    ref.read(notesListProvider.notifier).updateCategory("All Notes");
    context.pushNamed(
      'note-editor',
      extra: {'note_title': '', 'note_description': ''},
    );
  }

  void _onNoteTap(NoteModel note) {
    AppSettings().recentlyAddedNoteId = note.noteId;
    ref.read(notesListProvider.notifier).updateCategory(note.noteCategory);
    HapticFeedback.selectionClick();
    context.pushNamed('note-editor', extra: note.toMap());
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        onSortChanged: (value) {
          ref.read(notesListProvider.notifier).updateSortBy(value);
          context.pop();
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to search controller changes
    _searchController.removeListener(_onSearchChanged);
    _searchController.addListener(_onSearchChanged);

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [_buildAppBar()],
        body: _buildBody(),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: _buildFloatingActionButton(),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final selectedView = ref.watch(selectedViewProvider);

    return SliverAppBar(
      expandedHeight: 12.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: const FlexibleSpaceBar(
        title: _AppBarTitle(),
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        _buildAppBarAction(
          icon: selectedView == 'grid'
              ? Icons.view_list_rounded
              : Icons.grid_view_rounded,
          onPressed: _toggleView,
          tooltip: 'Toggle View',
        ),
        _buildAppBarAction(
          icon: Icons.filter_list_rounded,
          onPressed: _showFilterOptions,
          tooltip: 'Sort',
        ),
        _buildAppBarAction(
          icon: Icons.settings_rounded,
          onPressed: () => context.pushNamed('note-settings'),
          tooltip: 'Settings',
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      tooltip: tooltip,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      top: false,
      bottom: true,
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: 1.h),
          CategoryFilterSection(
            onCategoryChanged: (category) {
              ref.read(notesListProvider.notifier).updateCategory(category);
            },
          ),
          SizedBox(height: 2.h),
          Expanded(child: _buildNotesContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TextField(
        focusNode: _searchFocusNode,
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    final isLoading = ref.watch(isLoadingProvider);
    final filteredNotes = ref.watch(filteredNotesProvider);
    final selectedView = ref.watch(selectedViewProvider);
    final hasNotes = ref.watch(hasNotesProvider);
    final isSearching = ref.watch(isSearchingProvider);

    if (isLoading) {
      return Center(
        child: NotesShimmerLoader(
          viewType: selectedView == 'grid'
              ? NotesViewType.grid
              : NotesViewType.list,
        ),
      );
    }

    if (!hasNotes) return EmptyState(isSearching: isSearching);

    return selectedView == 'grid'
        ? _buildGridView(filteredNotes)
        : _buildListView(filteredNotes);
  }

  Widget _buildGridView(List<NoteModel> notes) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(note: note, onTap: () => _onNoteTap(note));
        },
      ),
    );
  }

  Widget _buildListView(List<NoteModel> notes) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteListItem(
            note: note,
            onTap: () => _onNoteTap(note),
            onLongPress: () {},
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.onSurface
        : AppTheme.primaryLight;
    final foregroundColor = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.onSecondary;
    return GestureDetector(
      onTap: _onCreateNote,
      child: Container(
        width: 140,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: foregroundColor),
              SizedBox(width: 1.h),
              Text(
                "New Note ",
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AppBar title
class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Zynote',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoryColor =
        Constants.categoryColors[note.noteCategory] ?? Colors.grey;
    final isPinned = note.pinned;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteHeader(
                title: note.noteTitle,
                isPinned: isPinned,
                pinColor: categoryColor,
                onDelete: () {
                  ref.read(notesListProvider.notifier).deleteNote(note.noteId);
                  HapticFeedback.mediumImpact();
                },
                onPinToggle: () {
                  ref.read(notesListProvider.notifier).togglePin(note.noteId);
                  HapticFeedback.lightImpact();
                },
              ),
              SizedBox(height: 1.h),
              _NotePreview(preview: note.preview),
              SizedBox(height: 1.h),
              _NoteFooter(
                isPinned: isPinned,
                category: note.noteCategory,
                isEncrypted: true,
                categoryColor: categoryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List note item
class NoteListItem extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        Constants.categoryColors[note.noteCategory] ?? Colors.grey;
    final isPinned = note.pinned;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: _NoteListItemContent(
            note: note,
            categoryColor: categoryColor,
            isPinned: isPinned,
          ),
        ),
      ),
    );
  }
}

class _NoteListItemContent extends ConsumerWidget {
  final NoteModel note;
  final Color categoryColor;
  final bool isPinned;

  const _NoteListItemContent({
    required this.note,
    required this.categoryColor,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    void onPinToggle() {
      ref.read(notesListProvider.notifier).togglePin(note.noteId);
      HapticFeedback.lightImpact();
    }

    void onDelete() {
      ref.read(notesListProvider.notifier).deleteNote(note.noteId);
      HapticFeedback.mediumImpact();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                note.noteTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Builder(
              builder: (context) {
                return InkWell(
                  onTap: () async {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final Offset offset = button.localToGlobal(Offset.zero);
                    final Size size = button.size;

                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + size.height,
                        offset.dx + size.width,
                        offset.dy,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'pin',
                          child: Text(isPinned ? 'Unpin' : 'Pin'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );

                    if (selected == null) return;

                    switch (selected) {
                      case 'pin':
                        onPinToggle();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  child: Icon(Icons.more_vert, size: 18.sp),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          note.preview,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _CategoryBadge(category: note.noteCategory, color: categoryColor),
            SizedBox(width: 2.w),
            Text(
              _formatDate(DateTime.parse(note.createdAt)),
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Spacer(),
            if (isPinned) Icon(Icons.push_pin, size: 16, color: categoryColor),
            SizedBox(width: 3.w),
            Icon(
              Icons.lock_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _NoteHeader extends StatelessWidget {
  final String title;
  final bool isPinned;
  final Color pinColor;
  final void Function()? onPinToggle;
  final void Function()? onDelete;

  const _NoteHeader({
    required this.title,
    required this.isPinned,
    required this.pinColor,
    this.onPinToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () async {
                      final RenderBox button =
                          context.findRenderObject() as RenderBox;
                      final Offset offset = button.localToGlobal(Offset.zero);
                      final Size size = button.size;

                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy + size.height,
                          offset.dx + size.width,
                          offset.dy,
                        ),
                        items: [
                          PopupMenuItem(
                            value: 'pin',
                            child: Text(isPinned ? 'Unpin' : 'Pin'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      );

                      if (selected == null) return;

                      switch (selected) {
                        case 'pin':
                          if (onPinToggle != null) onPinToggle!();
                          break;
                        case 'delete':
                          if (onDelete != null) onDelete!();
                          break;
                      }
                    },
                    child: Icon(Icons.more_vert, size: 18.sp),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotePreview extends StatelessWidget {
  final String preview;

  const _NotePreview({required this.preview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Text(
        softWrap: true,
        preview,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 7,
        textScaler: TextScaler.linear(1.05),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _NoteFooter extends StatelessWidget {
  final String category;
  final bool isEncrypted;
  final bool isPinned;
  final Color categoryColor;

  const _NoteFooter({
    required this.category,
    required this.isEncrypted,
    required this.isPinned,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CategoryBadge(category: category, color: categoryColor),
        Spacer(),
        if (isPinned) Icon(Icons.push_pin, size: 16.sp, color: categoryColor),
        SizedBox(width: 4.w),
        if (isEncrypted)
          Icon(
            Icons.lock_rounded,
            size: 16.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  final Color color;

  const _CategoryBadge({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final bool isSearching;

  const EmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.note_add_rounded,
            size: 36.sp,
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: 2.h),
          Text(
            isSearching ? 'No notes found' : 'No notes yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 18.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isSearching
                ? 'Try adjusting your search or filters'
                : 'Tap the + button to create your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  final ValueChanged<String> onSortChanged;

  const FilterBottomSheet({super.key, required this.onSortChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSortBy = ref.watch(sortByProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(context),
          SizedBox(height: 3.h),
          _buildTitle(context),
          SizedBox(height: 2.h),
          ..._buildSortOptions(context, currentSortBy),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 12.w,
        height: 0.5.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Sort By',
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  List<Widget> _buildSortOptions(BuildContext context, String currentSortBy) {
    return [
      _buildSortOption(
        context,
        currentSortBy: currentSortBy,
        title: 'Newest First',
        value: 'newest',
        icon: Icons.arrow_downward_rounded,
      ),
      _buildSortOption(
        context,
        currentSortBy: currentSortBy,
        title: 'Oldest First',
        value: 'oldest',
        icon: Icons.arrow_upward_rounded,
      ),
      _buildSortOption(
        context,
        currentSortBy: currentSortBy,
        title: 'Title (A-Z)',
        value: 'title',
        icon: Icons.sort_by_alpha_rounded,
      ),
      _buildSortOption(
        context,
        currentSortBy: currentSortBy,
        title: 'Category',
        value: 'category',
        icon: Icons.folder_rounded,
      ),
    ];
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String currentSortBy,
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = currentSortBy == value;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () => onSortChanged(value),
      ),
    );
  }
}
