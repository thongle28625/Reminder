import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/task_model.dart';

class PdfService {
  static Future<void> exportTasks(
      List<TaskModel> tasks,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'BÁO CÁO CÔNG VIỆC',
              ),
            ),

            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              headers: const [
                'Tên',
                'Ưu tiên',
                'Ngày',
                'Trạng thái',
              ],
              data: tasks.map((task) {
                return [
                  task.title,
                  task.priorityLabel,
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(task.dueDate),
                  task.isCompleted
                      ? 'Hoàn thành'
                      : 'Chưa hoàn thành',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async =>
          pdf.save(),
    );
  }
}