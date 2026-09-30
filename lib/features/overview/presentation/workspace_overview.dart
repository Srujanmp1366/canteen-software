import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/inventory_alert.dart';
import '../../dashboard/presentation/widgets/order_preview.dart';
import '../../materials/application/inventory_controller.dart';

// Read-only summaries support Phase 1. Management workflows follow later.
class PurchaseOverview extends ConsumerWidget {
  const PurchaseOverview({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersProvider);
    return ref
        .watch(ordersProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => EmptyState(
            title: 'Could not load orders',
            message: 'Please try again.',
            action: FilledButton(
              onPressed: () => ref.invalidate(ordersProvider),
              child: const Text('Retry'),
            ),
          ),
          data: (orders) => PageBody(
            children: [
              Text(
                'Purchase overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              const Text('Recent orders and expected deliveries.'),
              const SizedBox(height: 18),
              const _Notice(
                'Order creation and receiving will be available in a later release.',
              ),
              const SizedBox(height: 18),
              for (final o in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderPreview(
                    order: o,
                    supplierName:
                        suppliers.asData?.value
                            .where((s) => s.supplierId == o.supplierId)
                            .firstOrNull
                            ?.supplierName ??
                        o.supplierId,
                  ),
                ),
            ],
          ),
        );
  }
}

class AlertsOverview extends StatelessWidget {
  const AlertsOverview({super.key});
  @override
  Widget build(BuildContext context) => AsyncInventoryView(
    builder: (data) {
      final alerts = data.alerts
          .where((a) => a.status == AlertStatus.active)
          .toList();
      return PageBody(
        children: [
          Text(
            'Inventory alerts',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text('${alerts.length} active alerts · Updated with your stock'),
          const SizedBox(height: 20),
          if (alerts.isEmpty)
            const EmptyState(
              title: 'No active alerts',
              message: 'Your stock levels and expiry dates look good.',
            ),
          for (final a in alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => context.push('/inventory/${a.materialId}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(
                      words(a.alertType.name),
                      tone: a.alertType == AlertType.expired
                          ? StatusTone.red
                          : StatusTone.orange,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.message,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Current: ${quantity(a.currentQuantity, data.material(a.materialId).unit)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (a.alertType == AlertType.lowStock)
                      Text(
                        'Reorder level: ${quantity(a.thresholdQuantity, data.material(a.materialId).unit)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      dateTime(a.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'View material →',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class MoreOverview extends StatelessWidget {
  const MoreOverview({super.key});
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Text('Your workspace', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 20),
      const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.restaurant_outlined, size: 32, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Canteen Inventory',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('Smart Stock Management'),
            SizedBox(height: 16),
            Text('Prototype · Version 0.1.0'),
            SizedBox(height: 8),
            Text(
              'Changes are kept for this session. Restarting the app restores the sample inventory.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const _Notice(
        'Reports and workspace settings are planned for a later release.',
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: () => context.go('/inventory'),
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('Manage inventory'),
      ),
    ],
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 20, color: AppColors.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );
}
