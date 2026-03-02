import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:js' as js;

void showAddToHomeScreenPrompt(BuildContext context) {
  if (!kIsWeb) return; // Only run on Web

  // A simple way to detect iOS
  final userAgent = js.context['navigator']['userAgent'].toString().toLowerCase();
  final isIos = userAgent.contains('iphone') || userAgent.contains('ipad') || userAgent.contains('ipod');

  if (isIos) {
    // For iOS, we still need to show manual instructions.
    _showIosInstallPrompt(context);
  }
  // For other platforms (Chrome, etc.), the new install_prompt.js will handle
  // showing a custom banner automatically. No Dart code is needed.
}

void _showIosInstallPrompt(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add to Home Screen"),
        content: const Text(
          "To install this app on your iPhone or iPad:\n1. Tap the Share icon in Safari.\n2. Scroll down and choose 'Add to Home Screen'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Got It"),
          )
        ],
      ),
    );
  });
}
