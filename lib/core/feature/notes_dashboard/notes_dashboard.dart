import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/provider/dashboard_provider.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
import 'package:my_secure_note_app/core/helper/rsa_services.dart';
import 'package:sizer/sizer.dart';
import 'package:my_secure_note_app/core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    rsaService = RSAService();
    _initializeControllers();

    // Initialize notes data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notesProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
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

  void _onSearchChanged() {
    ref.read(notesProvider.notifier).updateSearchQuery(_searchController.text);
  }

  void _toggleView() {
    ref.read(notesProvider.notifier).toggleView();
    HapticFeedback.lightImpact();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(notesProvider.notifier).refresh();
    Fluttertoast.showToast(
      msg: "Notes refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onCreateNote() {
    HapticFeedback.mediumImpact();
     ref.read(notesProvider.notifier).updateCategory("All Notes");
    context.pushNamed('note-editor');
  }

  void _onNoteTap(Map<String, dynamic> note) {
    HapticFeedback.selectionClick();
    context.pushNamed(
      'note-editor',
      extra: {'noteId': note['id'], 'mode': 'view'},
    );
  }

  void _togglePin(Map<String, dynamic> note) {
    ref.read(notesProvider.notifier).togglePin(note['id'].toString());
    HapticFeedback.lightImpact();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        onSortChanged: (value) {
          ref.read(notesProvider.notifier).updateSortBy(value);
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
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
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
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
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
          onPressed: () => context.pushNamed('settings'),
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
      icon: Icon(icon, color: AppTheme.lightTheme.colorScheme.onSurface),
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
              ref.read(notesProvider.notifier).updateCategory(category);
            },
          ),
          SizedBox(height: 2.h),
          Expanded(child: _buildNotesContent()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.grey.shade100,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasNotes) {
      return EmptyState(isSearching: isSearching);
    }

    return selectedView == 'grid'
        ? _buildGridView(filteredNotes)
        : _buildListView(filteredNotes);
  }

  Widget _buildGridView(List<Map<String, dynamic>> notes) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.75,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => _onNoteTap(note),
            onLongPress: () => _togglePin(note),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> notes) {
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
            onLongPress: () => _togglePin(note),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _onCreateNote,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'New Note',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Zynote',
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        Constants.categoryColors[note['category']] ?? Colors.grey;
    final isPinned = note['isPinned'] ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
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
                title: note['title'],
                isPinned: isPinned,
                pinColor: categoryColor,
              ),
              SizedBox(height: 1.h),
              _NotePreview(preview: note['preview']),
              SizedBox(height: 1.h),
              _NoteFooter(
                category: note['category'],
                isEncrypted: note['isEncrypted'],
                categoryColor: categoryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteHeader extends StatelessWidget {
  final String title;
  final bool isPinned;
  final Color pinColor;

  const _NoteHeader({
    required this.title,
    required this.isPinned,
    required this.pinColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPinned) Icon(Icons.push_pin, size: 16, color: pinColor),
      ],
    );
  }
}

class _NotePreview extends StatelessWidget {
  final String preview;

  const _NotePreview({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        preview,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _NoteFooter extends StatelessWidget {
  final String category;
  final bool isEncrypted;
  final Color categoryColor;

  const _NoteFooter({
    required this.category,
    required this.isEncrypted,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CategoryBadge(category: category, color: categoryColor),
        if (isEncrypted)
          const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
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
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class NoteListItem extends StatelessWidget {
  final Map<String, dynamic> note;
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
    final categoryColor =
        Constants.categoryColors[note['category']] ?? Colors.grey;
    final isPinned = note['isPinned'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
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

class _NoteListItemContent extends StatelessWidget {
  final Map<String, dynamic> note;
  final Color categoryColor;
  final bool isPinned;

  const _NoteListItemContent({
    required this.note,
    required this.categoryColor,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                note['title'],
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPinned) Icon(Icons.push_pin, size: 16, color: categoryColor),
            SizedBox(width: 3.w),
            if (note['isEncrypted'])
              const Icon(Icons.lock_rounded, size: 16, color: Colors.grey),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          note['preview'],
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _CategoryBadge(category: note['category'], color: categoryColor),
            SizedBox(width: 2.w),
            Text(
              _formatDate(note['createdAt']),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
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

class EmptyState extends StatelessWidget {
  final bool isSearching;

  const EmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.note_add_rounded,
            size: 36.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 2.h),
          Text(
            isSearching ? 'No notes found' : 'No notes yet',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 18.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isSearching
                ? 'Try adjusting your search or filters'
                : 'Tap the + button to create your first note',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
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
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDragHandle(),
          SizedBox(height: 3.h),
          _buildTitle(),
          SizedBox(height: 2.h),
          ..._buildSortOptions(context, currentSortBy),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 12.w,
        height: 0.5.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Sort By',
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
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
            ? AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.grey,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.lightTheme.colorScheme.primary : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppTheme.lightTheme.colorScheme.primary,
              )
            : null,
        onTap: () => onSortChanged(value),
      ),
    );
  }
}
