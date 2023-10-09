
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class SessionInfo {
  final String topic;
  final String chainId;
  final String address;


  SessionInfo({
    required this.topic,
    required this.chainId,
    required this.address
  });
  
}

class SessionProvider  {
  
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store a key-value pair securely
  static Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Read a value from secure storage
  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Delete a key-value pair from secure storage
  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  static Future<String?> getAddress() async {
    return await _storage.read(key: 'address');
  }

  static Future<String?> getTopic() async {
    return await _storage.read(key: 'topic');
  }

  static Future<String?> getChainId() async {
    return await _storage.read(key: 'chainId');
  }

  Future<void> saveSessionData(SessionData sessionData) async {
      var nameSpace = sessionData.namespaces["eip155"];
      String fromWallet = nameSpace!.accounts[0].split(":")[2];
      String chainId = nameSpace.accounts[0].split(":")[1];

      await write(key: 'address', value: fromWallet);
      await write(key: 'chainId', value: chainId);
      await write(key: 'topic', value: sessionData.topic);
  }

  static clearSession() async {
    await delete(key: 'address');
    await delete(key: 'chainId');
    await delete(key: 'topic');
  }

  static Future<SessionInfo> getSessionInfo() async {
    String address = await getAddress() ?? '';
    String topic = await getTopic() ?? '';
    String chainId = await getChainId() ?? '';

    SessionInfo sessionInfo = SessionInfo(address: address, chainId: chainId, topic: topic);

    return sessionInfo;
  }


}