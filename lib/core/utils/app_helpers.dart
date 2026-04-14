import 'package:flutter/material.dart';

class AppHelpers {
  static void showComingSoonSnackBar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName section coming soon!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static String formatTimestamp(DateTime dateTime) {
    // Simple mock formatting
    return '${dateTime.hour}:${dateTime.minute}';
  }
}
