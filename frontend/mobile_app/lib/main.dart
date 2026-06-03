import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation.dart';
import 'providers/task_provider.dart';
import 'providers/task_list_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder:
            (
            context,
            themeProvider,
            child,
            ) {
          return MaterialApp(
            debugShowCheckedModeBanner:
            false,

            title: 'Task Reminder',

            theme: AppTheme.lightTheme(
              themeProvider.seedColor,
            ),

            darkTheme:
            AppTheme.darkTheme(
              themeProvider.seedColor,
            ),

            themeMode:
            themeProvider.isDark
                ? ThemeMode.dark
                : ThemeMode.light,

            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}