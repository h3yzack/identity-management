

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:web3dart/web3dart.dart';

// final _contractProvider = ChangeNotifierProvider((ref) => AccountInfoService());

class AccountInfoService  {
  
  // static AlwaysAliveProviderBase<AccountInfoService> get provider =>
  //     _contractProvider;
  bool loading = true;


  late final Web3Client _web3client;
  late final DeployedContract _deployedContract;
  late final EthereumAddress _contractAddress;
  late final ContractFunction _getBalance;
  late final ContractFunction _getAddress;
  late final String _abiCode;
  // credentials of deployer
  // late final Credentials _credentials;


  AccountInfoService();

  Future<void> init() async {
    await _initWeb3();
  }

  Future<void> _initWeb3() async {
    // Web3Client initilized
    _web3client = Web3Client(MyIdConstant.RPC_URL, Client());
    await _getAbi();
    await _getDeployedContract();

    // String privateKey =
    //   '54919c32395f2e6fa422a5791fc5ceb5b0d721416c11382eb183cbf941fc192d';
    // Credentials credentials;
    // EthereumAddress myAddress;

    // EthPrivateKey pk = EthPrivateKey.fromHex(privateKey);
    // Uint8List ul = pk.encodedPublicKey;
    // EthereumAddress ea = EthereumAddress.fromPublicKey(ul);

    // print('pk - ${ea.toString()}');

    // Future<void> getCredentials() async {
        
    //     credentials = await _web3client.credentialsFromPrivateKey(privateKey)
    //     myAddress = await credentials.extractAddress();
    // }
  }

  Future<void> _getAbi() async {
    // loads json file
    String abiFile = await rootBundle.loadString('assets/contracts/AccountInfo.json');

    final abiJSON = jsonDecode(abiFile);
    _abiCode = jsonEncode(abiJSON['abi']);

    // get contact address from abiJSON
    _contractAddress = EthereumAddress.fromHex(abiJSON['networks']['1337']['address']);
  }

  Future<void> _getDeployedContract() async {
    _deployedContract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "AccountInfo"), _contractAddress);

    _getBalance = _deployedContract.function("getBalance");
    _getAddress = _deployedContract.function("getAddress");

    // getCount();
  }

  getBalance(String address) async {
    // notifyListeners();
    debugPrint('to get balance from $address');

    final num = await _web3client
        .call(contract: _deployedContract, function: _getBalance, params: [EthereumAddress.fromHex(address)]);

    debugPrint(num.first.toString());

    return BigInt.parse(num.first.toString());
    
  }

  Future<String> getAddress() async {
    debugPrint('to get address');

    final address = await _web3client.call(contract: _deployedContract, function: _getAddress, params: []);
    debugPrint(address.first.toString());

    return address.first.toString();
  }

  Future<String> getEthBalance(String address) async {
    final ethAmount = await _web3client.getBalance(EthereumAddress.fromHex(address));
    // double amount = ethAmount.getValueInUnit(EtherUnit.ether);
    
    double num4 = double.parse((ethAmount.getValueInUnit(EtherUnit.ether)).toStringAsFixed(5));

    return '$num4 Eth';
  }
}
