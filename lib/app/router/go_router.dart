// app_router.dart
import 'package:go_router/go_router.dart';
import 'package:link_up/app/router/redirects.dart';
import 'package:link_up/presentation/screens/auth/login_screen.dart';
import 'package:link_up/presentation/screens/auth/register_screen.dart';
import 'package:link_up/presentation/screens/chat/chat_list_screen.dart';
import 'package:link_up/presentation/screens/chat/chat_screen.dart';
import 'package:link_up/presentation/screens/profile/profile_screen.dart';

class AppRouter {
  // Route paths as constants
  static const String rootPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String chatListPath = '/chat-list';
  static const String profilePath = '/profile';
  static const String chatPath = '/chat';

  // Routing configuration
  static final GoRouter router = GoRouter(
    initialLocation: rootPath,
    redirect: RouteRedirectHandler.handleRedirect,
    routes: _routes,
  );

  // Route definitions
  static final List<GoRoute> _routes = [
    GoRoute(
      path: rootPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: loginPath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: registerPath,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: chatListPath,
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: profilePath,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: chatPath,
      builder: (context, state) => const ChatScreen(),
    ),
  ];
}
