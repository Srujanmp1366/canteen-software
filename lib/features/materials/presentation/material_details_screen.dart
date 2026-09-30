import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import 'widgets/material_card.dart';
import 'widgets/stock_rows.dart';

class MaterialDetailsScreen extends StatefulWidget {
  const MaterialDetailsScreen({
    super.key,
    required this.materialId,
    this.showBatches = false,
  });
  final String materialId;
  final bool showBatches;
  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> {
  final batchKey = GlobalKey();
  bool scrolled = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/inventory')),
      title: const Text('Material details'),
      actions: [
        IconButton(
          tooltip: 'Edit Material',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/inventory/${widget.materialId}/edit'),
        ),
      ],
    ),
    body: SafeArea(
      child: AsyncInventoryView(
        builder: (data) {
          final m = data.materials
              .where((m) => m.materialId == widget.materialId)
              .firstOrNull;
          if (m == null) {
            return const EmptyState(
              title: 'Material not found',
              message: 'Choose a material from inventory.',
            );
          }
          final batches = data.batches
              .where((b) => b.materialId == m.materialId)
              .toList();
          final transactions = data.transactions
              .where((t) => t.materialId == m.materialId)
              .toList();
          if (widget.showBatches && !scrolled) {
            scrolled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (batchKey.currentContext != null) {
                Scrollable.ensureVisible(
                  batchKey.currentContext!,
                  duration: const Duration(milliseconds: 300),
                );
              }
            });
          }
          return PageBody(
            children: [
              Text(m.name, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(m.materialId, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(m.stockLabel, tone: materialTone(m)),
              ),
              const SizedBox(height: 24),
              StatGrid(
                children: [
                  StatCard(
                    label: 'Current stock',
                    value: quantity(m.currentQuantity, m.unit),
                    icon: Icons.inventory_2_outlined,
                  ),
                  StatCard(
                    label: 'Reorder level',
                    value: quantity(m.reorderLevel, m.unit),
                    icon: Icons.low_priority,
                  ),
                  StatCard(
                    label: 'Price / ${m.unit.label}',
                    value: money(m.pricePerUnit),
                    icon: Icons.sell_outlined,
                  ),
                  StatCard(
                    label: 'Stock value',
                    value: money(m.stockValue),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  if (m.isActive)
                    FilledButton.icon(
                      onPressed: () =>
                          context.push('/inventory/${m.materialId}/add'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stock'),
                    ),
                  if (m.currentQuantity > 0)
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push('/inventory/${m.materialId}/remove'),
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove Stock'),
                    ),
                ],
              ),
              const SectionHeader('Material information'),
              AppCard(
                child: Column(
                  children: [
                    _Detail('Category', m.category),
                    _Detail('Unit', m.unit.label),
                    _Detail(
                      'Expiry tracking',
                      m.expiryRequired ? 'Required' : 'Optional',
                    ),
                    _Detail('Created', date(m.createdAt)),
                    _Detail('Updated', dateTime(m.updatedAt)),
                    _Detail(
                      'Active status',
                      m.isActive ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
              ),
              SectionHeader('Stock batches', key: batchKey),
              if (batches.isEmpty)
                const EmptyState(
                  title: 'No batches yet',
                  message: 'Add stock to create the first batch.',
                ),
              for (final b in batches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BatchRow(batch: b, material: m),
                ),
              const SectionHeader('Recent transactions'),
              if (transactions.isEmpty)
                const EmptyState(
                  title: 'No transactions yet',
                  message: 'Stock movements will appear here.',
                ),
              for (final t in transactions.take(10))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TransactionRow(transaction: t, material: m),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}
