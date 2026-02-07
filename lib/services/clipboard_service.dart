import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class ClipboardService {
  static Timer? _clearTimer;

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _scheduleClear();
  }

  static void _scheduleClear() {
    _clearTimer?.cancel();
    _clearTimer = Timer(
      const Duration(seconds: AppConstants.clipboardClearSeconds),
      () async {
        await Clipboard.setData(const ClipboardData(text: ''));
      },
    );
  }

  static void cancelClear() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
