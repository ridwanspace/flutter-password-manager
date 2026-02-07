import 'package:flutter/material.dart';
import '../services/password_generator_service.dart';
import '../services/clipboard_service.dart';
import '../widgets/password_strength_indicator.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeDigits = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generatedPassword = PasswordGeneratorService.generate(
        length: _length.round(),
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeDigits: _includeDigits,
        includeSymbols: _includeSymbols,
      );
    });
  }

  void _copy() {
    ClipboardService.copyToClipboard(_generatedPassword);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Generated password display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SelectableText(
                      _generatedPassword,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    PasswordStrengthIndicator(password: _generatedPassword),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _copy,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _generate,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Length slider
            Text(
              'Length: ${_length.round()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _length,
              min: 4,
              max: 64,
              divisions: 60,
              label: _length.round().toString(),
              onChanged: (value) {
                setState(() => _length = value);
                _generate();
              },
            ),
            const SizedBox(height: 16),

            // Character type toggles
            Text(
              'Character Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Uppercase (A-Z)'),
              value: _includeUppercase,
              onChanged: (value) {
                setState(() => _includeUppercase = value);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Lowercase (a-z)'),
              value: _includeLowercase,
              onChanged: (value) {
                setState(() => _includeLowercase = value);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Digits (0-9)'),
              value: _includeDigits,
              onChanged: (value) {
                setState(() => _includeDigits = value);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Symbols (!@#\$...)'),
              value: _includeSymbols,
              onChanged: (value) {
                setState(() => _includeSymbols = value);
                _generate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
