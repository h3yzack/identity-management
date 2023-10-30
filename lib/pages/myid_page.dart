import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:myvc_wallet/model/wallet_credential.dart';
import 'package:myvc_wallet/services/wallet_service.dart';
import 'package:myvc_wallet/utils/common_util.dart';
import 'package:myvc_wallet/utils/routes.dart';
import 'package:myvc_wallet/utils/session_provider.dart';


class MyIdPage extends StatefulWidget {
  const MyIdPage({super.key});

  
  @override
  State<MyIdPage> createState() => _MyIdPageState();
}


class _MyIdPageState extends State<MyIdPage> {

  SessionProvider sessionStorage = SessionProvider();
  List<WalletCredential> records = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _getRecords();
    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyVC Wallet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, MyIdRoutes.uploadCredential);
              },
            ),
          ],
      ),
      body: _buildListOrEmptyState(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Scan', // used by assistive technologies
        onPressed: () {
          Map<String, String> data = {
            'requestId': '123',
            'verifierAddress': '0xeA74Cd133001253377b48DdD9eB9641e6Bb024cA',
            'title': 'Show me your proof'
          };
          String jsonString = jsonEncode(data);
          String hexString = hex.encode(utf8.encode(jsonString));

          Navigator.pushNamed(context, MyIdRoutes.myIdSubmitRequest, arguments: {'requestData': hexString});
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
  
  void _getRecords() async {
    setState(() {
      isLoading = true;
    });
    final walletService = WalletService();
    List<WalletCredential> allRecords = walletService.getAll();

    setState(() {
      records = allRecords;
      isLoading = false;
    });
  }
  
  Widget _buildListOrEmptyState() {
    // Build the ListView when the list is not empty
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
    _getRecords();
  
  }

  Widget _buildList(List<WalletCredential> records) {
    return ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: records.length,
          itemBuilder: (context, index) {
            var record = records[index];
            var date = CommonUtil.formatDate((record.issueDate));
            // bool status = record. ?? false;
            return Card(
              margin: const EdgeInsets.all(5.0),
              child: ListTile(
                // leading: CircleAvatar(
                //   backgroundImage: MemoryImage(base64Decode(record.base64Data)),
                // ),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(record.base64Data)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(record.name ?? record.credentialId),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Issued: $date'),
                    const SizedBox(height: 20.0),
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

  void _goToDetailPage(String id) {
    print('id to view: $id');
    Navigator.pushNamed(context, MyIdRoutes.myIdDetail, arguments: {'id': id});
  }

}