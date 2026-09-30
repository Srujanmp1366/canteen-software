import 'package:flutter/material.dart';

import '../../../models/raw_material.dart';

class MaterialFilters {
  const MaterialFilters({this.category, this.unit, this.activity = 'Active'});
  final String? category;
  final UnitType? unit;
  final String activity;
  int get count =>
      (category == null ? 0 : 1) +
      (unit == null ? 0 : 1) +
      (activity == 'Active' ? 0 : 1);
  bool matches(RawMaterial m) =>
      (category == null || m.category == category) &&
      (unit == null || m.unit == unit) &&
      (activity == 'All' || (activity == 'Active') == m.isActive);
}

Future<MaterialFilters?> showMaterialFilters(
  BuildContext context,
  MaterialFilters current,
) => showModalBottomSheet<MaterialFilters>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _FilterSheet(initial: current),
);

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final MaterialFilters initial;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String category = widget.initial.category ?? 'All categories';
  late String unit = widget.initial.unit?.name ?? 'All units';
  late String activity = widget.initial.activity;
  Widget dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: onChanged,
    ),
  );
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter materials',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          dropdown('Category', category, [
            'All categories',
            ...materialCategories,
          ], (v) => setState(() => category = v!)),
          dropdown('Unit', unit, [
            'All units',
            ...UnitType.values.map((u) => u.name),
          ], (v) => setState(() => unit = v!)),
          dropdown('Availability', activity, [
            'Active',
            'Inactive',
            'All',
          ], (v) => setState(() => activity = v!)),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              MaterialFilters(
                category: category == 'All categories' ? null : category,
                unit: unit == 'All units' ? null : UnitType.values.byName(unit),
                activity: activity,
              ),
            ),
            child: const Text('Apply filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, const MaterialFilters()),
            child: const Text('Reset filters'),
          ),
        ],
      ),
    ),
  );
}
