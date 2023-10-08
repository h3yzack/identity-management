import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myid_wallet/model/did_document.dart';
import 'package:myid_wallet/provider/did_provider.dart';
import 'package:myid_wallet/utils/routes.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';


class ProfilePage extends ConsumerStatefulWidget {
  final Web3App web3App;
  
  const ProfilePage({super.key, required this.web3App});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();

}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    bool isLoading = ref.watch(didDocumentProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile (DIDs)'),
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

  reload() {
    ref.read(didDocumentProvider.notifier).loadDids();
  }

  Widget _buildListOrEmptyState(WidgetRef ref) {
    List<DidDocument> didDocuments = ref.watch(didDocumentProvider).didDocuments ?? [];

    // Check if the list is empty
    if (didDocuments.isEmpty) {
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
          itemCount: didDocuments.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            var record = didDocuments[index];
            return ListTile(
              title: Text(record.title),
              subtitle: Text(record.did),
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
    
    final out = await Navigator.pushNamed(context, MyIdRoutes.profileForm, arguments: {'id': id});

    print('go to detail record page $out');
    reload();
  }
}


// class _ProfilePageState extends ConsumerState<ProfilePage> {
  
//   SessionProvider sessionStorage = SessionProvider();
//   final List<dynamic> items = [];
//   Status status = Status.init;
  
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
    
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(didServiceProvider);
//     status = state.addRecordStatus;
    
//     if (state.addRecordStatus == Status.done) {
//       print('reload page...');
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Profile (DIDs) - ${status.name}'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () {
//                 // goToDetail('');
//                 test();
//               },
//             ),
//           ],
//       ),
//       body: _buildListOrEmptyState()
        

//     );
//   }

  // Widget _buildListOrEmptyState() {
  //   // Check if the list is empty
  //   if (items.isEmpty) {
  //     return const Center(
  //       child: Text('No record'),
  //     );
  //   } else {
  //     // Build the ListView when the list is not empty
  //     return RefreshIndicator(
  //       child: ListView.separated(
  //         itemCount: items.length,
  //         separatorBuilder: (BuildContext context, int index) => const Divider(),
  //         physics: const AlwaysScrollableScrollPhysics(),
  //         itemBuilder: (BuildContext context, int index) {
  //           var record = items[index] as DidDocument;
  //           return ListTile(
  //             title: Text(record.title),
  //             subtitle: Text(record.did),
  //             trailing: const Icon(Icons.arrow_right_sharp),
  //               onTap: () {
  //                 goToDetail(record.did);
  //               },
  //           );
  //         },
  //       ), onRefresh: () { 
  //           return Future.delayed(
  //             const Duration(seconds: 1),
  //             () async {
  //               await getRecords();
  //               setState(() {});
  //             }
  //           );
  //       },
  //     );
  //   }
  // }
  
//   void _initialize() async {
//     // dynamic session = await SessionManager().get("session");

//     print("--------------");
//     String? address = await sessionStorage.getAddress();
//     String? chainId = await sessionStorage.getChainId();

//     print('Address: $address , chainId: $chainId');

//     // print(session);

//     await getRecords();
//   }

//   getRecords() async {
//       // items.add({'title': 'Test A', 'did': 'did:myid:absd1223122232'});
//       // items.add({'title': 'Test B', 'did': 'did:issuer:dasdasd1334123'});
      

//       items.clear();

//       try {
//         String address = await sessionStorage.getAddress() ?? '';
//         DidService didService = DidService();
//         await didService.init();

//         List<DidDocument> list = await didService.getDIDsByUser(address);
//         // print('LIST: $list');

//         items.addAll(list);

//       } catch (e) {
//           print(e);
//       }

//       setState(() {
        
//       });
//   }

//   goToDetail(String id) {
//     print('go to detail record page $id');
//     Navigator.pushNamed(context, MyIdRoutes.profileForm, arguments: {'id': id});
//   }

//   test() async {
//     final state = ref.watch(didServiceProvider);

//     DidService didService = DidService();
//     await didService.init();

//     String address = await sessionStorage.getAddress() ?? '';
//     didService.getDIDsByUser(address);

//     print(state.addRecordStatus.name);

//     setState(() {
//       status = state.addRecordStatus;
//     });
    

//   }
// }