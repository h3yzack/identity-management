
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:web3dart/web3dart.dart';

enum MYID_UTIL_METHOD {
  generateTokenId
}

class MyIdService {
  final String contractName = 'MyIdUtil';
  late final Web3Client _web3client;
  late final DeployedContract _deployedContract;
  late final EthereumAddress _contractAddress;
  late final String _abiCode;

  MyIdService();

  Future<void> init() async {
    await _initWeb3();
  }

  Future<void> _initWeb3() async {
    // Web3Client initilized
    _web3client = Web3Client(MyIdConstant.RPC_URL, Client());

    
    await _getAbi();
    await _getDeployedContract();
  }

  Future<void> _getAbi() async {
    String abiFile = await rootBundle.loadString('assets/contracts/MyIdUtil.json');

    final abiJSON = jsonDecode(abiFile);
    _abiCode = jsonEncode(abiJSON['abi']);

    // get contact address from abiJSON
    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);
    
  }

  Future<void> _getDeployedContract() async {

    _deployedContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, contractName), _contractAddress);

  }

  // mintNFT(String userAddress) async {
  //   debugPrint('to getDIDsByUser $userAddress');

  //   await _web3client
  //       .call(contract: _deployedContract, function: _deployedContract.function(NFT_METHOD_NAME.mintNFT.name), 
  //                     params: [EthereumAddress.fromHex(userAddress)]);

  //   debugPrint('Done mint');
    
  // }

  generateTokenId(String userAddress) async {
    debugPrint('to generateTokenId $userAddress - ${MYID_UTIL_METHOD.generateTokenId.name}');

    String formattedTimestamp = DateTime.now().toLocal().toString();

    final result = await _web3client
        .call(contract: _deployedContract, function: _deployedContract.function(MYID_UTIL_METHOD.generateTokenId.name), 
                      params: [EthereumAddress.fromHex(userAddress), formattedTimestamp]);

    print('RESULT: $result');

    return result.first.toString();
  }
}