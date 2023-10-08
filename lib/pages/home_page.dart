import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/pages/account_page.dart';
import 'package:myid_wallet/pages/issuer_page.dart';
import 'package:myid_wallet/pages/myid_page.dart';
import 'package:myid_wallet/pages/profile_page.dart';
import 'package:myid_wallet/pages/verifier_page.dart';
import 'package:myid_wallet/provider/did_provider.dart';
import 'package:myid_wallet/utils/routes.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';


class HomePage extends ConsumerStatefulWidget {
  final Web3App web3App;
  
  const HomePage({super.key, required this.web3App});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}
class _HomePageState extends ConsumerState<HomePage> {

  SessionProvider sessionStorage = SessionProvider();
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // const MyIdPage(),
    // const ProfilePage(),
    // const IssuerPage(),
    // const VerifierPage()
  ];


  
  
  @override
  void initState() {
    super.initState();

    _widgetOptions.add(const MyIdPage());
    _widgetOptions.add(ProfilePage(web3App: widget.web3App));
    _widgetOptions.add(const IssuerPage());
    _widgetOptions.add(const VerifierPage());
    _widgetOptions.add(AccountPage(web3App: widget.web3App));
    _initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assured_workload_rounded),
              label: 'Issuer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_sharp),
              label: 'Verifier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
    if (address == null) {
      Navigator.popAndPushNamed(context, MyIdRoutes.loginRoute);
    }

    // reload DID DOC
    print('reload did document...');
    ref.read(didDocumentProvider.notifier).loadDids();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}