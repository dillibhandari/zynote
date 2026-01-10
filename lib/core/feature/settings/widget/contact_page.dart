// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  final String title;
  const ContactPage({super.key, required this.title});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _subjectForContactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _subjectForContactController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      return;
    }

    final subject = Uri.encodeComponent(
      'Contact For - ${_subjectForContactController.text.trim()}',
    );

    final body = Uri.encodeComponent(
      'Name: ${_nameController.text.trim()}\n'
      'Email: ${_emailController.text.trim()}\n\n'
      'Message:\n${_messageController.text.trim()}',
    );

    final emailUri = Uri.parse(
      'mailto:yakstacksolution@gmail.com?subject=$subject&body=$body',
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email app opened'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );

      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to open email app'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid =
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _messageController.text.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Us',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Name', _nameController, 'Your name'),
              const SizedBox(height: 16),

              _buildTextField(
                'Subject',
                _subjectForContactController,
                'Your subject',
              ),

              const SizedBox(height: 16),
              _buildTextField(
                'Email',
                _emailController,
                'your.email@example.com',
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Message',
                _messageController,
                'Tell us what\'s on your mind...',
                TextInputType.multiline,
                4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isValid ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send Message',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, [
    TextInputType? keyboardType,
    int maxLines = 1,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
