import 'package:flutter/material.dart';

String describeError(Object error) {
  final raw = error.toString();

  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }

  return raw;
}

void showErrorSnackBar(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(describeError(error)),
      backgroundColor: Colors.red,
    ),
  );
}
