
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/model/did_document.dart';
import 'package:myvc_wallet/model/issued_credential.dart';
import 'package:myvc_wallet/provider/did_provider.dart';
import 'package:myvc_wallet/provider/issued_credential_provider.dart';
import 'package:myvc_wallet/services/issued_credential_service.dart';
import 'package:myvc_wallet/utils/common_util.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:myvc_wallet/utils/session_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class IssuerFormPage extends ConsumerStatefulWidget {
  final String? id;
  final Web3App web3App;

  const IssuerFormPage({super.key, required this.web3App, this.id});

  @override
  ConsumerState<IssuerFormPage> createState() => _IssuerFormPageState();
}

class _IssuerFormPageState extends ConsumerState<IssuerFormPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? _file;
  String? _fileBase64;
  DateTime? _selectedDate;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Issue New Credential'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
          child: _buildForm(ref),
        ));
  }

  Widget _buildForm(WidgetRef ref) {
    List<DidDocument> didDocuments = ref.watch(didDocumentProvider).didDocuments ?? [];

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
                    print(value[0]);
                    String base64String = CommonUtil.convertPlatformFileToBase64(value[0]);
                    setState(() {
                      // Convert the selected file to a Base64 string
                      _fileBase64 = base64String;
                    });
                  }
                },
              ),
              // if (_fileBase64 != null) ...[
              //   Text('Base64 String: $_fileBase64'),
              // ],
              FormBuilderTextField(
                name: 'userDid',
                decoration: InputDecoration(
                  labelText: 'User DID',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      // Implement QR code scanning logic here
                    },
                  ),
                  errorText:
                      _formKey.currentState?.fields['userDid']?.errorText,
                ),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderDropdown(
                name: 'issuerDid',
                decoration: const InputDecoration(labelText: 'Issuer DID'),
                validator: FormBuilderValidators.required(),
                items: didDocuments
                    .map((issuer) => DropdownMenuItem(
                          value: issuer.did,
                          child: Text(issuer.title),
                        ))
                    .toList(),
              ),
              // FormBuilderDropdown(
              //   name: 'docType',
              //   decoration: const InputDecoration(labelText: 'Document Type'),
              //   items: ['Digital Identity']
              //       .map((type) => DropdownMenuItem(
              //             value: type,
              //             child: Text(type),
              //           ))
              //       .toList(),
              // ),
              // FormBuilderDateTimePicker(
              //   name: 'selectedDate',
              //   inputType: InputType.date,
              //   decoration: const InputDecoration(labelText: 'Issue Date'),
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedDate = value;
              //     });
              //   },
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final formData = _formKey.currentState!.value;
                    // Handle form data submission here
                    print(formData);
                    String? id = await issueCredential(formData);
                    if (id != null) {
                      _goToDetailPage(id.toString());
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> issueCredential(Map<String, dynamic> formData) async {
    setState(() {
      isLoading = true;
    });
    try {
      String base64String =
          CommonUtil.convertPlatformFileToBase64(formData['file'][0]);
      SessionInfo sessionInfo = await SessionProvider.getSessionInfo();

      // final icBox = await Hive.openBox<IssuedCredential>('IssuedCredential');

      var uuid = const Uuid();
      String uniqueId = uuid.v4();

      final issuedCredential = IssuedCredential(
        credentialId: uniqueId,
        base64Data: base64String,
        // issueDate: formData['selectedDate'],
        issueDate: DateTime.now(),
        issuerDid: formData['issuerDid'],
        userDid: formData['userDid'],
        createdBy: sessionInfo.address,
        issuerAddress: sessionInfo.address,
      );

      // icBox.put(uniqueId, issuedCredential);
      final icService = IssuedCredentialService();
      await icService.save(uniqueId, issuedCredential);

      print('record saved - credentialId: $uniqueId');
      ref.read(issuedCredentialProvider.notifier).loadRecords();

      print(base64String);

      setState(() {
        isLoading = false;
      });

      // Navigator.pop(context, true);
      return uniqueId;
    } catch (e) {
      print('ERRROR: $e');
      setState(() {
        isLoading = false;
      });
    }

    return null;
  }

  void _close() {
    Navigator.pop(context, true);
  }

  void _goToDetailPage(String id) {
    Navigator.popAndPushNamed(context, MyIdRoutes.issuerCredentialDetail, arguments: {'id': id});
  }
}
