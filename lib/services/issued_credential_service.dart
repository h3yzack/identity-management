
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:myid_wallet/model/chain_metadata.dart';
import 'package:myid_wallet/model/ethereum_transaction.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:myid_wallet/model/verified_credential.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/crypto/eip155.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

enum SC_METHOD {
  issue,
  getCredential,
  verify,
  revoke,
  getMessageHash,
  getMessageHashHex
}
class IssuedCredentialService {

  final String contractName = 'VerifiableCredential';

  Web3Client? web3client;

  late final String _abiCode;
  late final EthereumAddress _contractAddress;
  late final DeployedContract _deployedContract;
  
  IssuedCredentialService();

  IssuedCredentialService.web3() {
    web3client = Web3Client(MyIdConstant.RPC_URL, Client());
  }
  
 
  Future<IssuedCredentialService> loadContract() async {
    String abiFile = await rootBundle.loadString('assets/contracts/$contractName.json');

    final abiJSON = jsonDecode(abiFile); 
    _abiCode = jsonEncode(abiJSON['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);

    _deployedContract = DeployedContract(ContractAbi.fromJson(_abiCode, contractName), _contractAddress);
    
    return this;
  }

  List<IssuedCredential> getIssuedCredentials(String issuerAddress) {
    final icBox = Hive.box<IssuedCredential>('IssuedCredential');
    final records = icBox.values.where((record) => record.issuerAddress == issuerAddress).toList();
    // tasks.sort((a, b) => a.priority.compareTo(b.priority));
    return records;
  }

  List<IssuedCredential> getByCreatedBy(String createdBy) {
    final icBox = Hive.box<IssuedCredential>('IssuedCredential');
    final records = icBox.values.where((record) => record.createdBy == createdBy).toList();
    // tasks.sort((a, b) => a.priority.compareTo(b.priority));
    return records;
  }

  // local storage
  IssuedCredential? getByKey(String key) {
    final icBox = Hive.box<IssuedCredential>('IssuedCredential');
    final record = icBox.get(key);

    return record;
  }

  // local storage
  save(String key, IssuedCredential issuedCredential) async {
    final icBox = await Hive.openBox<IssuedCredential>('IssuedCredential');

    icBox.put(key, issuedCredential);
  }

  Future<bool> processIssuing(Web3App web3App, IssuedCredential issuedCredential) async {
    // get hash

    try {
        SessionInfo sessionInfo = await SessionProvider.getSessionInfo();

        // get hash of base64data
        String messageHash = await _getMessageHash(issuedCredential);
        // List<int> hashBytes = await _getHash(issuedCredential);

        // String strHash = hex.encode(hashBytes);

        print('data hash retrieved $messageHash ');

        // to sign dataHash
        ChainMetadata chain = MyIdConstant.testChain;
        final signature = await EIP155.personalSign(
                            web3App: web3App, 
                            topic: sessionInfo.topic, chainId: chain.chainId, address: sessionInfo.address, data: messageHash);

      print('Signature: $signature');

      issuedCredential.signature = signature;
      issuedCredential.hashData = messageHash;
      issuedCredential.save();

      // to send to blockchain
      await _saveSignedCredential(web3App, issuedCredential, sessionInfo);
      issuedCredential.issued = true;
      issuedCredential.save();

    } catch (e) {
        print(e.toString());
        return false;
    }

    return true;
  }

  Future<bool> validateCredential(Web3App web3App, IssuedCredential issuedCredential) async {

    try {
      // get from blockchain
      VerifiedCredential verifiedCredential = await _getVerifiedCredential(issuedCredential.credentialId!, issuedCredential.userDid!);

      var statusVerify = await _verifySignature(issuedCredential.credentialId!, issuedCredential.userDid!);

      print('status of signature verification: $statusVerify');

    } catch (e) {
        print(e.toString());
        return false;
    }

    return true;
  }

  Future<bool> verifyCredential(String credentialId, String userDid) async {

    try {
      // get from blockchain
      // VerifiedCredential verifiedCredential = await _getVerifiedCredential(credentialId, userDid);

      var statusVerify = await _verifySignature(credentialId, userDid);

      print('status of signature verification: $statusVerify');

    } catch (e) {
        print(e.toString());
        return false;
    }

    return true;
  }

  _saveSignedCredential(Web3App web3App, IssuedCredential issuedCredential, SessionInfo sessionInfo) async {
    debugPrint('to add new signed credential -  _saveSignedCredential');

    // String dataHash = await _getMessageHash(issuedCredential);

    print('data Hash: ${issuedCredential.hashData}');

    String hexSignature = issuedCredential.signature!;

    if (hexSignature.startsWith("0x")) {
      hexSignature = hexSignature.substring(2);
    }

    ChainMetadata chain = MyIdConstant.testChain;

    Transaction transaction = Transaction.callContract(
        contract: _deployedContract,
        function: _deployedContract.function(SC_METHOD.issue.name),
        parameters: [
          issuedCredential.userDid,
          issuedCredential.credentialId,
          issuedCredential.hashData,
          hex.decode(hexSignature)
        ],
      );


    EthereumTransaction ethereumTransaction = EthereumTransaction(
        from: sessionInfo.address,
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

    debugPrint('_saveSignedCredential completed');
  }

  Future<String> _getMessageHash(IssuedCredential issuedCredential) async {

    print('userDID: ${issuedCredential.userDid!} - credentialId: ${issuedCredential.credentialId!}');
    final result = await web3client!.call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getMessageHashHex.name), 
                                          params: [issuedCredential.userDid, issuedCredential.credentialId]);

    return result.first.toString();
  }

  Future<List<int>> _getHash(IssuedCredential issuedCredential) async {

    print('userDID: ${issuedCredential.userDid!} - credentialId: ${issuedCredential.credentialId!}');
    final result = await web3client!.call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getMessageHash.name), 
                                          params: [issuedCredential.userDid, issuedCredential.credentialId]);
    
    print(result.first.toString());
    return result.first;
  }

  Future<VerifiedCredential> _getVerifiedCredential(String credentialId, String userDid) async {
    final result = await web3client!.call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getCredential.name), 
                                          params: [userDid, credentialId]);

    print(result.first.toString());

    return VerifiedCredential.fromJson(json.decode(result.first.toString()));

  }

  Future<String> _verifySignature(String credentialId, String userDid) async {
    final result = await web3client!.call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.verify.name), 
                                          params: [userDid, credentialId]);

    return result.first.toString();
  }

}