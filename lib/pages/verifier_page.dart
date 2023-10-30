import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:myvc_wallet/utils/session_provider.dart';

class VerifierPage extends StatefulWidget {
  const VerifierPage({super.key});
  
  @override
  State<VerifierPage> createState() => _VerifierPageState();
}

class _VerifierPageState extends State<VerifierPage> {

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
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
        ));
  }
  
  _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'title',
                  // readOnly: true,
                  initialValue: 'Show me your proof',
                  decoration: InputDecoration(
                    labelText: 'Title',
                    errorText:
                        _formKey.currentState?.fields['title']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                FormBuilderTextField(
                  name: 'requestId',
                  initialValue: '123',
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
                  initialValue: '0xeA74Cd133001253377b48DdD9eB9641e6Bb024cA',
                  // readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Verifier Address',
                    errorText:
                        _formKey.currentState?.fields['verifierAddress']?.errorText,
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final formData = _formKey.currentState!.value;
                      // Handle form data submission here
                      _submitRequest(formData);
                      // _close();
                    }
                  },
                  child: const Text(
                    'Submit Request',
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

  _submitRequest(Map<String, dynamic> formData) {

    // generate requestData in hex
    print(formData.toString());
    String hexRequest = hex.encode(utf8.encode(jsonEncode(formData)));

    Navigator.pushNamed(context, MyIdRoutes.verifierViewRequest, arguments: {'requestData': hexRequest} );

  }

}