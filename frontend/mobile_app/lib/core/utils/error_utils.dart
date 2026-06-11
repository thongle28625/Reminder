import 'package:flutter/material.dart';

String describeError(Object error) {
  final raw = error.toString();

  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }

  return raw;
}

String contextualizeError(String contextLabel, Object error) {
  return '$contextLabel\n${describeError(error)}';
}

void showErrorSnackBar(
  BuildContext context,
  Object error, {
  String? contextLabel,
}) {
  final message = contextLabel == null
      ? describeError(error)
      : contextualizeError(contextLabel, error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}
