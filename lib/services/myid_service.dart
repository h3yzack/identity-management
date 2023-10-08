
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:web3dart/web3dart.dart';

enum MYID_UTIL_METHOD {
  generateTokenId
}

class MyIdService {
  final String contractName = 'MyIdUtil';
  final Web3Client web3client;

  late final DeployedContract _deployedContract;
  late final EthereumAddress _contractAddress;
  late final String _abiCode;

  MyIdService(this.web3client);

  Future<MyIdService> loadContract() async {
    String abiFile = await rootBundle.loadString('assets/contracts/$contractName.json');

    final abiJSON = jsonDecode(abiFile); 
    _abiCode = jsonEncode(abiJSON['abi']);

    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);

    _deployedContract = DeployedContract(ContractAbi.fromJson(_abiCode, contractName), _contractAddress);

    return this;
  }

  Future<String> generateTokenId(String userAddress) async {
    debugPrint('to generateTokenId $userAddress - ${MYID_UTIL_METHOD.generateTokenId.name}');

    String formattedTimestamp = DateTime.now().toLocal().toString();

    final result = await web3client
        .call(contract: _deployedContract, function: _deployedContract.function(MYID_UTIL_METHOD.generateTokenId.name), 
                      params: [EthereumAddress.fromHex(userAddress), formattedTimestamp]);

    print('RESULT: $result');

    return result.first.toString();
  }
}