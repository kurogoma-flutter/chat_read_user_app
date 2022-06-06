import 'package:chat_app_read/pages/chat_list_page.dart';
import 'package:chat_app_read/pages/chat_page.dart';
import 'package:chat_app_read/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app_read/firebase_options.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/', // ベース：認証状態を識別してホーム画面orログインへ遷移させる
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage(),
      ),
      GoRoute(
        path: '/chatList',
        builder: (BuildContext context, GoRouterState state) =>
            const ChatListPage(),
      ),
      GoRoute(
        path: '/room/:roomId',
        builder: (context, state) {
          // パスパラメータの値を取得するには state.params を使用
          final String roomId = state.params['roomId']!;
          return ChatPage(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/login', // ログイン画面
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
    ],
    initialLocation: '/',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: 'チャット既読アプリ',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return const ChatListPage();
          } else {
            return const LoginPage();
          }
        });
  }
}
