import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../models/purchase_order.dart';
import '../../../models/stock_batch.dart';
import '../../materials/application/inventory_controller.dart';
import '../../materials/presentation/widgets/material_card.dart';
import '../../materials/presentation/widgets/stock_rows.dart';
import 'overview_sheet.dart';
import 'widgets/order_preview.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final suppliers = ref.watch(suppliersProvider);
    return AsyncInventoryView(
      builder: (data) {
        final low = data.materials
            .where((m) => m.isActive && m.isLowStock)
            .toList();
        final expiring =
            data.batches
                .where((b) => b.status == BatchStatus.expiringSoon)
                .toList()
              ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
        final total = data.materials.fold<double>(
          0,
          (sum, m) => sum + m.stockValue,
        );
        final pending = orders.asData?.value
            .where((o) => o.status == PurchaseOrderStatus.pending)
            .length;
        final batchRows = expiring
            .map(
              (b) => BatchRow(batch: b, material: data.material(b.materialId)),
            )
            .toList();
        final transactionRows = data.transactions
            .map(
              (t) => TransactionRow(
                transaction: t,
                material: data.material(t.materialId),
              ),
            )
            .toList();
        final orderRows =
            orders.asData?.value
                .map(
                  (o) => OrderPreview(
                    order: o,
                    supplierName:
                        suppliers.asData?.value
                            .where((s) => s.supplierId == o.supplierId)
                            .firstOrNull
                            ?.supplierName ??
                        o.supplierId,
                  ),
                )
                .toList() ??
            [];
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(inventoryProvider.notifier).refresh();
            ref.invalidate(ordersProvider);
            ref.invalidate(suppliersProvider);
          },
          child: PageBody(
            children: [
              Text(
                date(DateTime.now()).toUpperCase(),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your kitchen, in balance.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Everything you need for a well-stocked day.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              StatGrid(
                children: [
                  StatCard(
                    label: 'Total materials',
                    value: '${data.materials.length}',
                    icon: Icons.inventory_2_outlined,
                    onTap: () => context.go('/inventory'),
                  ),
                  StatCard(
                    label: 'Low stock',
                    value: '${low.length}',
                    icon: Icons.trending_down,
                    color: AppColors.orange,
                    onTap: () => context.go('/inventory?filter=Low%20stock'),
                  ),
                  StatCard(
                    label: 'Expiring soon',
                    value: '${expiring.length}',
                    icon: Icons.schedule,
                    color: AppColors.orange,
                    onTap: () =>
                        showOverview(context, 'Expiring soon', batchRows),
                  ),
                  StatCard(
                    label: 'Pending orders',
                    value: pending == null ? '—' : '$pending',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.blue,
                    onTap: () => context.go('/purchase'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white70,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'INVENTORY VALUE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      money(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Current stock at material unit prices',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => context.go('/inventory'),
                      label: const Text('Manage inventory'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                    ),
                  ],
                ),
              ),
              SectionHeader(
                'Needs a top-up',
                onViewAll: () => context.go('/inventory?filter=Low%20stock'),
              ),
              if (low.isEmpty)
                const AppCard(
                  child: EmptyState(
                    title: 'Stock looks healthy',
                    message:
                        'All active materials are above their reorder levels.',
                  ),
                ),
              for (final m in low.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MaterialCard(material: m, compact: true),
                ),
              SectionHeader(
                'Use these first',
                onViewAll: () =>
                    showOverview(context, 'Expiring soon', batchRows),
              ),
              if (batchRows.isEmpty)
                const EmptyState(
                  title: 'Nothing expiring soon',
                  message: 'No batches expire in the next seven days.',
                ),
              for (final row in batchRows.take(2))
                Padding(padding: const EdgeInsets.only(bottom: 12), child: row),
              SectionHeader(
                'Recent transactions',
                onViewAll: () =>
                    showOverview(context, 'Stock movements', transactionRows),
              ),
              for (final row in transactionRows.take(3))
                Padding(padding: const EdgeInsets.only(bottom: 12), child: row),
              SectionHeader(
                'Recent purchase orders',
                onViewAll: () => context.go('/purchase'),
              ),
              orders.when(
                data: (_) => Column(
                  children: [
                    for (final row in orderRows.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: row,
                      ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => EmptyState(
                  title: 'Orders unavailable',
                  message: 'Try loading orders again.',
                  action: TextButton(
                    onPressed: () => ref.invalidate(ordersProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
