
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';

class WalletService {

  WalletService();

  // local storage
  save(WalletCredential walletCredential) async {
    final icBox = await Hive.openBox<WalletCredential>('WalletCredential');

    icBox.put(walletCredential.credentialId, walletCredential);
  }

  delete(String key) async {
    final icBox = await Hive.openBox<WalletCredential>('WalletCredential');
    icBox.delete(key);
  }

  // local storage
  WalletCredential? getByKey(String key) {
    final icBox = Hive.box<WalletCredential>('WalletCredential');
    final record = icBox.get(key);

    return record;
  }

  List<WalletCredential> getAll() {
    final icBox = Hive.box<WalletCredential>('WalletCredential');
    final records = icBox.values.toList();
    records.sort((a, b) => a.issueDate.compareTo(b.issueDate));
    // tasks.sort((a, b) => a.priority.compareTo(b.priority));
    return records;
  }
}