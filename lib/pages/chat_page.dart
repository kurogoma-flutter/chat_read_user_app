import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.roomId}) : super(key: key);
  final String roomId;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _chatText = '';
  TextEditingController _textEditingController = TextEditingController();

  handleChatText(e) {
    setState(() {
      _chatText = e;
    });
  }

  /// サインアウト処理
  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/');
    } on FirebaseAuthException catch (e) {
      print('サインアウトに失敗しました');
    }
  }

  Future<void> postMessage() async {
    List<String> initReadUser = [FirebaseAuth.instance.currentUser!.uid];

    // 更新処理
    if (_chatText.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.roomId)
          .update({
        'readUsers': initReadUser,
        'lastMessage': _chatText,
        'lastMessageAt': Timestamp.now()
      });

      _textEditingController.clear();
      _chatText = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('チャットページ',
            style: TextStyle(fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'チャットサンプル',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: TextFormField(
                controller: _textEditingController,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction, // 入力時バリデーション
                cursorColor: Colors.blueAccent,
                decoration: const InputDecoration(
                  focusColor: Colors.red,
                  labelText: 'message',
                  hintText: 'テキスト入力',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent)),
                  border: OutlineInputBorder(borderSide: BorderSide()),
                ),
                maxLines: 1,
                onChanged: (value) {
                  handleChatText(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "入力してください";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 50,
              width: 120,
              child: ElevatedButton(
                onPressed: () async {
                  await postMessage();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  '投稿',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
