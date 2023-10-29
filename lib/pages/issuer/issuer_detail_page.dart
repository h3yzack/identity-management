import 'dart:convert';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:myid_wallet/provider/issued_credential_provider.dart';
import 'package:myid_wallet/services/issued_credential_service.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/common_util.dart';
import 'package:myid_wallet/widgets/image_widget.dart';
import 'package:myid_wallet/widgets/text_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class IssuerDetailPage extends ConsumerStatefulWidget {
  final String? id;
  final Web3App web3App;

  const IssuerDetailPage({super.key, required this.web3App, this.id});

  @override
  ConsumerState<IssuerDetailPage> createState() => _IssuerDetailPageState();
}

class _IssuerDetailPageState extends ConsumerState<IssuerDetailPage> {
  String _id = '';
  IssuedCredential? credential;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _id = widget.id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Credential'),
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

    getRecord();
    var data = credential?.base64Data ?? '';
    var date = CommonUtil.formatDate((credential?.issueDate));
    bool isVerified = credential?.issued ?? false;
    // bool isVerified = false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (data.isNotEmpty) ImageWidget(data),
          TextWidget('ID', credential?.credentialId ?? '', 1),
          TextWidget('User DID', credential?.userDid ?? '', 2),
          TextWidget('Issuer Address', credential?.createdBy ?? '', 1),
          TextWidget('Issuer DID', credential?.issuerDid ?? '', 2),
          TextWidget('Issue Date', date, 1),
          if (isVerified) TextWidget('Signature', credential?.signature ?? 'N/A', 2),
          _getVerifiedStatusWidget(isVerified),
          const SizedBox(height: 20.0),
          _getButtonsWidget(),
        ],
      ),
    );
  }

  Widget _getVerifiedStatusWidget(bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0), // Add top padding
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text('Status'),
          ),
          Expanded(
              child: isVerified
                  ? const Text(
                      'Verified',
                      style: TextStyle(
                        color: Color.fromARGB(255, 70, 117, 72),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : const Text('Unverified', style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),)),
        ],
      ),
    );
  }

  Widget _getButtonsWidget() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async {
              await _verify();
            },
            child: const Text(
              'Sign & Issue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10), // Add some spacing between the buttons
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              await _validate();
            },
            child: const Text(
              'Validate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _verify() async {
    setState(() {
      isLoading = true;
    });
    final icService = await IssuedCredentialService.web3().loadContract();

    await icService.processIssuing(widget.web3App, credential!);
    await getRecord();

    setState(() {
      isLoading = false;
    });
  }

  _validate() async {
    setState(() {
      isLoading = true;
    });

    final icService = await IssuedCredentialService.web3().loadContract();
    bool status =
        await icService.validateCredential(widget.web3App, credential!);

    print('status validate: $status');

    await _showValidateStatus(status);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getRecord() async {
    if (_id.isNotEmpty) {
      final icService = IssuedCredentialService();
      var record = icService.getByKey(_id);
      if (record != null) {
        print('Credential ID: ${record?.credentialId}');
        setState(() {
          credential = record;
        });
      }
    }
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
      final icBox = await Hive.openBox<IssuedCredential>('IssuedCredential');
      icBox.delete(_id);
      _displayDeletedRecord();
      _close();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _showValidateStatus(bool status) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Status'),
            content: Text('Signature validation : $status'),
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

  void _displayDeletedRecord() {
    showPlatformToast(
      child: const Text(
        StringConstants.recordDeleted,
      ),
      context: context,
    );
  }

  void _close() {
    // ref.read(didDocumentProvider.notifier).cancelTask();
    ref.read(issuedCredentialProvider.notifier).loadRecords();
    Navigator.pop(context, true);
  }
}
