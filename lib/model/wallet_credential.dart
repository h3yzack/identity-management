
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myid_wallet/utils/common_util.dart';

part 'wallet_credential.g.dart';

@HiveType(typeId: 1)
class WalletCredential extends HiveObject {
  @HiveField(0)
  String credentialId;

  @HiveField(1)
  String signature;

  @HiveField(2)
  DateTime issueDate;

  @HiveField(3)
  String issuerAddress;

  @HiveField(4)
  String issuerDid;

  @HiveField(5)
  String userDid;

  @HiveField(6)
  String? name;

  @HiveField(7)
  String? signedData;

  @HiveField(8)
  String base64Data;

  WalletCredential({
    required this.credentialId,
    required this.userDid,
    required this.issuerDid,
    required this.issuerAddress,
    required this.base64Data,
    this.signedData,
    required this.signature,
    required this.issueDate,
    this.name
  });

  factory WalletCredential.fromJson(Map<String, dynamic> json) {
    return WalletCredential(
      credentialId: json['credentialId'],
      userDid: json['userDid'],
      issuerDid: json['issuerDid'],
      issuerAddress: json['issuerAddress'],
      base64Data: json['base64Data'],
      signedData: json['signData'] ?? '',
      signature: json['signature'],
      issueDate: DateTime.parse(json['issuedDate'])
    );
  }
}