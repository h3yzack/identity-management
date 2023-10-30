
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:myvc_wallet/model/issued_credential.dart';
import 'package:myvc_wallet/services/issued_credential_service.dart';
import 'package:myvc_wallet/utils/session_provider.dart';

part 'issued_credential_provider.freezed.dart';

final issuedCredentialProvider = StateNotifierProvider<IssuedCredentialNotifier, IssuedCredentialState>((ref)=> IssuedCredentialNotifier());

@freezed
class IssuedCredentialState with _$IssuedCredentialState {
  const factory IssuedCredentialState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    @Default(0) int recordAdded,
    List<IssuedCredential>? credentials,
  }) = _IssuedCredentialState;

  const IssuedCredentialState._();
}

class IssuedCredentialNotifier extends StateNotifier<IssuedCredentialState> {

  IssuedCredentialNotifier() : super(const IssuedCredentialState(credentials: [])){
    // _web3client = Web3Client(MyIdConstant.RPC_URL, Client());

    loadRecords();
  }
  
  // load from local db
  loadRecords() async {
    state = state.copyWith(isLoading: true);

    final icService = IssuedCredentialService();
    String address = await SessionProvider.getAddress() ?? '';

    List<IssuedCredential> credentials = icService.getByCreatedBy(address);

    state = state.copyWith(credentials: credentials, isLoading: false);
  }
}