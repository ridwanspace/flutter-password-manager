import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/password_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/password_provider.dart';
import '../providers/category_provider.dart';
import '../services/encryption_service.dart';
import '../services/clipboard_service.dart';
import '../utils/icon_mapper.dart';
import '../widgets/confirm_dialog.dart';
import 'add_edit_entry_screen.dart';

class EntryDetailScreen extends StatefulWidget {
  final PasswordEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  bool _passwordVisible = false;
  late PasswordEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  String _decryptPassword() {
    final key = context.read<AuthProvider>().derivedKey!;
    return EncryptionService.decryptText(_entry.encryptedPassword, key);
  }

  String? _decryptNotes() {
    if (_entry.encryptedNotes == null) return null;
    final key = context.read<AuthProvider>().derivedKey!;
    return EncryptionService.decryptText(_entry.encryptedNotes!, key);
  }

  void _copyToClipboard(String text, String label) {
    ClipboardService.copyToClipboard(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteEntry() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Entry',
      content: 'Are you sure you want to delete "${_entry.title}"? This cannot be undone.',
    );

    if (confirmed && mounted) {
      final success =
          await context.read<PasswordProvider>().deleteEntry(_entry.id!);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _editEntry() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditEntryScreen(entry: _entry),
      ),
    );

    if (result == true && mounted) {
      // Reload the entry from the provider
      final passwordProvider = context.read<PasswordProvider>();
      await passwordProvider.loadEntries();
      final updated = passwordProvider.entries
          .where((e) => e.id == _entry.id)
          .firstOrNull;
      if (updated != null) {
        setState(() => _entry = updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.getCategoryById(_entry.categoryId);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    final notes = _decryptNotes();

    return Scaffold(
      appBar: AppBar(
        title: Text(_entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteEntry,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category badge
          if (category != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(IconMapper.getIcon(category.icon),
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Username
          if (_entry.username != null && _entry.username!.isNotEmpty)
            _buildDetailTile(
              icon: Icons.person,
              label: 'Username',
              value: _entry.username!,
              onCopy: () => _copyToClipboard(_entry.username!, 'Username'),
            ),

          // Password
          _buildDetailTile(
            icon: Icons.lock,
            label: 'Password',
            value: _passwordVisible ? _decryptPassword() : '\u2022' * 12,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _passwordVisible = !_passwordVisible);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      _copyToClipboard(_decryptPassword(), 'Password'),
                ),
              ],
            ),
          ),

          // URL
          if (_entry.url != null && _entry.url!.isNotEmpty)
            _buildDetailTile(
              icon: Icons.link,
              label: 'URL',
              value: _entry.url!,
              onCopy: () => _copyToClipboard(_entry.url!, 'URL'),
            ),

          // Notes
          if (notes != null && notes.isNotEmpty)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(notes),
                  ],
                ),
              ),
            ),

          // Timestamps
          const SizedBox(height: 16),
          Text(
            'Created: ${dateFormat.format(_entry.createdAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            'Updated: ${dateFormat.format(_entry.updatedAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: trailing ??
            (onCopy != null
                ? IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: onCopy,
                  )
                : null),
      ),
    );
  }
}
