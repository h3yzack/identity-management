import 'dart:convert';
import 'dart:io' as io;
import 'package:form_builder_file_picker/form_builder_file_picker.dart';

class CommonUtil  {

  static String convertPlatformFileToBase64(PlatformFile file)  {
  // Read the file's bytes
    try {
      final fileBytes = io.File(file.path!).readAsBytesSync();

      if (fileBytes.isNotEmpty) {
        // Encode the file bytes as Base64
        String base64String = base64Encode(fileBytes);
        return base64String;
      } else {
        throw Exception("Failed to read file contents.");
      }
    } catch (e) {
      print(e);
    }

    return '';
    
  }
}