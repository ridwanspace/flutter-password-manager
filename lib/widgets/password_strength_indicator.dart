import 'package:flutter/material.dart';
import '../services/password_generator_service.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = PasswordGeneratorService.calculateStrength(password);
    final label = PasswordGeneratorService.strengthLabel(strength);
    final color = _getColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: Colors.grey.shade300,
                  color: color,
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.5) return Colors.orange;
    if (strength < 0.7) return Colors.yellow.shade700;
    if (strength < 0.9) return Colors.lightGreen;
    return Colors.green;
  }
}
