import 'package:flutter/foundation.dart';

class AppConstants {
  static const List<String> priorityLabels = [
    'Thấp',
    'Trung Bình',
    'Cao',
  ];

  static String get defaultApiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5453';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5453';
      default:
        return 'http://localhost:5453';
    }
  }

  static String priorityLabel(int value) {
    if (value < 0 || value >= priorityLabels.length) {
      return priorityLabels.first;
    }

    return priorityLabels[value];
  }

  static int priorityValue(String label) {
    final index = priorityLabels.indexOf(label);
    return index >= 0 ? index : 0;
  }
}
