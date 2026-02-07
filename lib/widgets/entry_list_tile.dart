import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../models/category.dart';
import '../utils/icon_mapper.dart';

class EntryListTile extends StatelessWidget {
  final PasswordEntry entry;
  final Category? category;
  final VoidCallback onTap;

  const EntryListTile({
    super.key,
    required this.entry,
    this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            category != null
                ? IconMapper.getIcon(category!.icon)
                : Icons.lock,
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          entry.username ?? entry.url ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
