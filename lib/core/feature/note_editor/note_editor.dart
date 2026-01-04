import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
import 'package:my_secure_note_app/core/feature/note_editor/provider/note_editer_provider.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/provider/dashboard_provider.dart';
import 'package:sizer/sizer.dart';
import './widgets/share_options_widget.dart';
import './widgets/custom_quill_editer.dart';
import './widgets/keyboard_attached_toolbar.dart';
import '../notes_dashboard/widgets/category_list_widget.dart';
import '../../theme/app_theme.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NoteEditor({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor>
    with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _showShareOptions = false;
  bool _initialized = false;

  late NoteEditorNotifier _notifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _notifier = ref.read(noteEditorProvider(widget.existingNote).notifier);

    _preventScreenshots();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNote();
    });
  }

  void _initializeNote() {
    if (_initialized) return;

    final state = ref.read(noteEditorProvider(widget.existingNote));

    _titleController.text = state.title;
    _titleController.removeListener(_onTitleChanged);
    _titleController.addListener(_onTitleChanged);

    final controller = _notifier.initializeQuillController(
      html: state.htmlContent,
    );
    controller.addListener(() => _onEditorChanged(controller));

    setState(() => _initialized = true);
  }

  void _onTitleChanged() {
    _notifier.updateTitle(_titleController.text);
  }

  void _onEditorChanged(QuillController controller) {
    _notifier.onEditorChanged(controller);
  }

  void _preventScreenshots() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  Future<void> _saveNote() async {
    final success = await _notifier.saveNote();

    if (!success) {
      _showToast('Cannot save empty note');
    } else {
      ref.read(notesListProvider.notifier).loadNotes();
      _showToast('Note saved securely');
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(noteEditorProvider(widget.existingNote));
    if (state.hasUnsavedChanges) {
      if (await _showUnsavedChangesDialog()) {
        ref.read(notesListProvider.notifier).updateCategory('All Notes');
      }
    }
    ref.read(notesListProvider.notifier).updateCategory('All Notes');
    return true;
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            buttonPadding: EdgeInsets.zero,
            iconPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              'Unsaved Changes',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'You have unsaved changes. Do you want to save before leaving?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Discard',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _saveNote();
                  if (mounted) Navigator.of(context).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _shareNote(String method) {
    setState(() => _showShareOptions = false);

    // final htmlContent = _notifier.getShareContent();

    switch (method) {
      case 'secure_link':
        _showToast('Generating secure encrypted link...');
        break;
      case 'qr_code':
        _showToast('Creating encrypted QR code...');
        break;
      case 'platform_share':
        _showToast('Opening system share with encryption warning...');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _titleFocusNode.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _notifier.onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noteEditorProvider(widget.existingNote));

    if (!_initialized || state.controller == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onWillPop(),
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        appBar: _buildAppBar(state),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _buildTitleField(),
                      CategoryFilterSection(
                        horizontalPadding: 0.0,
                        onCategoryChanged: (category) {
                          _notifier.updateCategory(category);
                          ref
                              .read(notesListProvider.notifier)
                              .updateCategory(category);
                        },
                      ),
                      SizedBox(height: 2.h),
                      KeyboardAttachedToolbar(controller: state.controller!),
                      SizedBox(height: 1.h),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: CustomQuillEditor(
                      initialContent:
                          widget.existingNote?['note_description'] ?? '',
                      isReadOnly: false,
                      controller: state.controller!,
                      scrollController: _scrollController,
                      hintText: 'Type here . . .',
                    ),
                  ),
                ),
              ],
            ),
            if (_showShareOptions)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showShareOptions = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ShareOptionsWidget(
                        onSecureLink: () => _shareNote('secure_link'),
                        onQRCode: () => _shareNote('qr_code'),
                        onPlatformShare: () => _shareNote('platform_share'),
                        onClose: () =>
                            setState(() => _showShareOptions = false),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Note title...',
        hintStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(
            150,
          ),
          fontWeight: FontWeight.w400,
          fontSize: 18.sp,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  PreferredSizeWidget _buildAppBar(NoteEditorState state) {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () async {
          if (await _onWillPop()) {
            if (mounted) Navigator.of(context).pop();
          }
        },
        child: Container(
          margin: EdgeInsets.all(2.w),
          child: Padding(
            padding: const EdgeInsets.only(left: 6, top: 4),
            child: CustomIconWidget(
              iconName: 'arrow_back_ios',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
      titleSpacing: 6,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secure Editor',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.lastSaved != null)
            Text(
              'Last saved: ${_notifier.formatLastSaved()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12.sp,
              ),
            ),
        ],
      ),
      actions: [
        if (state.hasUnsavedChanges && !state.isSaving)
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'Unsaved',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        GestureDetector(
          onTap: _saveNote,
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isSaving) ...[
                  SizedBox(
                    width: 4.w,
                    height: 4.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                ] else ...[
                  CustomIconWidget(
                    iconName: 'save',
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                ],
                Text(
                  state.isSaving ? 'Saving...' : 'Save',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
