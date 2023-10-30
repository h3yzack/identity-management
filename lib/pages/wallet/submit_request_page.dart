import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/model/present_credential.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';
import 'package:myvc_wallet/services/present_request_service.dart';
import 'package:myvc_wallet/services/wallet_service.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class SubmitRequestPage extends StatefulWidget {
  final Web3App web3App;
  final String requestData;
  
  const SubmitRequestPage({super.key, required this.web3App, required this.requestData});

  @override
  State<SubmitRequestPage> createState() => _SubmitRequestPageState();
}

class _SubmitRequestPageState extends State<SubmitRequestPage> {

  bool isLoading = false;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  late Map<String, dynamic> _requestData;
  List<WalletCredential> credentials = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Verifiable Presentation'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: _buildForm(),
        ),
        );
  }

  init() async {
    // get request data
    List<int> byteList = hex.decode(widget.requestData);
    String jsonString = utf8.decode(byteList);
    Map<String, dynamic> jsonObject = jsonDecode(jsonString);

    // get wallet credential list
    final walletService = WalletService();
    List<WalletCredential> allRecords = walletService.getAll();

    setState(() {
      _requestData = jsonObject;
      credentials = allRecords;
    });
  }

  _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'title',
                  initialValue: _requestData['title'],
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Request Title',
                    errorText:
                        _formKey.currentState?.fields['title']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderTextField(
                  name: 'requestId',
                  initialValue: _requestData['requestId'],
                  // readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Request ID',
                    errorText:
                        _formKey.currentState?.fields['requestId']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderTextField(
                  name: 'verifierAddress',
                  initialValue: _requestData['verifierAddress'],
                  // readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Verifier Address',
                    errorText:
                        _formKey.currentState?.fields['verifierAddress']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderDropdown(
                  name: 'credentialId',
                  decoration: const InputDecoration(labelText: 'Choose My Credential'),
                  validator: FormBuilderValidators.required(),
                  items: credentials
                      .map((record) => DropdownMenuItem(
                            value: record.credentialId,
                            child: Text(record.name ?? record.credentialId),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                      'Additional Information',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700
                          ),
                      ),)
                    
                  ]
                ),
                const SizedBox(height: 10),
                FormBuilderTextField(
                  name: 'fullName',
                  initialValue: _requestData['fullName'],
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    errorText:
                        _formKey.currentState?.fields['fullName']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final formData = _formKey.currentState!.value;
                      // Handle form data submission here
                      print(formData);
                      await _submitRequest(formData);
                      _close();
                    }
                  },
                  child: const Text(
                    'Submit',
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

  _submitRequest(Map<String, dynamic> formData) async {
    print('to save into blockchain...');
    setState(() {
      isLoading = true;
    });

    try {
      // WalletCredential walletCredential = WalletCredential.fromJson(_contentFile);
      // print('Saving to local storage --> c: ${walletCredential.credentialId} - d: ${walletCredential.userDid}');

      WalletService walletService = WalletService();
      // await walletService.save(walletCredential);
      WalletCredential? credential = walletService.getByKey(formData['credentialId']);

      if (credential != null) {
        Map<String, String> otherInfo = {
          'fullName': formData['fullName']
        };

        // convert to hex
        String otherInfoHex = hex.encode(utf8.encode(jsonEncode(otherInfo)));

        // assemble data
        PresentCredential requestCredential = PresentCredential(
            credentialId: formData['credentialId'], 
            userDid: credential.userDid, 
            verifierAddress: formData['verifierAddress'], 
            requestId: formData['requestId'], 
            otherInfo: otherInfoHex
        );

        print(requestCredential.toString());

        // to save into blockchain
        PresentRequestService presentRequestService = await PresentRequestService.web3().loadContract();
        bool status = await presentRequestService.saveRequest(widget.web3App, requestCredential);

        // redirect to list
        await _showStatus(status);
      }

      

    } catch (e) {
        debugPrint(e.toString());
    }


    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showStatus(bool status) async {
    String textStatus = status ? 'SUCCESS' : 'FAILED';

    print('status submit: $textStatus');
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Status'),
            content: const Text('You have submitted your verified credential to Verifier!'),
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
