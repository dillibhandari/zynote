import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
import 'package:my_secure_note_app/core/feature/note_editor/provider/note_editer_provider.dart';
import 'package:my_secure_note_app/core/feature/note_editor/widgets/custom_quill_editer.dart';
import 'package:my_secure_note_app/core/feature/note_editor/widgets/keyboard_attached_toolbar.dart';
import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
import 'package:sizer/sizer.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final NoteModel? existingNote;
  const NoteEditor({super.key, this.existingNote});

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor>
    with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final provider =
      noteEditorProvider(widget.existingNote?.toMap());

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// ✅ SAFE PROVIDER MUTATION
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        final notifier = ref.read(provider.notifier);
        final state = ref.read(provider);

        notifier.initializeQuillController(state.htmlContent);
        _initialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    if (state.controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Keep controller text in sync
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
      _titleController.selection = TextSelection.collapsed(
        offset: _titleController.text.length,
      );
    }

    return PopScope(
      canPop: !state.hasUnsavedChanges,
      onPopInvoked: (_) => notifier.onAppPaused(),
      child: Scaffold(
        appBar: _buildAppBar(state),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: notifier.updateTitle,
                    decoration: const InputDecoration(
                      hintText: 'Note title...',
                      border: InputBorder.none,
                    ),
                  ),
                  CategoryFilterSection(
                    // selectedCategory: state.category,
                    onCategoryChanged: notifier.updateCategory,
                  ),
                  KeyboardAttachedToolbar(
                    controller: state.controller!,
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomQuillEditor(
                isReadOnly: false,
                controller: state.controller!,
                scrollController: _scrollController,
                // onChanged: () =>
                //     notifier.onEditorChanged(state.controller!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(NoteEditorState state) {
    final notifier = ref.read(provider.notifier);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existingNote == null ? 'New Note' : 'Edit Note'),
          if (state.lastSaved != null)
            Text(
              notifier.formatLastSaved(),
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: notifier.saveNote,
          child: state.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/provider/note_editer_provider.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/widgets/custom_quill_editer.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/widgets/keyboard_attached_toolbar.dart';
// import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
// import 'package:my_secure_note_app/core/theme/app_theme.dart';
// import 'package:sizer/sizer.dart';
// import './widgets/share_options_widget.dart';

// class NoteEditor extends ConsumerStatefulWidget {
//   final NoteModel? existingNote;

//   const NoteEditor({super.key, this.existingNote});

//   @override
//   ConsumerState<NoteEditor> createState() => _NoteEditorState();
// }

// class _NoteEditorState extends ConsumerState<NoteEditor>
//     with WidgetsBindingObserver {
//   final TextEditingController _titleController = TextEditingController();
//   final FocusNode _titleFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _editorFocusNode = FocusNode();

//   bool _showShareOptions = false;
//   late AutoDisposeProviderFamily<NoteEditorNotifier, NoteEditorState, NoteModel?> _provider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _preventScreenshots();
    
//     // Initialize provider reference
//     _provider = noteEditorProvider(widget.existingNote?.toMap());
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeNote();
//     });
//   }

//   void _initializeNote() {
//     final notifier = ref.read(_provider.notifier);
//     final state = ref.read(_provider);

//     _titleController.text = state.title;
//     _titleController.addListener(_onTitleChanged);

//     if (!state.isEditing && state.controller == null) {
//       final controller = notifier.initializeQuillController();
//       controller.addListener(() => _onEditorChanged(controller));
//     }
//   }

//   // Riverpod Functions:
  
//   // 1. Update title using Riverpod
//   void _onTitleChanged() {
//     ref.read(_provider.notifier).updateTitle(_titleController.text);
//   }

//   // 2. Handle editor changes using Riverpod
//   void _onEditorChanged(QuillController controller) {
//     ref.read(_provider.notifier).onEditorChanged(controller);
//   }

//   // 3. Save note using Riverpod
//   Future<void> _saveNote() async {
//     final notifier = ref.read(_provider.notifier);
//     final success = await notifier.saveNote();

//     if (!success) {
//       _showToast('Cannot save empty note');
//     } else {
//       _showToast('Note saved securely');
//     }
//   }

//   // 4. Handle app lifecycle changes using Riverpod
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       ref.read(_provider.notifier).onAppPaused();
//     }
//   }

//   // 5. Check for unsaved changes using Riverpod
//   Future<bool> _onWillPop() async {
//     final state = ref.read(_provider);
//     if (state.hasUnsavedChanges) {
//       return await _showUnsavedChangesDialog();
//     }
//     return true;
//   }

//   // 6. Get share content using Riverpod
//   void _shareNote(String method) {
//     setState(() => _showShareOptions = false);
//     final notifier = ref.read(_provider.notifier);
//     final htmlContent = notifier.getShareContent();

//     switch (method) {
//       case 'secure_link':
//         _showToast('Generating secure encrypted link...');
//         break;
//       case 'qr_code':
//         _showToast('Creating encrypted QR code...');
//         break;
//       case 'platform_share':
//         _showToast('Opening system share with encryption warning...');
//         break;
//     }
//   }

//   // Helper functions
//   void _preventScreenshots() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//   }

//   void _showToast(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<bool> _showUnsavedChangesDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(
//               'Unsaved Changes',
//               style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             content: Text(
//               'You have unsaved changes. Do you want to save before leaving?',
//               style: AppTheme.lightTheme.textTheme.bodyMedium,
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: Text('Discard', style: TextStyle(color: Colors.red)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   await _saveNote();
//                   if (mounted) Navigator.of(context).pop(true);
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _titleController.dispose();
//     _titleFocusNode.dispose();
//     _scrollController.dispose();
//     _editorFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 7. Watch the state using Riverpod
//     final state = ref.watch(_provider);

//     if (!state.isEditing || state.controller == null) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) async {
//         if (!didPop) {
//           final shouldPop = await _onWillPop();
//           if (shouldPop && mounted) {
//             Navigator.of(context).pop();
//           }
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         appBar: _buildAppBar(state),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 2.h),
//                       _buildTitleField(),
//                       SizedBox(height: 1.h),
//                       _buildCategorySection(),
//                       SizedBox(height: 2.h),
//                       KeyboardAttachedToolbar(controller: state.controller!),
//                       SizedBox(height: 1.h),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 4.w),
//                     child: CustomQuillEditor(
//                       isReadOnly: false,
//                       controller: state.controller!,
//                       scrollController: _scrollController,
//                       hintText: 'Type here . . .',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_showShareOptions)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showShareOptions = false),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: ShareOptionsWidget(
//                         onSecureLink: () => _shareNote('secure_link'),
//                         onQRCode: () => _shareNote('qr_code'),
//                         onPlatformShare: () => _shareNote('platform_share'),
//                         onClose: () =>
//                             setState(() => _showShareOptions = false),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTitleField() {
//     return TextField(
//       controller: _titleController,
//       focusNode: _titleFocusNode,
//       style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
//         fontWeight: FontWeight.w700,
//         fontSize: 18.sp,
//       ),
//       decoration: InputDecoration(
//         hintText: 'Note title...',
//         hintStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
//           color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withOpacity(0.6),
//           fontWeight: FontWeight.w400,
//           fontSize: 18.sp,
//         ),
//         border: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         contentPadding: EdgeInsets.zero,
//       ),
//       maxLines: 2,
//       textCapitalization: TextCapitalization.sentences,
//     );
//   }

//   Widget _buildCategorySection() {
//     return Consumer(
//       builder: (context, ref, child) {
//         // 8. Watch category changes using Riverpod
//         return CategoryFilterSection(
//           horizontalPadding: 0.0,
//           onCategoryChanged: (category) {
//             ref.read(_provider.notifier).updateCategory(category);
//           },
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(NoteEditorState state) {
//     // 9. Read notifier for app bar actions
//     final notifier = ref.read(_provider.notifier);

//     return AppBar(
//       backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//       elevation: 0,
//       leading: IconButton(
//         icon: Container(
//           padding: EdgeInsets.all(2.w),
//           child: CustomIconWidget(
//             iconName: 'arrow_back_ios',
//             color: AppTheme.lightTheme.colorScheme.onSurface,
//             size: 22,
//           ),
//         ),
//         onPressed: () async {
//           if (await _onWillPop()) {
//             if (mounted) Navigator.of(context).pop();
//           }
//         },
//       ),
//       titleSpacing: 6,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.existingNote == null ? 'New Note' : 'Edit Note',
//             style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           if (state.lastSaved != null)
//             Text(
//               'Last saved: ${notifier.formatLastSaved()}',
//               style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey.shade600,
//                 fontSize: 12.sp,
//               ),
//             ),
//         ],
//       ),
//       actions: [
//         if (state.hasUnsavedChanges && !state.isSaving)
//           Padding(
//             padding: EdgeInsets.only(right: 2.w),
//             child: Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Text(
//                   'Unsaved',
//                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         GestureDetector(
//           onTap: _saveNote,
//           child: Container(
//             margin: EdgeInsets.only(right: 4.w),
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
//             decoration: BoxDecoration(
//               color: AppTheme.lightTheme.colorScheme.primary,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (state.isSaving) ...[
//                   SizedBox(
//                     width: 4.w,
//                     height: 4.w,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 2.w),
//                 ] else ...[
//                   CustomIconWidget(
//                     iconName: 'save',
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                   SizedBox(width: 1.w),
//                 ],
//                 Text(
//                   state.isSaving ? 'Saving...' : 'Save',
//                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         IconButton(
//           icon: CustomIconWidget(
//             iconName: 'share',
//             color: AppTheme.lightTheme.colorScheme.onSurface,
//             size: 20,
//           ),
//           onPressed: () => setState(() => _showShareOptions = true),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/model/note_model.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/provider/note_editer_provider.dart';
// import 'package:my_secure_note_app/core/feature/note_editor/widgets/custom_quill_editer.dart';
//   import 'package:my_secure_note_app/core/feature/note_editor/widgets/keyboard_attached_toolbar.dart';
// import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
// import 'package:my_secure_note_app/core/theme/app_theme.dart';
// import 'package:sizer/sizer.dart';
// import './widgets/share_options_widget.dart';

// class NoteEditor extends ConsumerStatefulWidget {
//   final NoteModel? existingNote;

//   const NoteEditor({super.key, this.existingNote});

//   @override
//   ConsumerState<NoteEditor> createState() => _NoteEditorState();
// }

// class _NoteEditorState extends ConsumerState<NoteEditor>
//     with WidgetsBindingObserver {
//   final TextEditingController _titleController = TextEditingController();
//   final FocusNode _titleFocusNode = FocusNode();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _editorFocusNode = FocusNode();

//   bool _showShareOptions = false;
//   late AutoDisposeStateNotifierProviderFamily<NoteEditorNotifier, NoteEditorState, NoteModel?> _provider;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _preventScreenshots();
    
//     // Initialize provider reference
//     _provider = noteEditorProvider(widget.existingNote);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Initialize after the widget is mounted
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeNote();
//     });
//   }

//   void _initializeNote() {
//     final notifier = ref.read(_provider.notifier);
//     final state = ref.read(_provider);

//     // Setup title controller
//     _titleController.text = state.title;
//     _titleController.addListener(_onTitleChanged);

//     // Initialize quill controller if not already initialized
//     if (!state.isEditing && state.controller == null) {
//       final controller = notifier.initializeQuillController();
//       controller.addListener(() => _onEditorChanged(controller));
//     }
//   }

//   void _onTitleChanged() {
//     ref.read(_provider.notifier).updateTitle(_titleController.text);
//   }

//   void _onEditorChanged(QuillController controller) {
//     ref.read(_provider.notifier).onEditorChanged(controller);
//   }

//   void _preventScreenshots() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//   }

//   Future<void> _saveNote() async {
//     final notifier = ref.read(_provider.notifier);
//     final success = await notifier.saveNote();

//     if (!success) {
//       _showToast('Cannot save empty note');
//     } else {
//       _showToast('Note saved securely');
//     }
//   }

//   void _showToast(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<bool> _onWillPop() async {
//     final state = ref.read(_provider);
//     if (state.hasUnsavedChanges) {
//       return await _showUnsavedChangesDialog();
//     }
//     return true;
//   }

//   Future<bool> _showUnsavedChangesDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text(
//               'Unsaved Changes',
//               style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             content: Text(
//               'You have unsaved changes. Do you want to save before leaving?',
//               style: AppTheme.lightTheme.textTheme.bodyMedium,
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: Text('Discard', style: TextStyle(color: Colors.red)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   await _saveNote();
//                   if (mounted) Navigator.of(context).pop(true);
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }

//   void _shareNote(String method) {
//     setState(() => _showShareOptions = false);

//     final notifier = ref.read(_provider.notifier);
//     final htmlContent = notifier.getShareContent();

//     switch (method) {
//       case 'secure_link':
//         _showToast('Generating secure encrypted link...');
//         break;
//       case 'qr_code':
//         _showToast('Creating encrypted QR code...');
//         break;
//       case 'platform_share':
//         _showToast('Opening system share with encryption warning...');
//         break;
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _titleController.dispose();
//     _titleFocusNode.dispose();
//     _scrollController.dispose();
//     _editorFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       ref.read(_provider.notifier).onAppPaused();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(_provider);

//     // Show loading if controller is not initialized
//     if (!state.isEditing || state.controller == null) {
//       return Scaffold(
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return PopScope(
//       onPopInvokedWithResult: (didPop, result) async {
//         if (!didPop) {
//           final shouldPop = await _onWillPop();
//           if (shouldPop && mounted) {
//             Navigator.of(context).pop();
//           }
//         }
//       },
//       child: Scaffold(
//         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//         appBar: _buildAppBar(state),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 2.h),
//                       _buildTitleField(),
//                       SizedBox(height: 1.h),
//                       _buildCategorySection(),
//                       SizedBox(height: 2.h),
//                       KeyboardAttachedToolbar(controller: state.controller!),
//                       SizedBox(height: 1.h),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 4.w),
//                     child: CustomQuillEditor(
//                       isReadOnly: false,
//                       controller: state.controller!,
//                       scrollController: _scrollController,
//                       // focusNode: _editorFocusNode,
//                       hintText: 'Type here . . .',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (_showShareOptions)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showShareOptions = false),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.5),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: ShareOptionsWidget(
//                         onSecureLink: () => _shareNote('secure_link'),
//                         onQRCode: () => _shareNote('qr_code'),
//                         onPlatformShare: () => _shareNote('platform_share'),
//                         onClose: () =>
//                             setState(() => _showShareOptions = false),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTitleField() {
//     return TextField(
//       controller: _titleController,
//       focusNode: _titleFocusNode,
//       style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
//         fontWeight: FontWeight.w700,
//         fontSize: 18.sp,
//       ),
//       decoration: InputDecoration(
//         hintText: 'Note title...',
//         hintStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
//           color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withOpacity(0.6),
//           fontWeight: FontWeight.w400,
//           fontSize: 18.sp,
//         ),
//         border: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         contentPadding: EdgeInsets.zero,
//       ),
//       maxLines: 2,
//       textCapitalization: TextCapitalization.sentences,
//     );
//   }

//   Widget _buildCategorySection() {
//     return Consumer(
//       builder: (context, ref, child) {
//         // final state = ref.watch(_provider);
//         return CategoryFilterSection(
//           horizontalPadding: 0.0,
//           // selectedCategory: state.category,
//           onCategoryChanged: (category) {
//             ref.read(_provider.notifier).updateCategory(category);
//           },
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(NoteEditorState state) {
//     final notifier = ref.read(_provider.notifier);

//     return AppBar(
//       backgroundColor: AppTheme.lightTheme.colorScheme.surface,
//       elevation: 0,
//       leading: IconButton(
//         icon: Container(
//           padding: EdgeInsets.all(2.w),
//           child: CustomIconWidget(
//             iconName: 'arrow_back_ios',
//             color: AppTheme.lightTheme.colorScheme.onSurface,
//             size: 22,
//           ),
//         ),
//         onPressed: () async {
//           if (await _onWillPop()) {
//             if (mounted) Navigator.of(context).pop();
//           }
//         },
//       ),
//       titleSpacing: 6,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.existingNote == null ? 'New Note' : 'Edit Note',
//             style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           if (state.lastSaved != null)
//             Text(
//               'Last saved: ${notifier.formatLastSaved()}',
//               style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey.shade600,
//                 fontSize: 12.sp,
//               ),
//             ),
//         ],
//       ),
//       actions: [
//         if (state.hasUnsavedChanges && !state.isSaving)
//           Padding(
//             padding: EdgeInsets.only(right: 2.w),
//             child: Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 SizedBox(width: 1.w),
//                 Text(
//                   'Unsaved',
//                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         GestureDetector(
//           onTap: _saveNote,
//           child: Container(
//             margin: EdgeInsets.only(right: 4.w),
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
//             decoration: BoxDecoration(
//               color: AppTheme.lightTheme.colorScheme.primary,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (state.isSaving) ...[
//                   SizedBox(
//                     width: 4.w,
//                     height: 4.w,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   ),
//                   SizedBox(width: 2.w),
//                 ] else ...[
//                   CustomIconWidget(
//                     iconName: 'save',
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                   SizedBox(width: 1.w),
//                 ],
//                 Text(
//                   state.isSaving ? 'Saving...' : 'Save',
//                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         IconButton(
//           icon: CustomIconWidget(
//             iconName: 'share',
//             color: AppTheme.lightTheme.colorScheme.onSurface,
//             size: 20,
//           ),
//           onPressed: () => setState(() => _showShareOptions = true),
//         ),
//       ],
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:my_secure_note_app/core/common/widgets/custom_icon_widget.dart';
// // import 'package:my_secure_note_app/core/feature/note_editor/provider/note_editer_provider.dart';
// // import 'package:my_secure_note_app/core/feature/note_editor/widgets/custom_quill_editer.dart';
// // import 'package:my_secure_note_app/core/feature/note_editor/widgets/keyboard_attached_toolbar.dart';
// // import 'package:my_secure_note_app/core/feature/notes_dashboard/widgets/category_list_widget.dart';
// // import 'package:my_secure_note_app/core/feature/notes_dashboard/provider/dashboard_provider.dart';
// // import 'package:my_secure_note_app/core/theme/app_theme.dart';
// // import 'package:sizer/sizer.dart';
// // import './widgets/share_options_widget.dart';

// // class NoteEditor extends ConsumerStatefulWidget {
// //   final Map<String, dynamic>? existingNote;

// //   const NoteEditor({super.key, this.existingNote});

// //   @override
// //   ConsumerState<NoteEditor> createState() => _NoteEditorState();
// // }

// // class _NoteEditorState extends ConsumerState<NoteEditor>
// //     with WidgetsBindingObserver {
// //   final TextEditingController _titleController = TextEditingController();
// //   final FocusNode _titleFocusNode = FocusNode();
// //   final ScrollController _scrollController = ScrollController();
// //   final FocusNode _focusNode = FocusNode();

// //   bool _showShareOptions = false;
// //   bool _initialized = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //     _preventScreenshots();

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _initializeNote();
// //     });
// //   }

// //   void _initializeNote() {
// //     final notifier = ref.read(noteEditorProvider(widget.existingNote).notifier);
// //     final state = ref.read(noteEditorProvider(widget.existingNote));

// //     _titleController.text = state.title;
// //     _titleController.addListener(_onTitleChanged);

// //     final controller = notifier.initializeQuillController(state.htmlContent);
// //     controller.addListener(() => _onEditorChanged(controller));

// //     setState(() => _initialized = true);
// //   }

// //   void _onTitleChanged() {
// //     ref
// //         .read(noteEditorProvider(widget.existingNote).notifier)
// //         .updateTitle(_titleController.text);
// //   }

// //   void _onEditorChanged(controller) {
// //     ref
// //         .read(noteEditorProvider(widget.existingNote).notifier)
// //         .onEditorChanged(controller);
// //   }

// //   void _preventScreenshots() {
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
// //   }

// //   Future<void> _saveNote() async {
// //     final notifier = ref.read(noteEditorProvider(widget.existingNote).notifier);
// //     final success = await notifier.saveNote();

// //     if (!success) {
// //       _showToast('Cannot save empty note');
// //     } else {
// //       _showToast('Note saved securely');
// //     }
// //   }

// //   void _showToast(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         duration: const Duration(seconds: 2),
// //         behavior: SnackBarBehavior.floating,
// //       ),
// //     );
// //   }

// //   Future<bool> _onWillPop() async {
// //     final state = ref.read(noteEditorProvider(widget.existingNote));
// //     if (state.hasUnsavedChanges) {
// //       return await _showUnsavedChangesDialog();
// //     }
// //     return true;
// //   }

// //   Future<bool> _showUnsavedChangesDialog() async {
// //     return await showDialog<bool>(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: Text(
// //               'Unsaved Changes',
// //               style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //             content: Text(
// //               'You have unsaved changes. Do you want to save before leaving?',
// //               style: AppTheme.lightTheme.textTheme.bodyMedium,
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.of(context).pop(true),
// //                 child: Text('Discard', style: TextStyle(color: Colors.red)),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.of(context).pop(false),
// //                 child: const Text('Cancel'),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () async {
// //                   await _saveNote();
// //                   if (mounted) Navigator.of(context).pop(true);
// //                 },
// //                 child: const Text('Save'),
// //               ),
// //             ],
// //           ),
// //         ) ??
// //         false;
// //   }

// //   void _shareNote(String method) {
// //     setState(() => _showShareOptions = false);

// //     final notifier = ref.read(noteEditorProvider(widget.existingNote).notifier);
// //     final htmlContent = notifier.getShareContent();

// //     switch (method) {
// //       case 'secure_link':
// //         _showToast('Generating secure encrypted link...');
// //         break;
// //       case 'qr_code':
// //         _showToast('Creating encrypted QR code...');
// //         break;
// //       case 'platform_share':
// //         _showToast('Opening system share with encryption warning...');
// //         break;
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     _titleController.dispose();
// //     _titleFocusNode.dispose();
// //     _scrollController.dispose();
// //     _focusNode.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.paused) {
// //       ref.read(noteEditorProvider(widget.existingNote).notifier).onAppPaused();
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final state = ref.watch(noteEditorProvider(widget.existingNote));

// //     if (!_initialized || state.controller == null) {
// //       return Scaffold(
// //         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
// //         body: const Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     return PopScope(
// //       onPopInvokedWithResult: (didPop, result) async => _onWillPop(),
// //       child: Scaffold(
// //         backgroundColor: AppTheme.lightTheme.colorScheme.surface,
// //         appBar: _buildAppBar(state),
// //         body: Stack(
// //           children: [
// //             Column(
// //               children: [
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 4.w),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       SizedBox(height: 2.h),
// //                       _buildTitleField(),
// //                       CategoryFilterSection(
// //                         horizontalPadding: 0.0,
// //                         onCategoryChanged: (category) {
// //                           // ref
// //                           //     .read(notesProvider.notifier)
// //                           //     .updateCategory(category);
// //                           // ref
// //                           //     .read(
// //                           //       noteEditorProvider(
// //                           //         widget.existingNote,
// //                           //       ).notifier,
// //                           //     )
// //                           //     .updateCategory(category);
// //                         },
// //                       ),
// //                       SizedBox(height: 2.h),
// //                       KeyboardAttachedToolbar(controller: state.controller!),
// //                       SizedBox(height: 1.h),
// //                     ],
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 4.w),
// //                     child: CustomQuillEditor(
// //                       isReadOnly: false,
// //                       controller: state.controller!,
// //                       scrollController: _scrollController,
// //                       hintText: 'Type here . . .',
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             if (_showShareOptions)
// //               Positioned.fill(
// //                 child: GestureDetector(
// //                   onTap: () => setState(() => _showShareOptions = false),
// //                   child: Container(
// //                     color: Colors.black.withOpacity(0.5),
// //                     child: Align(
// //                       alignment: Alignment.bottomCenter,
// //                       child: ShareOptionsWidget(
// //                         onSecureLink: () => _shareNote('secure_link'),
// //                         onQRCode: () => _shareNote('qr_code'),
// //                         onPlatformShare: () => _shareNote('platform_share'),
// //                         onClose: () =>
// //                             setState(() => _showShareOptions = false),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTitleField() {
// //     return TextField(
// //       controller: _titleController,
// //       focusNode: _titleFocusNode,
// //       style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
// //         fontWeight: FontWeight.w700,
// //         fontSize: 18.sp,
// //       ),
// //       decoration: InputDecoration(
// //         hintText: 'Note title...',
// //         hintStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
// //           color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(
// //             alpha: 0.6,
// //           ),
// //           fontWeight: FontWeight.w400,
// //           fontSize: 18.sp,
// //         ),
// //         border: InputBorder.none,
// //         enabledBorder: InputBorder.none,
// //         focusedBorder: InputBorder.none,
// //         contentPadding: EdgeInsets.zero,
// //       ),
// //       maxLines: 2,
// //       textCapitalization: TextCapitalization.sentences,
// //     );
// //   }

// //   PreferredSizeWidget _buildAppBar(NoteEditorState state) {
// //     final notifier = ref.read(noteEditorProvider(widget.existingNote).notifier);

// //     return AppBar(
// //       backgroundColor: AppTheme.lightTheme.colorScheme.surface,
// //       elevation: 0,
// //       leading: GestureDetector(
// //         onTap: () async {
// //           if (await _onWillPop()) {
// //             if (mounted) Navigator.of(context).pop();
// //           }
// //         },
// //         child: Container(
// //           margin: EdgeInsets.all(2.w),
// //           child: Padding(
// //             padding: EdgeInsetsGeometry.only(left: 6, top: 4),
// //             child: CustomIconWidget(
// //               iconName: 'arrow_back_ios',
// //               color: AppTheme.lightTheme.colorScheme.onSurface,
// //               size: 22,
// //             ),
// //           ),
// //         ),
// //       ),
// //       titleSpacing: 6,
// //       title: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Secure Editor',
// //             style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           if (state.lastSaved != null)
// //             Text(
// //               'Last saved: ${notifier.formatLastSaved()}',
// //               style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
// //                 color: Colors.grey.shade600,
// //                 fontSize: 12.sp,
// //               ),
// //             ),
// //         ],
// //       ),
// //       actions: [
// //         if (state.hasUnsavedChanges && !state.isSaving)
// //           Padding(
// //             padding: EdgeInsets.only(right: 2.w),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 8,
// //                   height: 8,
// //                   decoration: BoxDecoration(
// //                     color: Colors.orange,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //                 SizedBox(width: 1.w),
// //                 Text(
// //                   'Unsaved',
// //                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
// //                     color: Colors.orange,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         GestureDetector(
// //           onTap: _saveNote,
// //           child: Container(
// //             margin: EdgeInsets.only(right: 4.w),
// //             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
// //             decoration: BoxDecoration(
// //               color: AppTheme.lightTheme.colorScheme.primary,
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 if (state.isSaving) ...[
// //                   SizedBox(
// //                     width: 4.w,
// //                     height: 4.w,
// //                     child: CircularProgressIndicator(
// //                       strokeWidth: 2,
// //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                     ),
// //                   ),
// //                   SizedBox(width: 2.w),
// //                 ] else ...[
// //                   CustomIconWidget(
// //                     iconName: 'save',
// //                     color: Colors.white,
// //                     size: 16,
// //                   ),
// //                   SizedBox(width: 1.w),
// //                 ],
// //                 Text(
// //                   state.isSaving ? 'Saving...' : 'Save',
// //                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
