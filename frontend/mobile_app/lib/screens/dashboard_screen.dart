import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import 'task_list_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    int today = tasks.where((e) {
      final now = DateTime.now();

      return !e.isCompleted &&
          e.dueDate.day == now.day &&
          e.dueDate.month == now.month &&
          e.dueDate.year == now.year;
    }).length;

    int overdue = tasks.where(
          (e) =>
      !e.isCompleted &&
          e.dueDate.isBefore(DateTime.now()),
    ).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildCard(
                  context,
                  "Tổng",
                  tasks.where((e) => !e.isCompleted).length,
                  Colors.blue.shade50,
                ),
                _buildCard(
                  context,
                  "Hoàn thành",
                  0,
                  Colors.green.shade50,
                ),
                _buildCard(
                  context,
                  "Hôm nay",
                  today,
                  Colors.orange.shade50,
                ),
                _buildCard(
                  context,
                  "Quá hạn",
                  overdue,
                  Colors.red.shade50,
                ),
              ],
            ),

            const SizedBox(height: 30),

            LinearProgressIndicator(
              value: provider.progress,
              minHeight: 10,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context,
      String title,
      int count,
      Color color,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskListView(
              title: title,
              filter: title == "Tổng"
                  ? "Tất cả"
                  : title,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            title == "Hoàn thành"
                ? const Icon(
              Icons.check_circle,
              size: 32,
              color: Colors.green,
            )
                : Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}