import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myvc_wallet/model/issued_credential.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';
import 'package:myvc_wallet/pages/home_page.dart';
import 'package:myvc_wallet/pages/issuer/issuer_detail_page.dart';
import 'package:myvc_wallet/pages/issuer/issuer_download_page.dart';
import 'package:myvc_wallet/pages/issuer/issuer_form_page.dart';
import 'package:myvc_wallet/pages/login_page.dart';
import 'package:myvc_wallet/pages/profile/form_page.dart';
import 'package:myvc_wallet/pages/verifier/presentation_page.dart';
import 'package:myvc_wallet/pages/wallet/detail_id_page.dart';
import 'package:myvc_wallet/pages/wallet/submit_request_page.dart';
import 'package:myvc_wallet/pages/wallet/upload_id_page.dart';
import 'package:myvc_wallet/utils/common_constant.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

Future<void> main() async {

  // init hive
  WidgetsFlutterBinding.ensureInitialized();
  // final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  // Hive.init(appDocumentDir.path);
  
  await Hive.initFlutter();
  Hive.registerAdapter(IssuedCredentialAdapter());
  Hive.registerAdapter(WalletCredentialAdapter());

  await Hive.openBox<IssuedCredential>('IssuedCredential');
  await Hive.openBox<WalletCredential>('WalletCredential');
  
  runApp(const ProviderScope(child: MyApp()));
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
        name: 'MyVC Wallet',
        description: 'MyVC Wallet',
        url: 'https://myvcwallet.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
      ),
    );

    setState(() {
      _initialized = true;
    });

    bool storage = true;
    bool videos = true;
    bool photos = true;
    bool camera = true;

    // Only check for storage < Android 13
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('ANDROID SDK: ${androidInfo.version.sdkInt}');
    if (androidInfo.version.sdkInt >= 33) {
      videos = await Permission.videos.status.isGranted;
      photos = await Permission.photos.status.isGranted;
    } else {
      storage = await Permission.storage.status.isGranted;
    }

    camera = await Permission.camera.status.isGranted;

    if (storage && videos && photos && camera) {
      // Good to go!
      print('all good to go $storage - $videos - $photos - $camera');
    } else {
      // crap.
      print('permission access denied');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
        Permission.videos,
        Permission.camera
      ].request();
      print('Camera: ${statuses[Permission.camera]} - ${statuses[Permission.storage]}');
    }
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
      title: 'My VC Wallet',
      debugShowCheckedModeBanner: false,
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
        MyIdRoutes.uploadCredential: (context) =>  const UploadIdPage(), 
      },
      onGenerateRoute: (settings) {
        if (settings.name == MyIdRoutes.profileForm) {
            final args = settings.arguments as Map<String, String?>;
            final param = args['id'];
            return MaterialPageRoute(
              builder: (context) => ProfileFormPage(web3App: _web3App!, id: param),
            );
        } else if (settings.name == MyIdRoutes.issueCredentialForm) {
            final args = settings.arguments as Map<String, String?>;
            final param = args['id'];
            return MaterialPageRoute(
              builder: (context) => IssuerFormPage(web3App: _web3App!, id: param),
            );
        } else if (settings.name == MyIdRoutes.issuerCredentialDetail) {
            final args = settings.arguments as Map<String, String?>;
            final param = args['id'];
            return MaterialPageRoute(
              builder: (context) => IssuerDetailPage(web3App: _web3App!, id: param),
            );
        } else if (settings.name == MyIdRoutes.issuerCredentialDownload) {
            final args = settings.arguments as Map<String, String?>;
            final param = args['id'];
            return MaterialPageRoute(
              builder: (context) => DownloadVCPage(id: param),
            );
        } else if (settings.name == MyIdRoutes.myIdDetail) {
            final args = settings.arguments as Map<String, String?>;
            final param = args['id']!;
            return MaterialPageRoute(
              builder: (context) => WalletDetailPage(web3App: _web3App!, id: param),
            );
        } else if (settings.name == MyIdRoutes.myIdSubmitRequest) {
            final args = settings.arguments as Map<String, String?>;
            final requestData = args['requestData']!;  // in hex
            return MaterialPageRoute(
              builder: (context) => SubmitRequestPage(web3App: _web3App!, requestData: requestData),
            );
        } else if (settings.name == MyIdRoutes.verifierViewRequest) {
            final args = settings.arguments as Map<String, String?>;
            final requestData = args['requestData']!;  // in hex
            return MaterialPageRoute(
              builder: (context) => CredentialPresentationPage(requestData: requestData),
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

