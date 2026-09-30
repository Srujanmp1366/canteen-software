import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/materials/presentation/materials_screen.dart';
import '../../features/materials/presentation/material_details_screen.dart';
import '../../features/materials/presentation/material_form_screen.dart';
import '../../features/materials/presentation/stock_form_screen.dart';
import '../../features/overview/presentation/workspace_overview.dart';
import 'app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
          GoRoute(
            path: '/inventory',
            builder: (_, state) => MaterialsScreen(
              key: ValueKey(state.uri.toString()),
              initialFilter: state.uri.queryParameters['filter'] ?? 'All',
            ),
          ),
          GoRoute(
            path: '/purchase',
            builder: (_, _) => const PurchaseOverview(),
          ),
          GoRoute(path: '/alerts', builder: (_, _) => const AlertsOverview()),
          GoRoute(path: '/more', builder: (_, _) => const MoreOverview()),
        ],
      ),
      GoRoute(
        path: '/inventory/new',
        builder: (_, _) => const MaterialFormScreen(),
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (_, state) => MaterialDetailsScreen(
          materialId: state.pathParameters['id']!,
          showBatches: state.uri.queryParameters['section'] == 'batches',
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                MaterialFormScreen(materialId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'add',
            builder: (_, state) => StockFormScreen(
              materialId: state.pathParameters['id']!,
              removing: false,
            ),
          ),
          GoRoute(
            path: 'remove',
            builder: (_, state) => StockFormScreen(
              materialId: state.pathParameters['id']!,
              removing: true,
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to dashboard'),
        ),
      ),
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});
