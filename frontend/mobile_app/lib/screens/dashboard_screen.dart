import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../services/pdf_service.dart';
import 'task_list_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final total = provider.totalTasks;
    final completed = provider.completedTasks;
    final today = provider.todayTasks.where((task) => !task.isCompleted).length;
    final overdue = provider.overdueTasks.length;
    final pending = provider.pendingTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildCard(
                  context,
                  title: 'Tổng',
                  count: total,
                  color: Colors.blue.shade50,
                  filter: 'Tổng',
                ),
                _buildCard(
                  context,
                  title: 'Hoàn thành',
                  count: completed,
                  color: Colors.green.shade50,
                  filter: 'Hoàn thành',
                ),
                _buildCard(
                  context,
                  title: 'Hôm nay',
                  count: today,
                  color: Colors.orange.shade50,
                  filter: 'Hôm nay',
                ),
                _buildCard(
                  context,
                  title: 'Quá hạn',
                  count: overdue,
                  color: Colors.red.shade50,
                  filter: 'Quá hạn',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Đã hoàn thành $completed/$total công việc • Còn lại $pending',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: provider.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Xuất báo cáo PDF'),
                onPressed: () async {
                  await PdfService.exportTasks(provider.tasks);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required String filter,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskListView(
              title: title,
              filter: filter,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
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
