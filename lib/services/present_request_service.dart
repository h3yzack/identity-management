
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:myvc_wallet/model/chain_metadata.dart';
import 'package:myvc_wallet/model/ethereum_transaction.dart';
import 'package:myvc_wallet/model/present_credential.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:myvc_wallet/utils/crypto/eip155.dart';
import 'package:myvc_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import 'package:web3dart/web3dart.dart';

enum SC_METHOD {
  save,
  getRequest
}

class PresentRequestService {
  final String contractName = 'PresentRequest';

  Web3Client? web3client;

  late final String _abiCode;
  late final EthereumAddress _contractAddress;
  late final DeployedContract _deployedContract;
  
  PresentRequestService();

  PresentRequestService.web3() {
    web3client = Web3Client(MyIdConstant.RPC_URL, Client());
  }

  Future<PresentRequestService> loadContract() async {
    String abiFile = await rootBundle.loadString('assets/contracts/$contractName.json');

    final abiJSON = jsonDecode(abiFile); 
    _abiCode = jsonEncode(abiJSON['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);

    _deployedContract = DeployedContract(ContractAbi.fromJson(_abiCode, contractName), _contractAddress);
    
    return this;
  }

  Future<bool> saveRequest(Web3App web3App, PresentCredential request) async {
    try {
      SessionInfo sessionInfo = await SessionProvider.getSessionInfo();
      print('topic: ${sessionInfo.topic}');
      await _saveRequest(web3App, request, sessionInfo);

    } catch (e) {
      print(e.toString());
      return false;
    }

    return true;
  }

  Future<PresentCredential> getPresentRequest(String requestId, String verifierAddress) async {
    final result = await web3client!.call(contract: _deployedContract, function: _deployedContract.function(SC_METHOD.getRequest.name), 
                                          params: [requestId, verifierAddress]);

    // print(result.first.toString());

    return PresentCredential.fromJson(json.decode(result.first.toString()));

  }

  _saveRequest(Web3App web3App, PresentCredential request, SessionInfo sessionInfo) async {
    debugPrint('to add new present request -  _saveRequest');

    ChainMetadata chain = MyIdConstant.testChain;

    Transaction transaction = Transaction.callContract(
        contract: _deployedContract,
        function: _deployedContract.function(SC_METHOD.save.name),
        parameters: [
          request.credentialId,
          request.verifierAddress,
          request.requestId,
          request.userDid,
          request.otherInfo
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

    debugPrint('_saveRequest completed');
  }
}