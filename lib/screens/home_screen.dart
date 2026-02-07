import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/password_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/entry_list_tile.dart';
import '../widgets/category_chip.dart';
import 'add_edit_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'password_generator_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasswordProvider>().loadEntries();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordProvider = context.watch<PasswordProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  passwordProvider.setSearchQuery(query);
                },
              )
            : const Text('Password Manager'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  passwordProvider.setSearchQuery('');
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'generator':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PasswordGeneratorScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'lock':
                  authProvider.lock();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generator',
                child: ListTile(
                  leading: Icon(Icons.password),
                  title: Text('Password Generator'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'lock',
                child: ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Lock Vault'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          if (categoryProvider.categories.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: passwordProvider.selectedCategoryId == null,
                      onSelected: (_) {
                        passwordProvider.setSelectedCategory(null);
                      },
                    ),
                  ),
                  ...categoryProvider.categories.map(
                    (category) => CategoryChip(
                      category: category,
                      isSelected:
                          passwordProvider.selectedCategoryId == category.id,
                      onTap: () {
                        passwordProvider.setSelectedCategory(
                          passwordProvider.selectedCategoryId == category.id
                              ? null
                              : category.id,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Entry list
          Expanded(
            child: passwordProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : passwordProvider.entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              passwordProvider.searchQuery.isNotEmpty
                                  ? 'No matching entries'
                                  : 'No passwords yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (passwordProvider.searchQuery.isEmpty)
                              Text(
                                'Tap + to add your first password',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: passwordProvider.entries.length,
                        itemBuilder: (context, index) {
                          final entry = passwordProvider.entries[index];
                          final category = categoryProvider
                              .getCategoryById(entry.categoryId);
                          return EntryListTile(
                            entry: entry,
                            category: category,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EntryDetailScreen(entry: entry),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
