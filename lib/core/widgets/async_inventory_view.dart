import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventory_repository.dart';
import '../../features/materials/application/inventory_controller.dart';
import 'empty_state.dart';

class AsyncInventoryView extends ConsumerWidget {
  const AsyncInventoryView({super.key, required this.builder});
  final Widget Function(InventorySnapshot) builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(inventoryProvider)
      .when(
        data: builder,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: EmptyState(
            title: 'Could not load inventory',
            message: 'Please try loading your inventory again.',
            action: FilledButton(
              onPressed: () => ref.invalidate(inventoryProvider),
              child: const Text('Retry'),
            ),
          ),
        ),
      );
}
