import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class EditAppearanceScreen
    extends StatelessWidget {
  const EditAppearanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider =
    context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tùy chỉnh giao diện",
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Card(
              child: SwitchListTile(
                value:
                themeProvider.isDark,
                title: const Text(
                  "Chế độ tối",
                ),
                subtitle: const Text(
                  "Bật hoặc tắt Dark Mode",
                ),
                secondary: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onChanged: (_) {
                  themeProvider
                      .toggleTheme();
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Màu giao diện",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
              Colors.primaries.map(
                    (color) {
                  return GestureDetector(
                    onTap: () {
                      themeProvider
                          .changeColor(
                        color,
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration:
                      BoxDecoration(
                        color: color,
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          width: 3,
                          color: themeProvider
                              .seedColor ==
                              color
                              ? Colors.black
                              : Colors
                              .transparent,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.palette,
                ),
                title: const Text(
                  "Màu hiện tại",
                ),
                subtitle: Text(
                  themeProvider
                      .seedColor
                      .toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}