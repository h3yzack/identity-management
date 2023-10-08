
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:myid_wallet/model/chain_metadata.dart';
import 'package:myid_wallet/model/did_document.dart';
import 'package:myid_wallet/model/ethereum_transaction.dart';
import 'package:myid_wallet/services/myid_service.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/crypto/eip155.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

enum SC_METHOD {
  addDIDDocument,
  getDIDDocuments
}

class DidDocumentService {
  final String contractName = 'DIDRegistry';

  final Web3Client web3client;

  late final String _abiCode;
  late final EthereumAddress _contractAddress;
  late final DeployedContract _deployedContract;
  SessionProvider sessionStorage = SessionProvider();

  DidDocumentService(this.web3client);

  Future<DidDocumentService> loadContract() async {
    String abiFile = await rootBundle.loadString('assets/contracts/$contractName.json');

    final abiJSON = jsonDecode(abiFile); 
    _abiCode = jsonEncode(abiJSON['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);

    _deployedContract = DeployedContract(ContractAbi.fromJson(_abiCode, contractName), _contractAddress);

    return this;
  }

  Future<List<DidDocument>> getDidDocumentByUser(String address) async {
    debugPrint('to getDIDsByUser $address');

    final result = await web3client
        .call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getDIDDocuments.name), 
        params: [EthereumAddress.fromHex(address)]);

    List<dynamic> records = result[0];
    List<DidDocument> didDocuments = records.map((item) => DidDocument.fromJson(json.decode(item))).toList();

    return didDocuments;
  }

  Future<bool> saveDidDocument(Web3App web3App, String name, String type) async {
    
    SessionInfo sessionInfo = await sessionStorage.getSessionInfo();

    // get tokenId
    final myIdService = await MyIdService(web3client).loadContract();

    String tokenId = await myIdService.generateTokenId(sessionInfo.address);

    String did = 'did:$type:$tokenId';
    print('DID: $did');

    try {
      // sign did
      ChainMetadata chain = MyIdConstant.testChain;
      final signature = await EIP155.personalSign(
                            web3App: web3App, 
                            topic: sessionInfo.topic, chainId: chain.chainId, address: sessionInfo.address, data: did);

      print('Signature: $signature');

      DidDocument didDocument = DidDocument(did: did, didType: type, title: name, 
                                  user: sessionInfo.address, signature: signature);

      _addDid(web3App, didDocument, sessionInfo);
      
    } catch (e) {
      return false;
    }
    

    return true;
  }

  _addDid(Web3App web3App, DidDocument didDocument, SessionInfo sessionInfo) async {

    debugPrint('to add new did -  addDid');

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
                            topic: sessionInfo.topic, chainId: chain.chainId,  
                            transaction: ethereumTransaction
    );
    
    print('transaction completed $transactionId');

    debugPrint('addDid completed');
    
  }

}