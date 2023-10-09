import 'package:hive/hive.dart';

part 'issued_credential.g.dart';

@HiveType(typeId: 0)
class IssuedCredential extends HiveObject {
  @HiveField(0)
  String? credentialId;

  @HiveField(1)
  String? userDid;

  @HiveField(2)
  String? userAddress;
  
  @HiveField(3)
  String? base64Data;

  @HiveField(4)
  String? signature;
  
  @HiveField(5)
  String? issuerDid;

  @HiveField(6)
  String? issuerAddress;

  @HiveField(7)
  DateTime? issueDate;

  @HiveField(8)
  String? createdBy;

  IssuedCredential({
    this.credentialId,
    this.userDid,
    this.userAddress,
    this.base64Data,
    this.signature,
    this.issuerDid,
    this.issuerAddress,
    this.issueDate,
    this.createdBy
  });
}