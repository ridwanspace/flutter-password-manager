import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/icon_mapper.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category.name),
        avatar: Icon(
          IconMapper.getIcon(category.icon),
          size: 18,
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
