import 'dart:convert';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String base64Image;

  const ImageWidget(this.base64Image, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10), // Add 10px padding
      child: Image.memory(
        base64Decode(base64Image),
        width: 350,
        height: 250,
        fit: BoxFit.scaleDown, // Use BoxFit.scaleDown to maintain aspect ratio
      ),
    );
  }
}
