import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String data;
  final String label;
  final int maxLines;

  const TextWidget(this.label, this.data, this.maxLines, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2), // Add 2px padding
      child: TextField(
        decoration: InputDecoration(labelText: label),
        readOnly: true,
        maxLines: maxLines,
        controller: TextEditingController(text: data),
      ),
    );
  }
}
