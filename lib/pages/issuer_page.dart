import 'package:flutter/material.dart';
import 'package:myid_wallet/utils/session_provider.dart';


class IssuerPage extends StatefulWidget {
  const IssuerPage({super.key});

  
  @override
  State<IssuerPage> createState() => _IssuerPageState();
}


class _IssuerPageState extends State<IssuerPage> {

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
        title: const Text('Credentials'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('This is the page for issuer'),
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