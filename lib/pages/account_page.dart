import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:myvc_wallet/model/chain_metadata.dart';
import 'package:myvc_wallet/services/account_info_service.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:myvc_wallet/utils/crypto/eip155.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:myvc_wallet/utils/session_provider.dart';
import 'package:myvc_wallet/widgets/event_widget.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';


class AccountPage extends StatefulWidget {
  final Web3App web3App;
  
  const AccountPage({super.key, required this.web3App});
  
  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage> {

  late Client httpClient;
  late Web3Client ethClient;
  late String? accountAddress;
  SessionProvider sessionStorage = SessionProvider();

  String _ethBalance = '0';
  String _bcAddress = '-';

  
  @override
  void initState() {
    super.initState();
    _initialize();

    // widget.web3App.getActiveSessions().
    
    print('key: ${widget.web3App.getActiveSessions()}');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // width: 100.0, // Set the container's width as needed
            height: 350.0, // Set the container's height as needed
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.all(10.0),
            // color: Colors.blue,
            child:  Center(
              child: Card(
                child: SizedBox.expand(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'Account Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16), // Body padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your balance', style: TextStyle(fontSize: 13),),
                              Text(
                                _ethBalance.toString(), 
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
                              ),
                              const SizedBox(height: 20.0),
                              const Text('Your Address', style: TextStyle(fontSize: 13),),
                              Text(
                                _bcAddress.toString(), 
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
                              ),
                              const SizedBox(height: 50.0),
                              Center(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                    ),
                                    onPressed: ()  {
                                      logout();
                                      // sign();
                                    },
                                    child: const Text('Logout', style: TextStyle(
                                      color: Colors.white, fontSize: 13,

                                    ),),
                                  ),
                              ),
                              
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          
        ],
      ),
    );
  }
  
  void _initialize() async {
    accountAddress = await SessionProvider.getAddress();
   
    try {
      AccountInfoService accountInfoService = AccountInfoService();
      await accountInfoService.init();

      final balance = await accountInfoService.getBalance(accountAddress.toString());
      var ethBalance =  await accountInfoService.getEthBalance(accountAddress.toString());
      var bcAddress =  await accountInfoService.getAddress();
      
      setState(() {
        _ethBalance = ethBalance;
        _bcAddress = accountAddress.toString();
      });

      print("--------------");
      String? address = await SessionProvider.getAddress();
      String? chainId = await SessionProvider.getChainId();

      print('Address: $address , chainId: $chainId');
      print('bcAddress $bcAddress, balance: $balance, ethBalance: $ethBalance');
    } catch (e) {
      print(e);
      _onSessionEvent("Connection fail!");
    }
    

   
  }

  void _onSessionEvent(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: StringConstants.alertEvent,
          content:
              message,
        );
      },
    );
  }

  logout() async {
    try {
      var topic = await SessionProvider.getTopic();
      widget.web3App.disconnectSession(topic: topic.toString(), reason: const WalletConnectError(code: 01, message: "logout"));

      await SessionProvider.clearSession();

      Navigator.popAndPushNamed(context, MyIdRoutes.loginRoute);
    } catch (e) {
      print(e);
    }

  }
  
  sign() async {
    var topic = await SessionProvider.getTopic();
    ChainMetadata chain = MyIdConstant.testChain;

    // String raw = '0xc16a39D447a6775f0BDfCc9B4BD9846343F7caaddid:myid:23235454324322e4bbdf7c-95c3-4cf6-a48d-d85b8cdb5f89'
    String data = '0xf4b1864725aaf821efbacc8e242935745f7a39d2643ccc26c9c0371778d1d753';

    // var x = '0x${hex.encode(utf8.encode('Hello World'))}';
    print('data: $data - ${accountAddress.toString()}');

    // String data = 'hello';

    var ress = await widget.web3App.request(
      topic: topic.toString(),
      chainId: chain.chainId,
      request: SessionRequestParams(
        method: EIP155.methods[EIP155Methods.personalSign]!,
        params: [data, accountAddress.toString()],
      ),
    );

    // var res = await widget.web3App.request(
    //   topic: topic.toString(),
    //   chainId: chain.chainId,
    //   request: SessionRequestParams(
    //     method: 'eth_sign',
    //     params: [data, accountAddress.toString()],
    //   ),
    // );

    print(ress);
  }
}