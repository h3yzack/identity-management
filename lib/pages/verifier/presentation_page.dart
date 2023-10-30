import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/model/present_credential.dart';
import 'package:myvc_wallet/model/verified_credential.dart';
import 'package:myvc_wallet/services/issued_credential_service.dart';
import 'package:myvc_wallet/services/present_request_service.dart';
import 'package:myvc_wallet/widgets/text_widget.dart';

class CredentialPresentationPage extends StatefulWidget {
  final String requestData;

  const CredentialPresentationPage({super.key, required this.requestData});

  @override
  State<CredentialPresentationPage> createState() =>
      _CredentialPresentationPageState();
}

class _CredentialPresentationPageState extends State<CredentialPresentationPage> {
  bool isLoading = false;
  late Map<String, dynamic> requestData;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  VerifiedCredential? verifiedCredential;
  bool isVerified = false;
  Map<String, dynamic> otherInfo = {};

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // get request data
    Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(hex.decode(widget.requestData)));

    print('param: ${jsonObject}');
    setState(() {
      requestData = jsonObject;
    });

    // get result
    _getRequest();
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
        child: SingleChildScrollView(
          child: _renderDetail(),
        ),
      ),
    );
  }

  Widget _renderDetail() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              _getVerifiedStatusWidget(),

              TextWidget('ID', verifiedCredential?.credentialId ?? '-', 1),
              TextWidget('User DID', verifiedCredential?.userDid ?? '-' , 2),
              TextWidget('Issuer Address', verifiedCredential?.issuer ?? '-', 1),
              // TextWidget('Issuer DID', verifiedCredential., 2),
              // TextWidget('Issue Date', date, 1),
              TextWidget('Signature', verifiedCredential?.signature ?? '-', 2),
              const SizedBox(height: 20.0),
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
              TextWidget('Full Name', otherInfo['fullName'] ?? '-', 1),
            ],
          ),
        ));
  }

  Widget _getVerifiedStatusWidget() {

    return Container(
      padding: const EdgeInsets.all(2), // Add 10px padding
      child: isVerified
                  ? const Text(
                      'VALID',
                      style: TextStyle(
                        color: Color.fromARGB(255, 70, 117, 72),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : const Text('INVALID', style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      ),
    );
  }

  Future<void> _getRequest() async {
    setState(() {
      isLoading = true;
    });
    try {
      // get request from smart contract
      PresentRequestService presentRequestService = await PresentRequestService.web3().loadContract();
      PresentCredential request = await presentRequestService.getPresentRequest(requestData['requestId'], requestData['verifierAddress']);

      print('Request - ${request.toString()}');
      if (request.credentialId.isEmpty && request.userDid.isEmpty) {
        print('no record found!');
        await _showAlert('No verifiable presentation record found!');
        _close();
      } else {
        print('get credential record...');

        IssuedCredentialService issuedCredentialService = await IssuedCredentialService.web3().loadContract();
        VerifiedCredential _verifiedCredential  = await issuedCredentialService.getVerifiedCredential(
                                                              request.credentialId, request.userDid);
        bool status =  await issuedCredentialService.verifyCredential(request.credentialId, request.userDid);

        print('verified credential: ${_verifiedCredential.toString()}');

        setState(() {
          verifiedCredential = _verifiedCredential;
          isVerified = status;
        });
      }

      // other info
      if (request.otherInfo.isNotEmpty) {
        setState(() {
          otherInfo = jsonDecode(utf8.decode(hex.decode(request.otherInfo)));
        });
      }

    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }


  Future<void> _showAlert(String message) async {

    print('status submit: $message');
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Notification'),
            content: Text(message),
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
