import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}