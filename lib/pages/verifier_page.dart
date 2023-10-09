import 'package:flutter/material.dart';
import 'package:myid_wallet/utils/session_provider.dart';


class VerifierPage extends StatefulWidget {
  const VerifierPage({super.key});

  
  @override
  State<VerifierPage> createState() => _VerifierPageState();
}


class _VerifierPageState extends State<VerifierPage> {

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
        title: const Text('Verificiation Request'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('This is the page for verifier'),
      ),
    );
  }
  
  void _initialize() async {
    // dynamic session = await SessionManager().get("session");

    print("--------------");
    String? address = await SessionProvider.getAddress();
    String? chainId = await SessionProvider.getChainId();

    print('Address: $address , chainId: $chainId');

    // print(session);
  }

}