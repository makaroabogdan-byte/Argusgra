import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home_shell.dart';
import '../chats/chats_screen.dart';
import '../settings/settings_screen.dart';
import '../ai_chat/ai_chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chats',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/chats', builder: (context, state) => const ChatsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/ai_chat', builder: (context, state) => const AiChatScreen()),
    ],
  );
});
