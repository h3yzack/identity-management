
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:myid_wallet/model/chain_metadata.dart';
import 'package:myid_wallet/model/did_document.dart';
import 'package:myid_wallet/model/ethereum_transaction.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/crypto/eip155.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

final didServiceProvider = ChangeNotifierProvider((ref) => DidService());

enum SC_METHOD {
  addDIDDocument,
  getDIDDocuments
}

class DidService extends ChangeNotifier {
  final String contractName = 'DIDRegistry';

  Status addRecordStatus = Status.init;

  late final Web3Client _web3client;
  late final DeployedContract _deployedContract;
  late final EthereumAddress _contractAddress;
  late final String _abiCode;
  SessionProvider sessionStorage = SessionProvider();


  DidService();

  Future<void> init() async {
    await _initWeb3();
  }

  Future<void> _initWeb3() async {
    _web3client = Web3Client(MyIdConstant.RPC_URL, Client());

    
    await _getAbiAndContract();
    // await _getDeployedContract();

    notifyListeners();
  }

  Future<void> _getAbiAndContract() async {
    String abiFile = await rootBundle.loadString('assets/contracts/$contractName.json');

    final abiJSON = jsonDecode(abiFile);
    _abiCode = jsonEncode(abiJSON['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);

    _deployedContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, contractName), _contractAddress);
    
  }


  getDIDsByUser(String address) async {
    // notifyListeners();
    debugPrint('to getDIDsByUser $address');

    final result = await _web3client
        .call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getDIDDocuments.name), 
        params: [EthereumAddress.fromHex(address)]);

    List<dynamic> records = result[0];
    // debugPrint(records[0]);

    List<DidDocument> didDocuments = records.map((item) => DidDocument.fromJson(json.decode(item))).toList();

    // // Now, you have a list of DidDocument objects
    // for (var document in didDocuments) {
    //   print("DID: ${document.did}");
    //   print("DID Type: ${document.didType}");
    //   print("Title: ${document.title}");
    //   print("Description: ${document.description}");
    //   print("Signature: ${document.signature}");
    //   print("User: ${document.user}\n");
    // }

    addRecordStatus = Status.done;
    notifyListeners();

    return didDocuments;
    
  }

  addDidDocument(DidDocument didDocument) async {
    debugPrint('to add new did -  addDid');

    Credentials credentials = EthPrivateKey.fromHex('0x84dbc48cb51f683855b9f587a37ddf52776f9b0101d524eafc913ab76379d52e');

    print('own address: ${credentials.address}');
    String address = await sessionStorage.getAddress() ?? '';
    var topic = await sessionStorage.getTopic() ?? '';
    ChainMetadata chain = MyIdConstant.testChain;

    Transaction transaction = Transaction.callContract(
        contract: _deployedContract,
        function: _deployedContract.function(SC_METHOD.addDIDDocument.name),
        parameters: [
          didDocument.did,
          didDocument.didType,
          didDocument.title,
          EthereumAddress.fromHex(didDocument.user),
          didDocument.signature
        ],
      );

    final response = await _web3client.sendTransaction(credentials, transaction, chainId: 1337);

    while (true) {
      final receipt = await _web3client.getTransactionReceipt(response);
      if (receipt != null) {
        print('Transaction successful');
        print(receipt);
        break;
      }
      // Wait for a while before polling again
      await Future.delayed(const Duration(seconds: 2));
    }

    return response;
  }

  addDid(DidDocument didDocument, Web3App web3App) async {

    debugPrint('to add new did -  addDid');
    addRecordStatus = Status.loading;
    notifyListeners();

    String address = await sessionStorage.getAddress() ?? '';
    var topic = await sessionStorage.getTopic() ?? '';
    ChainMetadata chain = MyIdConstant.testChain;

    Transaction transaction = Transaction.callContract(
        contract: _deployedContract,
        function: _deployedContract.function(SC_METHOD.addDIDDocument.name),
        parameters: [
          didDocument.did,
          didDocument.didType,
          didDocument.title,
          EthereumAddress.fromHex(didDocument.user),
          didDocument.signature
        ],
      );

      print('submit to contract address ${_contractAddress.toString()}');

    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: didDocument.user,
        to: _contractAddress.hex,
        value: "0x0",
        data: hex.encode(List<int>.from(transaction.data!)), /// ENCODE TRANSACTION USING convert LIB
      );

    final transactionId = await EIP155.ethSendTransaction(
                            web3App: web3App, 
                            topic: topic, chainId: chain.chainId,  
                            transaction: ethereumTransaction
    );
    
    print('transaction completed $transactionId');

    debugPrint('addDid completed');
    // return transactionId;
    addRecordStatus = Status.done;
    notifyListeners();
  }
}