// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';

// class KeyboardAttachedToolbar extends StatelessWidget {
//   final QuillController controller;

//   const KeyboardAttachedToolbar({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//       padding: EdgeInsets.only(bottom: bottomInset),
//       child: Material(
//         elevation: 8,
//         color: Colors.white,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // First row
//             Container(
//               height: 40,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildButton(Icons.undo, 'Undo', controller.undo),
//                   _buildButton(Icons.redo, 'Redo', controller.redo),
//                   _buildButton(
//                     Icons.format_bold,
//                     'Bold',
//                     () => controller.formatSelection(Attribute.bold),
//                   ),
//                   _buildButton(
//                     Icons.format_italic,
//                     'Italic',
//                     () => controller.formatSelection(Attribute.italic),
//                   ),
//                   _buildButton(
//                     Icons.format_underline,
//                     'Underline',
//                     () => controller.formatSelection(Attribute.underline),
//                   ),
//                   _buildButton(
//                     Icons.format_strikethrough,
//                     'Strikethrough',
//                     () => controller.formatSelection(Attribute.strikeThrough),
//                   ),
//                   _buildButton(
//                     Icons.link,
//                     'Link',
//                     () => _showLinkDialog(context),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(height: 0),
//             // Second row
//             Container(
//               height: 40,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildButton(
//                     Icons.format_list_bulleted,
//                     'Bullet List',
//                     () => controller.formatSelection(Attribute.ul),
//                   ),
//                   _buildButton(
//                     Icons.format_list_numbered,
//                     'Numbered List',
//                     () => controller.formatSelection(Attribute.ol),
//                   ),
//                   _buildButton(
//                     Icons.format_quote,
//                     'Quote',
//                     () => controller.formatSelection(Attribute.blockQuote),
//                   ),
//                   _buildButton(
//                     Icons.code,
//                     'Code',
//                     () => controller.formatSelection(Attribute.codeBlock),
//                   ),
//                   _buildButton(
//                     Icons.format_color_text,
//                     'Text Color',
//                     () => _showColorPicker(context, false),
//                   ),
//                   _buildButton(
//                     Icons.format_color_fill,
//                     'Background Color',
//                     () => _showColorPicker(context, true),
//                   ),
//                   _buildButton(
//                     Icons.format_clear,
//                     'Clear Format',
//                     () => controller.formatSelection(
//                       Attribute.clone(Attribute.width,''),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(IconData icon, String tooltip, VoidCallback onTap) {
//     return IconButton(
//       icon: Icon(icon, size: 20),
//       tooltip: tooltip,
//       onPressed: onTap,
//       style: IconButton.styleFrom(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//         minimumSize: Size(36, 36),
//       ),
//     );
//   }

//   void _showLinkDialog(BuildContext context) {
//     final textController = TextEditingController();
//     final urlController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Insert Link'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: textController,
//               decoration: const InputDecoration(hintText: 'Link text'),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: urlController,
//               decoration: const InputDecoration(
//                 hintText: 'https://example.com',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (urlController.text.isNotEmpty) {
//                 controller.formatSelection(Attribute.link);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Insert'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showColorPicker(BuildContext context, bool isBackground) {
//     final colors = [
//       Colors.black,
//       Colors.red,
//       Colors.green,
//       Colors.blue,
//       Colors.orange,
//       Colors.purple,
//       Colors.grey,
//     ];

//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               isBackground ? 'Select Background Color' : 'Select Text Color',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children: colors.map((color) {
//                 return InkWell(
//                   onTap: () {
//                     if (isBackground) {
//                       controller.formatSelection(
//                         Attribute.background,

//                         // color.value,
//                       );
//                     } else {
//                       controller.formatSelection(Attribute.color);
//                     }
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';

// class KeyboardAttachedToolbar extends StatelessWidget {
//   final QuillController controller;

//   const KeyboardAttachedToolbar({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//       padding: EdgeInsets.only(bottom: bottomInset),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(top: BorderSide(color: Colors.grey.shade300)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 2),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildTinyButton(Icons.undo, 'Undo', () => controller.undo()),
//                   _buildTinyButton(Icons.redo, 'Redo', () => controller.redo()),
//                   _buildTinyButton(
//                     Icons.format_bold,
//                     'Bold',
//                     () => controller.formatText(Attribute.bold),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_italic,
//                     'Italic',
//                     () => controller.formatText(Attribute.italic),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_underline,
//                     'Underline',
//                     () => controller.formatText(Attribute.underline),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_strikethrough,
//                     'Strikethrough',
//                     () => controller.formatText(Attribute.strikeThrough),
//                   ),
//                   _buildTinyButton(
//                     Icons.link,
//                     'Link',
//                     () => controller.formatSelection(Attribute.link, ''),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_quote,
//                     'Quote',
//                     () => controller.formatSelection(Attribute.blockQuote),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_list_bulleted,
//                     'Bullets',
//                     () => controller.formatSelection(Attribute.ul),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_list_numbered,
//                     'Numbers',
//                     () => controller.formatSelection(Attribute.ol),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 2),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildTinyButton(
//                     Icons.format_indent_increase,
//                     'Indent',
//                     () => controller.formatSelection(Attribute.indentL1),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_indent_decrease,
//                     'Outdent',
//                     () =>
//                         controller.formatSelection(Attribute.indentL1.toggle()),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_clear,
//                     'Clear',
//                     () => controller.formatSelection(
//                       Attribute.clone(Attribute.clear),
//                     ),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_color_text,
//                     'Color',
//                     () => controller.formatSelection(
//                       Attribute.color,
//                       Colors.red.value,
//                     ),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_color_fill,
//                     'Bg Color',
//                     () => controller.formatSelection(
//                       Attribute.backgroundColor,
//                       Colors.yellow.value,
//                     ),
//                   ),
//                   _buildTinyButton(
//                     Icons.code,
//                     'Code',
//                     () => controller.formatSelection(Attribute.codeBlock),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_align_left,
//                     'Left',
//                     () => controller.formatSelection(Attribute.leftAlignment),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_align_center,
//                     'Center',
//                     () => controller.formatSelection(Attribute.centerAlignment),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_align_right,
//                     'Right',
//                     () => controller.formatSelection(Attribute.rightAlignment),
//                   ),
//                   _buildTinyButton(
//                     Icons.format_align_justify,
//                     'Justify',
//                     () =>
//                         controller.formatSelection(Attribute.justifyAlignment),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTinyButton(IconData icon, String tooltip, VoidCallback onTap) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(4),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(4),
//           child: Container(
//             width: 32,
//             height: 28,
//             alignment: Alignment.center,
//             child: Icon(icon, size: 18, color: Colors.grey.shade700),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';

// class KeyboardAttachedToolbar extends StatelessWidget {
//   final QuillController controller;

//   const KeyboardAttachedToolbar({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeOut,
//       padding: EdgeInsets.only(bottom: bottomInset),
//       child: Material(
//         elevation: 8,
//         color: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   QuillToolbarHistoryButton(
//                     controller: controller,
//                     isUndo: true,
//                   ),
//                   QuillToolbarHistoryButton(
//                     controller: controller,
//                     isUndo: false,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.bold,
//                     controller: controller,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.italic,
//                     controller: controller,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.underline,
//                     controller: controller,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.strikeThrough,
//                     controller: controller,
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.ol,
//                     controller: controller,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.ul,
//                     controller: controller,
//                   ),
//                   QuillToolbarToggleStyleButton(
//                     attribute: Attribute.blockQuote,
//                     controller: controller,
//                   ),
//                   QuillToolbarClearFormatButton(controller: controller),
//                   QuillToolbarIndentButton(
//                     controller: controller,
//                     isIncrease: true,
//                   ),
//                   QuillToolbarIndentButton(
//                     controller: controller,
//                     isIncrease: false,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class KeyboardAttachedToolbar extends StatelessWidget {
  final QuillController controller;

  const KeyboardAttachedToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        elevation: 8,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuillButton(
                    child: QuillToolbarHistoryButton(
                      options: QuillToolbarHistoryButtonOptions(iconSize: 12),
                      controller: controller,
                      isUndo: true,
                    ),

                    tooltip: 'Undo',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarHistoryButton(
                      options: QuillToolbarHistoryButtonOptions(iconSize: 12),
                      controller: controller,
                      isUndo: false,
                      // iconSize: 20,
                    ),
                    tooltip: 'Redo',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(iconSize: 12),
                      attribute: Attribute.bold,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Bold',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(iconSize: 12),
                      attribute: Attribute.italic,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Italic',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(iconSize: 12),
                      attribute: Attribute.underline,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Underline',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(iconSize: 12),
                      attribute: Attribute.strikeThrough,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Strikethrough',
                  ),
                  _buildIconButton(
                    icon: Icons.link,
                    tooltip: 'Link',
                    onTap: () => _showLinkDialog(context),
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(
                        iconSize: 12,
                      ),
                      attribute: Attribute.ul,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Bullet List',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(
                        iconSize: 12,
                      ),

                      attribute: Attribute.ol,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Numbered List',
                  ),
                  _buildQuillButton(
                    child: QuillToolbarToggleStyleButton(
                      options: QuillToolbarToggleStyleButtonOptions(
                        iconSize: 12,
                      ),

                      attribute: Attribute.blockQuote,
                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Quote',
                  ),
                  _buildIconButton(
                    icon: Icons.code,
                    tooltip: 'Code',
                    onTap: () =>
                        controller.formatSelection(Attribute.codeBlock),
                  ),
                  _buildIconButton(
                    icon: Icons.format_color_text,
                    tooltip: 'Text Color',
                    onTap: () => _showColorPicker(context, false),
                  ),
                  _buildIconButton(
                    icon: Icons.format_color_fill,
                    tooltip: 'Background Color',
                    onTap: () => _showColorPicker(context, true),
                  ),
                  _buildQuillButton(
                    child: QuillToolbarClearFormatButton(
                      options: QuillToolbarClearFormatButtonOptions(
                        iconSize: 12,
                      ), //QuillToolbarToggleStyleButtonOptions(iconSize: 16),

                      controller: controller,
                      // iconSize: 20,
                    ),
                    tooltip: 'Clear Format',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuillButton({required Widget child, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: Colors.grey.shade800),
          ),
        ),
      ),
    );
  }

  void _showLinkDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                labelText: 'URL',
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                final selection = controller.selection;
                if (selection.isCollapsed) {
                  controller.replaceText(
                    selection.start,
                    selection.end,
                    urlController.text,
                    null,
                  );
                  controller.formatText(
                    selection.start,
                    urlController.text.length,
                    LinkAttribute(urlController.text),
                  );
                } else {
                  controller.formatSelection(LinkAttribute(urlController.text));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, bool isBackground) {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Yellow', 'color': Colors.yellow},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Grey', 'color': Colors.grey},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBackground ? 'Select Background Color' : 'Select Text Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((colorData) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final colorValue = (colorData['color'] as Color).value;
                        if (isBackground) {
                          controller.formatSelection(Attribute.background);
                        } else {
                          controller.formatSelection(Attribute.color);
                        }
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorData['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      colorData['name'] as String,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
