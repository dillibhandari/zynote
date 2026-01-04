import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:sizer/sizer.dart';

typedef FutureStringCallback = Future<String> Function(String htmlText);

class CustomQuillEditor extends StatefulWidget {
  final String? initialContent;
  final FutureStringCallback? onContentChanged;
  final bool isReadOnly;
  final QuillController controller;
  final ScrollController scrollController;
  final String? hintText;

  const CustomQuillEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    required this.isReadOnly,
    required this.controller,
    required this.scrollController,
    this.hintText,
  });

  @override
  State<CustomQuillEditor> createState() => _CustomQuillEditorState();
}

class _CustomQuillEditorState extends State<CustomQuillEditor> {
  final FocusNode _focusNode = FocusNode();
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _checkIfEmpty();
    widget.controller.addListener(_onTextChanged);
  }

  void _checkIfEmpty() {
    final plainText = widget.controller.document.toPlainText();
    final isEmpty = plainText.trim().isEmpty || plainText == '\n';
    if (_showHint != isEmpty) {
      setState(() {
        _showHint = isEmpty;
      });
    }
  }

  void _onTextChanged() {
    _checkIfEmpty();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients && mounted) {
        final currentScroll = widget.scrollController.offset;
        final maxScroll = widget.scrollController.position.maxScrollExtent;

        if (maxScroll - currentScroll < 150) {
          widget.scrollController.animateTo(
            maxScroll,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(height: 2.h),
          Expanded(
            child: Container(
              decoration: _editorDecoration(),
              child: Stack(
                children: [
                  if (_showHint && widget.hintText != null)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.hintText!,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  CupertinoScrollbar(
                    controller: widget.scrollController,
                    child: QuillEditor(
                      controller: widget.controller,
                      scrollController: widget.scrollController,
                      focusNode: _focusNode,
                      config: _editorConfig(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _editorDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }

  QuillEditorConfig _editorConfig() {
    return QuillEditorConfig(
      scrollable: true,
      expands: false,
      scrollBottomInset: 50,
      detectWordBoundary: true,
      searchConfig: QuillSearchConfig(
        searchEmbedMode: SearchEmbedMode.plainText,
      ),
      autoFocus: false,
      showCursor: true,
      padding: const EdgeInsets.all(16),
      customStyles: DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          const HorizontalSpacing(2, 8),
          const VerticalSpacing(0, 0),
          const VerticalSpacing(0, 0),
          null,
        ),
        bold: const TextStyle(fontWeight: FontWeight.bold),
        italic: const TextStyle(fontStyle: FontStyle.italic),
        underline: const TextStyle(decoration: TextDecoration.underline),
        strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
        link: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        h1: DefaultTextBlockStyle(
          const TextStyle(
            fontSize: 28,
            height: 1.3,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(16, 8),
          const VerticalSpacing(0, 0),
          null,
        ),
        h2: DefaultTextBlockStyle(
          const TextStyle(
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(12, 8),
          const VerticalSpacing(0, 0),
          null,
        ),
        h3: DefaultTextBlockStyle(
          const TextStyle(
            fontSize: 20,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(10, 6),
          const VerticalSpacing(0, 0),
          null,
        ),
      ),

      embedBuilders: [
        ...FlutterQuillEmbeds.editorBuilders(),
        TimeStampEmbedBuilder(),
      ],
    );
  }
}

class TimeStampEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            embedContext.node.value.data as String,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
