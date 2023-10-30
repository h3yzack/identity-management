import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myvc_wallet/model/chain_metadata.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:myvc_wallet/utils/crypto/eip155.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:myvc_wallet/utils/session_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {

  final Web3App web3App;
  
  const LoginPage({super.key, required this.web3App});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  bool _shouldDismissQrCode = true;
  SessionData? _sessionData;
  final ValueNotifier<IdConnectionState> connectedSession = ValueNotifier<IdConnectionState>(IdConnectionState.disconnected);
  bool isLoading = false;
  SessionProvider sessionStorage = SessionProvider();

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() {
    // Add a listener to respond to route changes

    connectedSession.addListener(() async {
      print('listener triggered ... : $connectedSession.value');
      setLoading(false);

      if (connectedSession.value == IdConnectionState.connected) {
          await sessionStorage.saveSessionData(_sessionData!);

          showPlatformToast(
            child: const Text(
              StringConstants.connectionEstablished,
            ),
            context: context,
          );

          // Navigator.of(context).popAndPushNamed(MyIdRoutes.homeRoute);
          goToHome();

      } else {
          showPlatformToast(
            child: const Text(
              StringConstants.connectionFailed,
            ),
            context: context,
          );
      }
    });
  }

  void goToHome() {
    // Navigator.of(context).popUntil(ModalRoute.withName(MyIdRoutes.loginRoute));
    // Navigator.of(context).pushNamed(MyIdRoutes.homeRoute);
    if (kIsWeb) {
      print('try to go to home?');
       Navigator.of(context).popAndPushNamed(MyIdRoutes.homeRoute, arguments: widget.web3App) ;
    } else {
        Navigator.of(context).pushNamedAndRemoveUntil(MyIdRoutes.homeRoute, (route) => false);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyID Wallet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
      ),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading) 
              Container(
                width: 100.0, // Set the container's width as needed
                height: 100.0, // Set the container's height as needed
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                // color: Colors.blue,
                child: Center(
                  child: Text(
                    '',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ),
            const SizedBox(height: 10.0),
            // const SizedBox.square(dimension: 15.0),
            Text(
                "Login", 
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox.square(dimension: 8.0),
            const SizedBox(height: 10.0),
            Text(
              "Sign in to your account", 
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: ()  {
                // Handle login button press
                // Navigator.pushNamed(context, '/home');
                setLoading(true);
                _onConnect();
              },
              child: Text('Login with MetaMask', style: Theme.of(context).textTheme.labelMedium),
            ),
            // Consumer<SessionProvider>(
            //     builder: (context, sessionProvider, child) {
            //       print(sessionProvider.session);
            //       return Text('Login: ${sessionProvider.isLogin}');
            //     },
            //   ),
        
          ],
        ),
      ),
    );
  }
  
  void setLoading(bool status) {
    setState(() {
      isLoading = status; 
    });
  }
  

  Future<void> _onConnect() async {
    final Map<String, RequiredNamespace> requiredNamespaces = {};

    ChainMetadata chain = MyIdConstant.testChain;

    final String chainName = chain.chainId.split(':')[0];
    
    // final RequiredNamespace rNamespace = RequiredNamespace(
    //   chains: [chain.chainId],
    //   methods: EIP155.methods.values.toList(),
    //   events: EIP155.events.values.toList(),
    // );
    final RequiredNamespace rNamespace = RequiredNamespace(
      chains: [chain.chainId],
      methods: EIP155.methods.values.toList(),
      events: EIP155.events.values.toList(),
    );
    requiredNamespaces[chainName] = rNamespace;

    debugPrint('Required namespaces: $requiredNamespaces');

    debugPrint('Creating connection and session');
    final ConnectResponse res = await widget.web3App.connect(
      requiredNamespaces: requiredNamespaces,
    );
    debugPrint('Connection created, connection response: ${res.uri}');

    print(res.uri!.toString());

    // final Uri? uri = res.uri;

    // final String encodedUrl = Uri.encodeComponent('$uri');
    // var deepLinkUrl = 'metamask://wc?uri=$encodedUrl';
    // debugPrint('URL: $deepLinkUrl');
    
    debugPrint('Is WEB? : $kIsWeb');
    if (!kIsWeb && !Platform.isMacOS) {
      debugPrint('found mobile app ');
      await launchUrlString(res.uri!.toString(), mode: LaunchMode.externalApplication);
    } else {
      _showQrCode(res);
    }

    try {
      debugPrint('Awaiting session proposal settlement');
      final SessionData sessionData = await res.session.future;

      // debugPrint('Requesting authentication');
      // final AuthRequestResponse authRes = await widget.web3App.requestAuth(
      //   pairingTopic: res.pairingTopic,
      //   params: AuthRequestParams(
      //     chainId: chain.chainId,
      //     domain: MyIdConstant.domain,
      //     aud: MyIdConstant.aud,
      //     // statement: 'Welcome to example flutter app',
      //   ),
      // );

      // debugPrint('Awaiting authentication response');
      // final authResponse = await authRes.completer.future;

      // print(authResponse);

      if (kIsWeb || Platform.isMacOS) {
        Navigator.pop(context);
      }

      setState(() {
        _sessionData = sessionData;
        connectedSession.value = IdConnectionState.connected;
      });


    } catch (e) {
      debugPrint(e.toString());
      
      if (kIsWeb || Platform.isMacOS) {
        Navigator.pop(context);
      }

      setState(() {
        connectedSession.value = IdConnectionState.connectionFailed;
      });
    
    }
  }

  Future<void> _showQrCode(ConnectResponse response) async {
    // Show the QR code
    debugPrint('Showing QR Code: ${response.uri}');

    _shouldDismissQrCode = true;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            StringConstants.scanQrCode,
            style: StyleConstants.titleText,
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            height: 350,
            child: Center(
              child: Column(
                children: [
                  QrImageView(
                    data: response.uri!.toString(),
                  ),
                  const SizedBox(
                    height: StyleConstants.linear16,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: response.uri!.toString(),
                        ),
                      );
                      await showPlatformToast(
                        child: const Text(
                          StringConstants.copiedToClipboard,
                        ),
                        context: context,
                      );
                    },
                    child: const Text(
                      'Copy URL to Clipboard',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    _shouldDismissQrCode = false;
  }
  
  
}

