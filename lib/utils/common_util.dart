import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:intl/intl.dart';

class CommonUtil {
  static String convertPlatformFileToBase64(PlatformFile file) {
    // Read the file's bytes
    try {
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes!;
      } else {
          fileBytes = io.File(file.path!).readAsBytesSync();
      }
      // final fileBytes = io.File(file.path!).readAsBytesSync();

      if (fileBytes.isNotEmpty) {
        // Encode the file bytes as Base64
        String base64String = base64Encode(fileBytes);
        return base64String;
      } else {
        throw Exception("Failed to read file contents.");
      }
    } catch (e) {
      print('----------: ${e.toString()}');
    }

    return '';
  }

  static Map<String, dynamic> getJsonObjectFromFile(PlatformFile file) {
    try {
      Uint8List fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes!;
      } else {
          fileBytes = io.File(file.path!).readAsBytesSync();
      }
      // final fileBytes = io.File(file.path!).readAsBytesSync();

      if (fileBytes.isNotEmpty) {
        // Encode the file bytes as Base64
        String jsonString = utf8.decode(fileBytes);
        return jsonDecode(jsonString);
      } else {
        throw Exception("Failed to read file contents.");
      }
    } catch (e) {
      print('----------: ${e.toString()}');
    }

    return {};
  }

  static String formatDate(DateTime? date) {
    // var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    // var inputDate = inputFormat.parse(date);

    if (date != null) {
      var outputFormat = DateFormat('dd-MM-yyyy HH:mm a');
      var outputDate = outputFormat.format(date);

      return outputDate;
    } else {
      return '-';
    }
  }

  static DateTime toDateFromString(String dateStr) {
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    var inputDate = inputFormat.parse(dateStr);

    // var outputFormat = DateFormat('dd-MM-yyyy HH:mm a');
    // var outputDate = outputFormat.format(inputDate);

    return inputDate;
  }
}
