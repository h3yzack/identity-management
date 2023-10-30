import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:myid_wallet/provider/issued_credential_provider.dart';
import 'package:myid_wallet/utils/common_util.dart';
import 'package:myid_wallet/utils/routes.dart';
import 'package:myid_wallet/utils/session_provider.dart';


class IssuerPage extends ConsumerStatefulWidget {
  const IssuerPage({super.key});
  
  @override
  ConsumerState<IssuerPage> createState() => _IssuerPageState();
}

class _IssuerPageState extends ConsumerState<IssuerPage> {

  @override
  void initState() {
    super.initState();
    // _initialize();
    
  }
  
  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(issuedCredentialProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credentials'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                addNewRecord('');
                // reload();
              },
            ),
          ],
      ),
      body: isLoading ?
            const Center(
                  child: CircularProgressIndicator(),
                )
            : _buildListOrEmptyState(ref)
    );
  }
  
  void _initialize() async {
    // dynamic session = await SessionManager().get("session");

    print("--------------");
    String? address = await SessionProvider.getAddress();
    String? chainId = await SessionProvider.getChainId();

    print('Address: $address , chainId: $chainId');

    // print(session);
  }

  Widget _buildListOrEmptyState(WidgetRef ref) {
    List<IssuedCredential> records = ref.watch(issuedCredentialProvider).credentials ?? [];

    return RefreshIndicator(
        onRefresh: _refresh,
        child: records.isEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(20.0),
                physics:const AlwaysScrollableScrollPhysics(),
                itemCount: 1,
                itemBuilder: (context, index) {
                  return const Center(
                      child: Text('No records available'),
                    );
                },
              )
              
            : _buildList(records),
      );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    reload();
  }

  Widget _buildList(List<IssuedCredential> records) {
    return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: records.length,
          itemBuilder: (context, index) {
            var record = records[index];
            var date = CommonUtil.formatDate((record.issueDate));
            bool status = record.issued ?? false;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: MemoryImage(base64Decode(record.base64Data!)),
                ),
                title: Text(record.credentialId!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Issued Date: $date'),
                    // Text('Status : $status'),
                    status
                      ? const Text(
                          'Verified',
                          style: TextStyle(
                            color: Color.fromARGB(255, 70, 117, 72),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Text('Unverified', style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          )),
                  ],
                ),
                onTap: () {
                  _goToDetailPage(record.key ?? '');
                },
              ),
            );
          },
        );
  }

  addNewRecord(String id) async {
    
    final out = await Navigator.pushNamed(context, MyIdRoutes.issueCredentialForm, arguments: {'id': id});

    print('go to detail record page $out');
    // reload();
  }

  reload() {
    ref.read(issuedCredentialProvider.notifier).loadRecords();
  }

  void _goToDetailPage(String id) {
    print('id to view: $id');
    Navigator.pushNamed(context, MyIdRoutes.issuerCredentialDetail, arguments: {'id': id});
  }

}