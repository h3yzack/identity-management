import 'package:flutter/material.dart';
import 'package:myid_wallet/model/chain_metadata.dart';

class MyIdConstant {
  static const String projectId = '22bf11a2a23ee7f716654ab11cec27af';
  static const String rpcUrl = 'https://vastly-active-mudfish.ngrok-free.app/';

  static const String RPC_URL = "https://vastly-active-mudfish.ngrok-free.app/";
  static const String WS_URL = "ws://0.0.0.0:7545";

  static const String aud = 'https://myidwallet.com/login';
  static const String domain = 'myidwallet.com';

  static final testChain = ChainMetadata(
      type: ChainType.eip155,
      chainId: 'eip155:1337',
      name: 'Metamask',
      logo: '/chain-logos/eip155-1.png',
      color: Colors.blue.shade300,
      isTestnet: true,
      rpc: ['https://vastly-active-mudfish.ngrok-free.app'],
    );
}

class StyleConstants {
  static const Color primaryColor = Color.fromARGB(255, 16, 165, 206);
  static const Color secondaryColor = Color(0xFF1A1A1A);
  static const Color grayColor = Color.fromARGB(255, 180, 180, 180);
  static const Color titleTextColor = Color(0xFFFFFFFF);

  // Linear
  static const double linear8 = 8;
  static const double linear16 = 16;
  static const double linear24 = 24;
  static const double linear32 = 32;
  static const double linear48 = 48;
  static const double linear40 = 40;
  static const double linear56 = 56;
  static const double linear72 = 72;
  static const double linear80 = 80;

  // Magic Number
  static const double magic10 = 10;
  static const double magic14 = 14;
  static const double magic20 = 20;
  static const double magic40 = 40;
  static const double magic64 = 64;

  // Width
  static const double maxWidth = 400;

  // Text styles
  static const TextStyle titleText = TextStyle(
    color: Colors.black,
    fontSize: linear32,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitleText = TextStyle(
    color: Colors.black,
    fontSize: linear24,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle buttonText = TextStyle(
    color: Colors.black,
    fontSize: magic14,
    fontWeight: FontWeight.w600,
  );
}

class StringConstants {
  // General
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String delete = 'Delete';

  static const String receivedPing = 'Received Ping';
  static const String receivedEvent = 'Received Event';
  static const String alertEvent = 'Alert';

  static const String scanQrCode = 'Scan QR Code';
  static const String copiedToClipboard = 'Copied to clipboard';
  static const String connectionFailed = 'Session setup failed';
  static const String connectionEstablished = 'Session established';
}

enum IdConnectionState {
  disconnected,
  connecting,
  connected,
  connectionFailed,
  connectionCancelled,
}

enum Status { init, loading, done }