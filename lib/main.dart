import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:myid_wallet/pages/home_page.dart';
import 'package:myid_wallet/pages/login_page.dart';
import 'package:myid_wallet/pages/profile/form_page.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/routes.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

void main() {
  // runApp(const MyApp());
  runApp(const ProviderScope(child: MyApp()));
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => ActionProvider()),
  //       // Add other providers here if needed
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  bool _initialized = false;
  Web3App? _web3App;
  

  @override
  void initState() {
    initialize();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    // _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    super.dispose();
  }

  Future<void> initialize() async {
    print('Project ID: ${MyIdConstant.projectId}');

    _web3App = await Web3App.createInstance(
      projectId: MyIdConstant.projectId,
      metadata: const PairingMetadata(
        name: 'MyID Wallet',
        description: 'MyID Wallet',
        url: 'https://myidwallet.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
    );

    // TODO  registerEventHandler
    // _web3App!.registerEventHandler(chainId: chain.chainId, event: event);
    // _web3App!.onSessionPing.subscribe(_onSessionPing);
    // _web3App!.onSessionEvent.subscribe(_onSessionEvent);

    setState(() {
      _initialized = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
        ),
      );
    }
    
    return MaterialApp(
      title: 'My ID Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400
          )
        )
      ),

      initialRoute: MyIdRoutes.homeRoute,
      routes: {
        MyIdRoutes.loginRoute: (context) => LoginPage(web3App: _web3App!),
        MyIdRoutes.homeRoute: (context) =>  HomePage(web3App: _web3App!),
        // MyIdRoutes.profileRoute: (context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == MyIdRoutes.profileForm) {
          final args = settings.arguments as Map<String, String?>;
          final param = args['id'];
          return MaterialPageRoute(
            builder: (context) => ProfileFormPage(web3App: _web3App!, id: param),
          );
        }
      },
    );
  }

  // void _onSessionPing(SessionPing? args) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return EventWidget(
  //         title: StringConstants.receivedPing,
  //         content: 'Topic: ${args!.topic}',
  //       );
  //     },
  //   );
  // }

  // void _onSessionEvent(SessionEvent? args) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return EventWidget(
  //         title: StringConstants.receivedEvent,
  //         content:
  //             'Topic: ${args!.topic}\nEvent Name: ${args.name}\nEvent Data: ${args.data}',
  //       );
  //     },
  //   );
  // }
  
}

