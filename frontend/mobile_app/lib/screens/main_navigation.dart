import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Thêm import này
import '../providers/task_provider.dart';
import '../providers/task_list_provider.dart';// Thêm import này
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // XÓA DÒNG: int currentIndex = 0; (Vì đã có Provider quản lý)

  final pages = const [
    DashboardScreen(),
    HomeScreen(),
    SearchScreen(),
  ];
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TaskProvider>().loadTasks();
      context.read<TaskListProvider>().loadLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe biến index từ TaskProvider
    final currentIndex = context.watch<TaskProvider>().tabIndex;

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: "Dashboard"),
          NavigationDestination(icon: Icon(Icons.task), label: "Tasks"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
        ],
        onDestinationSelected: (index) {
          // Cập nhật index thông qua Provider
          context.read<TaskProvider>().setTabIndex(index);
        },
      ),
    );
  }
}