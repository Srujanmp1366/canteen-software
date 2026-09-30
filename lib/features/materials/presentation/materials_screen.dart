import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_inventory_view.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/page_body.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/raw_material.dart';
import '../application/inventory_controller.dart';
import 'material_filter_sheet.dart';
import 'widgets/material_card.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key, this.initialFilter = 'All'});
  final String initialFilter;
  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  String query = '';
  late String quickFilter = widget.initialFilter;
  MaterialFilters filters = const MaterialFilters();
  Future<void> _action(RawMaterial material, String action) async {
    final path = '/inventory/${material.materialId}';
    if (action != 'toggle') {
      context.push(
        action == 'batches' ? '$path?section=batches' : '$path/$action',
      );
      return;
    }
    try {
      await ref
          .read(inventoryProvider.notifier)
          .saveMaterial(
            material.copyWith(isActive: !material.isActive),
            isNew: false,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              material.isActive ? 'Material deactivated' : 'Material activated',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.push('/inventory/new'),
      icon: const Icon(Icons.add),
      label: const Text('Add Material'),
    ),
    body: AsyncInventoryView(
      builder: (data) {
        final materials = data.materials
            .where(
              (m) =>
                  filters.matches(m) &&
                  '${m.name} ${m.category} ${m.materialId}'
                      .toLowerCase()
                      .contains(query.trim().toLowerCase()) &&
                  (quickFilter == 'All' ||
                      quickFilter == 'Low stock' && m.isLowStock ||
                      quickFilter == 'Out of stock' && m.isOutOfStock),
            )
            .toList();
        return RefreshIndicator(
          onRefresh: () => ref.read(inventoryProvider.notifier).refresh(),
          child: PageBody(
            children: [
              Text(
                'Raw Materials',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'A clear view of every ingredient.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              AppSearchBar(
                onChanged: (v) => setState(() => query = v),
                activeFilters: filters.count,
                onFilter: () async {
                  final result = await showMaterialFilters(context, filters);
                  if (result != null && mounted) {
                    setState(() => filters = result);
                  }
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final label in ['All', 'Low stock', 'Out of stock'])
                    ChoiceChip(
                      label: Text(label),
                      selected: quickFilter == label,
                      onSelected: (_) => setState(() => quickFilter = label),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${materials.length} materials',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              if (materials.isEmpty)
                const EmptyState(
                  title: 'No materials found',
                  message: 'Try another search or adjust your filters.',
                ),
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final m in materials)
                      SizedBox(
                        width: constraints.maxWidth >= 650
                            ? (constraints.maxWidth - 14) / 2
                            : constraints.maxWidth,
                        child: MaterialCard(
                          material: m,
                          onAction: (action) => _action(m, action),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
