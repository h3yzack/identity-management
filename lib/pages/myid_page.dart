import 'package:flutter/material.dart';
import 'package:myid_wallet/utils/session_provider.dart';


class MyIdPage extends StatefulWidget {
  const MyIdPage({super.key});

  
  @override
  State<MyIdPage> createState() => _MyIdPageState();
}


class _MyIdPageState extends State<MyIdPage> {

  SessionProvider sessionStorage = SessionProvider();
  
  @override
  void initState() {
    super.initState();
    _initialize();
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyID Wallet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('This is the MY ID Screen'),
      ),
    );
  }
  
  void _initialize() async {
    // dynamic session = await SessionManager().get("session");

    print("--------------");
    String? address = await sessionStorage.getAddress();
    String? chainId = await sessionStorage.getChainId();

    print('Address: $address , chainId: $chainId');

    // print(session);
  }

}