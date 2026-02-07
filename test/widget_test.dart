import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_password_manager/app.dart';
import 'package:flutter_password_manager/providers/auth_provider.dart';
import 'package:flutter_password_manager/providers/password_provider.dart';
import 'package:flutter_password_manager/providers/category_provider.dart';

void main() {
  testWidgets('App launches and shows lock screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PasswordProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const PasswordManagerApp(),
      ),
    );

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Should show the lock screen with setup prompt
    expect(find.text('Create Master Password'), findsOneWidget);
  });
}
