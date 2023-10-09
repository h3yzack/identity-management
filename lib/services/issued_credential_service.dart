
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:web3dart/web3dart.dart';

class IssuedCredentialService {

  Web3Client? web3client;
  
  IssuedCredentialService();

  IssuedCredentialService.web3(this.web3client);
  
 
  Future<IssuedCredentialService> loadContract() async {
    return this;
  }

  List<IssuedCredential> getIssuedCredentials(String issuerAddress) {
    final icBox = Hive.box<IssuedCredential>('IssuedCredential');
    final records = icBox.values.where((record) => record.issuerAddress == issuerAddress).toList();
    // tasks.sort((a, b) => a.priority.compareTo(b.priority));
    return records;
  }

  List<IssuedCredential> getByCreatedBy(String createdBy) {
    final icBox = Hive.box<IssuedCredential>('IssuedCredential');
    final records = icBox.values.where((record) => record.createdBy == createdBy).toList();
    // tasks.sort((a, b) => a.priority.compareTo(b.priority));
    return records;
  }
}