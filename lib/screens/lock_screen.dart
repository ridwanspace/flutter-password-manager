import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_field.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final password = _passwordController.text;

    // Unfocus text fields before rebuilding to avoid web engine assertion
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration.zero);

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await authProvider.setupMasterPassword(password);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!success) {
      setState(() => _error = authProvider.lastError ?? 'Failed to set up master password');
    }
  }

  Future<void> _handleUnlock() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final password = _passwordController.text;

    // Unfocus text fields before rebuilding to avoid web engine assertion
    FocusScope.of(context).unfocus();
    await Future.delayed(Duration.zero);

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await authProvider.unlock(password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (!success) {
        setState(() => _error = 'Incorrect master password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isSetup = !authProvider.isMasterPasswordSet;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  isSetup ? 'Create Master Password' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSetup
                      ? 'Set a strong master password to protect your vault'
                      : 'Enter your master password to unlock',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PasswordField(
                  controller: _passwordController,
                  labelText: 'Master Password',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (isSetup && value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                if (isSetup) ...[
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmController,
                    labelText: 'Confirm Password',
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (isSetup ? _handleSetup : _handleUnlock),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isSetup ? 'Create Password' : 'Unlock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
