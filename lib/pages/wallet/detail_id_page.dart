
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';
import 'package:myvc_wallet/services/issued_credential_service.dart';
import 'package:myvc_wallet/services/wallet_service.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:myvc_wallet/utils/common_util.dart';
import 'package:myvc_wallet/widgets/image_widget.dart';
import 'package:myvc_wallet/widgets/text_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletDetailPage extends ConsumerStatefulWidget {
  final String id;
  final Web3App web3App;

  const WalletDetailPage({super.key, required this.web3App, required this.id});

  @override
  ConsumerState<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends ConsumerState<WalletDetailPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  late String _id;
  late WalletCredential walletRecord;
  bool isLoading = false;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _id = widget.id;
    });

    _getRecord();
  }

  void _getRecord() async {
    setState(() {
      isLoading = true;
    });
    final walletService = WalletService();
    final tempRecord = walletService.getByKey(widget.id);

    if (tempRecord != null) {
      setState(() {
        walletRecord = tempRecord;
      });
    }

    await _validate();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Verified Credential'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                deleteRecord();
                // reload();
              },
            ),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: SingleChildScrollView(
            child: _renderDetail(ref),
          ),
        ));
  }

  Widget _renderDetail(WidgetRef ref) {
    // get record by id

    var data = walletRecord.base64Data;
    var date = CommonUtil.formatDate(walletRecord.issueDate);
    
    // bool isVerified = false;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (data.isNotEmpty) ImageWidget(data),
            _getVerifiedStatusWidget(),
            FormBuilderTextField(
                name: 'name',
                initialValue: walletRecord.name,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Please enter name',
                  floatingLabelStyle: const TextStyle(
                                    // height: 4,
                                    color: Color.fromARGB(255, 160, 26, 179)),
                  errorText: _formKey.currentState?.fields['name']?.errorText,
                ),
                validator: FormBuilderValidators.required(),
              ),
            TextWidget('ID', walletRecord.credentialId, 1),
            TextWidget('User DID', walletRecord.userDid , 2),
            TextWidget('Issuer Address', walletRecord.issuerAddress, 1),
            TextWidget('Issuer DID', walletRecord.issuerDid, 2),
            TextWidget('Issue Date', date, 1),
            TextWidget('Signature', walletRecord.signature, 2),
            const SizedBox(height: 20.0),
            ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final formData = _formKey.currentState!.value;
                      // Handle form data submission here
                      print(formData);
                
                      _saveLocal(formData);
                      // _close();
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
        ),
      )
    );
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

  _validate() async {
    // setState(() {
    //   isLoading = true;
    // });

    final icService = await IssuedCredentialService.web3().loadContract();
    bool status =  await icService.verifyCredential(walletRecord.credentialId, walletRecord.userDid);

    // await _showValidateStatus(status);

    setState(() {
      isVerified = status;
      // isLoading = false;
    });
  }

  _saveLocal(Map<String, dynamic> formData) async {
    print('to save into my wallet...');
    setState(() {
      isLoading = true;
    });

    try {
   
      print('Saving to local storage --> c: ${walletRecord.credentialId}');

      walletRecord.name = formData['name'];
      walletRecord.save();

      // redirect to list
      _displayStatus(StringConstants.recordSaved);

    } catch (e) {
        debugPrint(e.toString());
    }


    setState(() {
      isLoading = false;
    });
  }

  void _displayStatus(String statusText) {
    showPlatformToast(
      child: Text(
        statusText,
      ),
      context: context,
    );
  }

  // to detele record
  deleteRecord() async {
    print('to delete record: $_id');

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Proceed to delete record?'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('No'),
                onPressed: () {
                  print('cancel delete!');
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Yes'),
                onPressed: () {
                  print('proceed delete!');
                  Navigator.pop(context);
                  proceedDelete();
                },
              ),
            ],
          );
        });
  }

  proceedDelete() async {
    try {
      final walletService = WalletService();
      walletService.delete(_id);
      _displayStatus(StringConstants.recordDeleted);
      _close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _close() {
    // ref.read(didDocumentProvider.notifier).cancelTask();
    // ref.read(issuedCredentialProvider.notifier).loadRecords();
    Navigator.pop(context, true);
  }
}