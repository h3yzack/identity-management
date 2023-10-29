
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart';
import 'package:myid_wallet/model/did_document.dart';
import 'package:myid_wallet/services/did_document_service.dart';
import 'package:myid_wallet/utils/common_constant.dart';
import 'package:myid_wallet/utils/session_provider.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import 'package:web3dart/web3dart.dart';

part 'did_provider.freezed.dart';

@freezed
class DidState with _$DidState {
  const factory DidState({
    @Default(true) bool isLoading,
    @Default(false) bool isSaving,
    @Default(false) bool isBack,
    @Default(0) int recordAdded,
    List<DidDocument>? didDocuments,
  }) = _DidState;

  const DidState._();
}

class DidNotifier extends StateNotifier<DidState> {
  late final Web3Client _web3client;
  SessionProvider sessionStorage = SessionProvider();
  
  DidNotifier() : super(const DidState(didDocuments: [])){
    _web3client = Web3Client(MyIdConstant.RPC_URL, Client());

    loadDids();
  }
  

  loadDids() async {
    state = state.copyWith(isLoading: true);
    final didService = await DidDocumentService(_web3client).loadContract();

    String address = await SessionProvider.getAddress() ?? '';

    if (address.isNotEmpty) {
      final didDocuments = await didService.getDidDocumentByUser(address);
      state = state.copyWith(didDocuments: didDocuments, isLoading: false, isBack: false);
    } else {
      state = state.copyWith(isLoading: false, isBack: false);
    }

  }
  
  // loadSearchedNews(String title) async {
  //   state = state.copyWith(isLoading: true);
  //   final newsResponse = await NewsService().fetchNewsBySearching(title);
  //   final news = NewsModel.fromJson(newsResponse);
  //   state = state.copyWith(newsModel: news,isLoading: false);
  // }

  saveDidDocument(Web3App web3App, String name, String type)  {
    state = state.copyWith(isSaving: true);

    // final didService = await DidDocumentService(_web3client).loadContract();
    // final status = await didService.saveDidDocument(web3App, name, type);

    // print('SAVE DID DOCUMENT STATUS: $status');

    // state =  state.copyWith(isSaving: false, recordAdded: 2);

    // return true;
  }

  updateIsSaving(bool status) {
    state = state.copyWith(isSaving: status);
  }

  updateIsBack(bool status) {
    state = state.copyWith(isBack: status);
  }

  cancelTask() {
    state = state.copyWith(isSaving: false, isLoading: false, isBack: true);
  }
}

final didDocumentProvider = StateNotifierProvider<DidNotifier, DidState>((ref)=> DidNotifier());