import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';
import 'package:myvc_wallet/services/wallet_service.dart';
import 'package:myvc_wallet/utils/common_util.dart';

class UploadIdPage extends StatefulWidget {
  const UploadIdPage({super.key});

  @override
  State<UploadIdPage> createState() => _UploadIdPageState();
}

class _UploadIdPageState extends State<UploadIdPage> {
  bool isLoading = false;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _contentFile = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Credential'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: _buildForm(),
        ));
  }

  init() async {}

  _buildForm() {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderFilePicker(
                  name: 'file',
                  decoration: InputDecoration(
                    labelText: 'Upload File',
                    errorText: _formKey.currentState?.fields['file']?.errorText,
                  ),
                  maxFiles: 1,
                  typeSelectors: const [
                    TypeSelector(
                      type: FileType.any,
                      selector: Row(
                        children: <Widget>[
                          Icon(Icons.file_upload),
                          Text('Upload'),
                        ],
                      ),
                    )
                  ],
                  validator: FormBuilderValidators.required(),
                  onChanged: (value) {
                    // print('value: $value');
                    if (value != null) {
                      // print(value[0]);
                      Map<String, dynamic> importVc =
                          CommonUtil.getJsonObjectFromFile(value[0]);
                      print(importVc.toString());
                      setState(() {
                        // Convert the selected file to a Base64 string
                        _contentFile = importVc;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final formData = _formKey.currentState!.value;
                      // Handle form data submission here
                      print(formData);
                      // String? id = await issueCredential(formData);
                      // if (id != null) {
                      //   _goToDetailPage(id.toString());
                      // }
                      _saveLocal();
                      _close();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  _saveLocal() async {
    print('to save into my wallet...');
    setState(() {
      isLoading = true;
    });

    try {
      WalletCredential walletCredential = WalletCredential.fromJson(_contentFile);
      print('Saving to local storage --> c: ${walletCredential.credentialId} - d: ${walletCredential.userDid}');

      WalletService walletService = WalletService();
      await walletService.save(walletCredential);

      // redirect to list
      _showUploadStatus(true);

    } catch (e) {
        debugPrint(e.toString());
    }


    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showUploadStatus(bool status) async {
    String textStatus = status ? 'SUCCESS' : 'FAILED';

    print('status upload: $textStatus');
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Status'),
            content: Text('Upload Credential : $textStatus'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  _close() {
      Navigator.pop(context);
  }
}
