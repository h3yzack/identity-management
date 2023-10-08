
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/provider/did_provider.dart';
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

  @override
  void initState() {
    super.initState();
    
    setState(() {
      _id =  widget.id ?? '';
    });
   
  }


  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(didDocumentProvider);
    // bool isLoading = ref.watch(didDocumentProvider).isLoading;
    bool isSaving = ref.watch(didDocumentProvider).isSaving;


    return Scaffold(
      appBar: AppBar(
        title: Text(_id == '' ? 'Create New Profile' : 'Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
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
                      decoration: const InputDecoration(labelText: 'Description'),
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
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    
                    const SizedBox(height: 20.0),
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
                        const SizedBox(width: 10.0),
                        ElevatedButton(
                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              saveRecord();
                              // submitForm();
                            
                            }
                          },
                          child: isSaving ? 
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

  saveRecord() async {
    final status = await ref.read(didDocumentProvider.notifier).saveDidDocument(widget.web3App, _name, _type);

    print('status: $status');

    Navigator.pop(context, true);
  }

  // submitForm() async {
  //   loading = true;
  //   String address = await sessionStorage.getAddress() ?? '';
  //   var topic = await sessionStorage.getTopic() ?? '';
  //   ChainMetadata chain = MyIdConstant.testChain;
  //   // get tokenId
  //   String tokenId = await myIdService.generateTokenId(address);

  //   String did = 'did:$_type:$tokenId';

  //   print(did);

  //   // sign did
  //   final signature = await EIP155.personalSign(
  //                         web3App: widget.web3App, 
  //                         topic: topic, chainId: chain.chainId, address: address, data: did);

  //   print('Signature: $signature');

  //   DidDocument didDocument = DidDocument(did: did, didType: _type, title: _name, 
  //                               user: address, signature: signature);

    
  //   print('didDocument: $didDocument');
  //   await didService.init();

  //   final result = await didService.addDid(didDocument, widget.web3App);

  //   // final result = await didService.addDidDocument(didDocument);
  //   print('done adding new did $result');
  //   loading = false;
  //   Navigator.pop(context, true);
  // }

  
}