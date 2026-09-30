import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/raw_material.dart';

StatusTone materialTone(RawMaterial m) => !m.isActive
    ? StatusTone.neutral
    : m.isOutOfStock
    ? StatusTone.red
    : m.isLowStock
    ? StatusTone.orange
    : StatusTone.green;

IconData categoryIcon(String category) => switch (category) {
  'Grains' => Icons.grass,
  'Dairy' => Icons.water_drop_outlined,
  'Vegetables' => Icons.eco_outlined,
  'Beverages' => Icons.coffee_outlined,
  'Bakery' => Icons.bakery_dining_outlined,
  'Protein' => Icons.egg_outlined,
  'Spices' => Icons.spa_outlined,
  _ => Icons.kitchen_outlined,
};

class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    this.onAction,
    this.compact = false,
  });
  final RawMaterial material;
  final ValueChanged<String>? onAction;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final m = material;
    return AppCard(
      onTap: () => context.push('/inventory/${m.materialId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon(m.category),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      compact ? m.category : '${m.materialId} · ${m.category}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onAction != null)
                PopupMenuButton<String>(
                  tooltip: 'Actions for ${m.name}',
                  onSelected: onAction,
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (m.isActive)
                      const PopupMenuItem(
                        value: 'add',
                        child: Text('Add Stock'),
                      ),
                    if (m.currentQuantity > 0)
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove Stock'),
                      ),
                    const PopupMenuItem(
                      value: 'batches',
                      child: Text('View Batches'),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(m.isActive ? 'Deactivate' : 'Activate'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                quantity(m.currentQuantity, m.unit),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              StatusBadge(m.stockLabel, tone: materialTone(m)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Reorder at ${quantity(m.reorderLevel, m.unit)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (m.isLowStock && m.reorderLevel > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (m.currentQuantity / m.reorderLevel).clamp(0, 1),
                minHeight: 4,
                backgroundColor: AppColors.orangeSoft,
                color: AppColors.orange,
              ),
            ),
          ],
          if (!compact) ...[
            const Divider(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Text(
                  '${money(m.pricePerUnit)} / ${m.unit.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${money(m.stockValue)} stock value',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
