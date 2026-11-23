import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> items;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryGrid({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childAspectRatio: 1.1,
      children: items.map((c) {
        final isSelected = c.name == selected;
        return InkWell(
          onTap: () => onSelected(c.name),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.15)
                  : Colors.white,
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  c.icon,
                  color: isSelected ? primary : Colors.grey.shade700,
                ),
                const SizedBox(height: 6),
                Text(
                  c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
