
import 'package:myid_wallet/model/ethereum_transaction.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

enum EIP155Methods {
  personalSign,
  ethSign,
  ethSignTransaction,
  ethSignTypedData,
  ethSendTransaction,
  ethSendRawTransaction
}

enum EIP155Events {
  chainChanged,
  accountsChanged,
}

extension EIP155MethodsX on EIP155Methods {
  String? get value => EIP155.methods[this];
}

extension EIP155MethodsStringX on String {
  EIP155Methods? toEip155Method() {
    final entries = EIP155.methods.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

extension EIP155EventsX on EIP155Events {
  String? get value => EIP155.events[this];
}

extension EIP155EventsStringX on String {
  EIP155Events? toEip155Event() {
    final entries = EIP155.events.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

class EIP155 {
  static final Map<EIP155Methods, String> methods = {
    EIP155Methods.personalSign: 'personal_sign',
    EIP155Methods.ethSign: 'eth_sign',
    EIP155Methods.ethSignTransaction: 'eth_signTransaction',
    EIP155Methods.ethSignTypedData: 'eth_signTypedData',
    EIP155Methods.ethSendTransaction: 'eth_sendTransaction',
    EIP155Methods.ethSendRawTransaction: 'eth_sendRawTransaction'
  };

  static final Map<EIP155Events, String> events = {
    EIP155Events.chainChanged: 'chainChanged',
    EIP155Events.accountsChanged: 'accountsChanged',
  };

  static Future<dynamic> personalSign({
    required Web3App web3App,
    required String topic,
    required String chainId,
    required String address,
    required String data,
  }) async {
    return await web3App.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: methods[EIP155Methods.personalSign]!,
        params: [data, address],
      ),
    );
  }

  static Future<dynamic> ethSendTransaction({
    required Web3App web3App,
    required String topic,
    required String chainId,
    required EthereumTransaction transaction,
  }) async {
    try {
      print(transaction.toJson());
      return await web3App.request(
        topic: topic,
        chainId: chainId,
        request: SessionRequestParams(
          method: methods[EIP155Methods.ethSendTransaction]!,
          params: [transaction.toJson()],
        ),
      );
    } catch (e) {
      print(e);
    }
    
  }

  
}
