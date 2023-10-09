import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/model/issued_credential.dart';
import 'package:myid_wallet/provider/issued_credential_provider.dart';
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
                goToDetail('');
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

    // Check if the list is empty
    if (records.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
              const Duration(seconds: 1),
              () {
                reload();
              }
            );
        },
        child:  const Center(
            child: Text('No record'),
          ));
    } else {
      // Build the ListView when the list is not empty
      return RefreshIndicator(
        child: ListView.separated(
          itemCount: records.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            var record = records[index];
            return ListTile(
              title: Text(record.issueDate.toString()),
              subtitle: Text(record.userDid ?? ''),
              trailing: const Icon(Icons.arrow_right_sharp),
                onTap: () {
                  // goToDetail(record.did);
                },
            );
          },
        ), onRefresh: () { 
            return Future.delayed(
              const Duration(seconds: 1),
              () {

                reload();
              }
            );
        },
      );
    }
  }

  goToDetail(String id) async {
    
    final out = await Navigator.pushNamed(context, MyIdRoutes.issueCredentialForm, arguments: {'id': id});

    print('go to detail record page $out');
    // reload();
  }

  reload() {
    ref.read(issuedCredentialProvider.notifier).loadRecords();
  }

}