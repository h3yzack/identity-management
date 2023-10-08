
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/model/chain_metadata.dart';
import 'package:myid_wallet/model/did_document.dart';
import 'package:myid_wallet/services/did_service.dart';
import 'package:myid_wallet/services/myid_service.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/crypto/eip155.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class ProfileFormPage extends ConsumerStatefulWidget {
  final String? id;
  final Web3App web3App;

  const ProfileFormPage({super.key, required this.web3App, this.id});
  
  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> {

  String _id = '';
  SessionProvider sessionStorage = SessionProvider();
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _type = 'myid'; // Default value

  MyIdService myIdService = MyIdService();
  DidService didService = DidService();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    
    setState(() {
      _id =  widget.id ?? '';
    });
    
    _initialize();
    // 
  }

  void _initialize() async {
    await myIdService.init();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(didServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_id == '' ? 'Create New Profile' : 'Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == '') {
                    return 'Please enter profile name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                // minLines: 2,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              DropdownButtonFormField(
                value: _type,
                items: ['myid', 'issuer']
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value.toString();
                  });
                },
                decoration: InputDecoration(labelText: 'Type'),
              ),
              
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 10.0),
                  ElevatedButton(
                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Perform form submission, e.g., sending data to an API or processing it
                        // Here, we'll just print the collected data
                        print('Name: $_name');
                        print('Description: $_description');
                        print('Gender: $_type');
                        submitForm();
                      }
                    },
                    child: state.addRecordStatus == Status.loading ? 
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ) :
                        const Text('Save', style: TextStyle(color: Colors.white, fontSize: 13,)),
                  ),
                ],
              )
              
            ],
          ),
        ),
      ),
    );
  }


  submitForm() async {
    loading = true;
    String address = await sessionStorage.getAddress() ?? '';
    var topic = await sessionStorage.getTopic() ?? '';
    ChainMetadata chain = MyIdConstant.testChain;
    // get tokenId
    String tokenId = await myIdService.generateTokenId(address);

    String did = 'did:$_type:$tokenId';

    print(did);

    // sign did
    final signature = await EIP155.personalSign(
                          web3App: widget.web3App, 
                          topic: topic, chainId: chain.chainId, address: address, data: did);

    print('Signature: $signature');

    DidDocument didDocument = DidDocument(did: did, didType: _type, title: _name, 
                                user: address, signature: signature);

    
    print('didDocument: $didDocument');
    await didService.init();

    final result = await didService.addDid(didDocument, widget.web3App);

    // final result = await didService.addDidDocument(didDocument);
    print('done adding new did $result');
    loading = false;
    Navigator.pop(context);
  }

  
}