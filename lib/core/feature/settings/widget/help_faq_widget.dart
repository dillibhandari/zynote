import 'package:flutter/material.dart';
import 'package:my_secure_note_app/core/common/widgets/custom_app_bar.dart';

class FAQPage extends StatelessWidget {
  final String title;
  const FAQPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I create a new note?',
        'answer':
            'Tap the "New Note" button at the bottom of the screen to create a new note instantly.',
      },
      {
        'question': 'How do I organize notes into categories?',
        'answer':
            'You can use the Personal and Work tabs to categorize your notes, or create custom categories in the settings.',
      },
      {
        'question': 'Can I search through my notes?',
        'answer':
            'Yes! Use the search bar at the top of the main screen to quickly find any note by keyword.',
      },
      {
        'question': 'Is there a limit to how many notes I can create?',
        'answer':
            'No limit! Create as many notes as you need to stay organized.',
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              ...faqs.map(
                (faq) =>
                    FAQItem(question: faq['question']!, answer: faq['answer']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({Key? key, required this.question, required this.answer})
    : super(key: key);

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}
