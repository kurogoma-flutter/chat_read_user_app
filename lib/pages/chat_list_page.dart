import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  /// サインアウト処理
  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/');
    } on FirebaseAuthException catch (e) {
      print('サインアウトに失敗しました');
    }
  }

  bool _isRead(List readUsers) {
    User? user = FirebaseAuth.instance.currentUser;
    if (readUsers.contains(user!.uid)) {
      return false;
    }
    return true;
  }

  readAction(String roomId, List readUsers) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    if (!readUsers.contains(uid)) {
      readUsers.add(uid);
    }

    FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .update({'readUsers': readUsers});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
        title: const Text('チャット一覧ページ',
            style: TextStyle(fontWeight: FontWeight.w400)),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chatRoom')
              .orderBy('createdAt')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("データが見つかりません"));
            }
            // データ表示
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                final data = document.data()! as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Text('${data['roomId']}'),
                    subtitle: Text('${data['lastMessage']}'),
                    trailing: Visibility(
                      visible: _isRead(data['readUsers']),
                      child: const CircleAvatar(
                        maxRadius: 4,
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    onTap: () async {
                      await readAction(data['roomId'], data['readUsers']);
                      context.go('/room/${data['roomId']}');
                    },
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
