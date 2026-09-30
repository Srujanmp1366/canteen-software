import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilter,
    this.activeFilters = 0,
  });
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final int activeFilters;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search material, category or ID',
            prefixIcon: Icon(Icons.search),
            hintStyle: TextStyle(fontSize: 13),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filledTonal(
        onPressed: onFilter,
        tooltip: 'Filter materials',
        icon: Badge(
          isLabelVisible: activeFilters > 0,
          label: Text('$activeFilters'),
          child: const Icon(Icons.tune),
        ),
      ),
    ],
  );
}
