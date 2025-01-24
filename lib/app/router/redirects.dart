import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/data/repositories/auth_repo.dart';

import 'go_router.dart';

class RouteRedirectHandler {
  // Routes that require authentication
  static const List<String> protectedRoutes = [
    AppRouter.chatListPath,
    AppRouter.chatPath,
    AppRouter.profilePath,
  ];

  // Routes only accessible when not authenticated
  static const List<String> authRoutes = [
    AppRouter.loginPath,
    AppRouter.registerPath,
  ];

  // Centralized redirect logic
  static Future<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    final token = await AuthRepository.retrieveToken();

    // Redirect unauthenticated users from protected routes
    if (token == null && protectedRoutes.contains(state.uri.toString())) {
      return AppRouter.rootPath;
    }

    // Redirect authenticated users from auth routes
    if (token != null && authRoutes.contains(state.uri.toString())) {
      return AppRouter.chatListPath;
    }

    return null; // No redirection needed
  }
}
