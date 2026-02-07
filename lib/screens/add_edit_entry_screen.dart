import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/password_provider.dart';
import '../providers/category_provider.dart';
import '../services/encryption_service.dart';
import '../services/password_generator_service.dart';
import '../widgets/password_field.dart';
import '../widgets/password_strength_indicator.dart';

class AddEditEntryScreen extends StatefulWidget {
  final PasswordEntry? entry;

  const AddEditEntryScreen({super.key, this.entry});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();
  int? _selectedCategoryId;
  bool _isLoading = false;

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final entry = widget.entry!;
      final key = context.read<AuthProvider>().derivedKey!;
      _titleController.text = entry.title;
      _usernameController.text = entry.username ?? '';
      _passwordController.text =
          EncryptionService.decryptText(entry.encryptedPassword, key);
      if (entry.encryptedNotes != null) {
        _notesController.text =
            EncryptionService.decryptText(entry.encryptedNotes!, key);
      }
      _urlController.text = entry.url ?? '';
      _selectedCategoryId = entry.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    final password = PasswordGeneratorService.generate();
    setState(() {
      _passwordController.text = password;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final passwordProvider = context.read<PasswordProvider>();
    final key = authProvider.derivedKey!;

    bool success;
    if (isEditing) {
      success = await passwordProvider.updateEntry(
        id: widget.entry!.id!,
        title: _titleController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        password: _passwordController.text,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        categoryId: _selectedCategoryId,
        clearCategory: _selectedCategoryId == null,
        encryptionKey: key,
        createdAt: widget.entry!.createdAt,
      );
    } else {
      success = await passwordProvider.addEntry(
        title: _titleController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        password: _passwordController.text,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        categoryId: _selectedCategoryId,
        encryptionKey: key,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save entry')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'Add Entry'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username / Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordController,
                labelText: 'Password *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Generate password',
                  onPressed: _generatePassword,
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return PasswordStrengthIndicator(password: value.text);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('No Category'),
                  ),
                  ...categoryProvider.categories.map(
                    (cat) => DropdownMenuItem<int?>(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
