import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:myid_wallet/services/issued_credential_service.dart';
import 'package:myid_wallet/widgets/text_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';


class DownloadVCPage extends StatefulWidget {
  final String? id;

  const DownloadVCPage({super.key, this.id});

  
  @override
  State<DownloadVCPage> createState() => _DownloadVCPageState();
}


class _DownloadVCPageState extends State<DownloadVCPage> {
  String _id = '';
  IssuedCredential? credential;
  String downloadData = '';
  String sharedData = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      _id = widget.id ?? '';
    });
    
  }
  
  @override
  Widget build(BuildContext context) {
    _getRecord();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Credential'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: 
        SingleChildScrollView(
          child: Center(
                    child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30.0),
                          QrImageView(
                            data: downloadData,
                            version: QrVersions.auto,
                            size: 200.0,
                            gapless: false,
                            // errorCorrectionLevel: QrErrorCorrectLevel.L,
                          ),
                          const SizedBox(height: 30.0),
                          // _getImageQr(),
                          
                          Container(
                            padding: const EdgeInsets.all(20), // Add 2px padding
                            child: TextWidget('Image', sharedData, 10),
                          ),
                          const SizedBox(height: 30.0),
                          Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: sharedData.isEmpty
                                    ? null
                                    : () => _onShare(context),
                                child: const Text('Share'),
                              );
                            },
                          ),
                          const SizedBox(height: 30.0),
                          Builder(
                            builder: (BuildContext context) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                onPressed: () => _onSave(context),
                                child: const Text('Download file'),
                              );
                            },
                          ),
                        ],
                      ),
                      
                    
                  ),
        )
        
    );
  }
  
  Future<void> _getRecord() async {
    if (_id.isNotEmpty) {
      final icService = IssuedCredentialService();
      var record = icService.getByKey(_id);
      if (record != null) {
        print('Credential ID: ${record.credentialId}');

        // List<int> data = utf8.encode(record.base64Data!);
        // String hexData = hex.encode(data);

        // var stringBytes = utf8.encode(record.base64Data!);
        // var gzipBytes = gzip.encode(stringBytes);
        // var compressedBase64String = base64.encode(gzipBytes);

        // print(compressedBase64String);

        Map<String, dynamic> jsonObject = {
          'credentialId': record.credentialId,
          'signature': record.signature,
          'issuedDate': record.issueDate!.toIso8601String(),
          'issuerAddress': record.createdBy,
          'issuerDid': record.issuerDid,
          'userDid': record.userDid,
          'signData': record.hashData,
          // 'base64Data': compressedBase64String
        };

        // Convert the JSON object to a string
        String jsonString = jsonEncode(jsonObject);

        // Convert the JSON string to bytes
        List<int> bytes = utf8.encode(jsonString);

        // Convert the bytes to a hex string
        String hexString = hex.encode(bytes);

        
        // print(hexString);

        List<int> data = utf8.encode(record.base64Data!);
        String hexData = hex.encode(data);

        // var stringBytes = utf8.encode(record.base64Data!);
        // var gzipBytes = gzip.encode(stringBytes);
        // var compressedBase64String = base64.encode(gzipBytes);

        setState(() {
          credential = record;
          downloadData = hexString;
          sharedData = hexData;
        });
      }
    }
  }

  Future<void> _onSave(BuildContext context) async {

    Map<String, dynamic> jsonObject = {
        'credentialId': credential?.credentialId,
        'signature': credential?.signature,
        'issuedDate': credential?.issueDate!.toIso8601String(),
        'issuerAddress': credential?.createdBy,
        'issuerDid': credential?.issuerDid,
        'userDid': credential?.userDid,
        'signData': credential?.hashData,
        'base64Data': credential?.base64Data
      };

      // Convert the JSON object to a string
      String jsonString = jsonEncode(jsonObject);
      List<int> bytes = utf8.encode(jsonString);
      String hexString = hex.encode(bytes);

    // File file = File('myvc.txt');
    // await file.writeAsString(hexString);
    // Uint8List bytesF = await file.readAsBytes();
    Uint8List uint8List = Uint8List.fromList(bytes);

    await FileSaver.instance.saveAs(
            name: 'myvc-wallet',
            bytes: uint8List,
            ext: 'txt',
            mimeType: MimeType.text);

  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve teh context immediately
    // surrounding the ElevatedButton.
    //
    // Teh context's `findRenderObject` returns teh first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. Teh ElevatedButton's RenderObject
    // TEMPhas its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(sharedData,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);

    // if (uri.isNotEmpty) {
    //   await Share.shareUri(Uri.parse(uri));
    // } else if (imagePaths.isNotEmpty) {
    //   final files = <XFile>[];
    //   for (var i = 0; i < imagePaths.length; i++) {
    //     files.add(XFile(imagePaths[i], name: imageNames[i]));
    //   }
    //   await Share.shareXFiles(files,
    //       text: text,
    //       subject: subject,
    //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    // } else {
    //   await Share.share(text,
    //       subject: subject,
    //       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    // }
  }
  
}