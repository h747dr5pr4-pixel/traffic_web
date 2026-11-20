import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/mock_data.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final violations = mockViolationsList;
    final paid = violations.where((v) => v.status == ViolationStatus.paid);
    final disputed =
        violations.where((v) => v.status == ViolationStatus.disputed).length;
    final wanted = violations
        .where((v) => v.isWanted)
        .map((v) => v.plateNumber)
        .toSet()
        .length;

    final collected = paid.fold<double>(0, (sum, v) => sum + v.amount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600 ? 1 : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 12,
                children: [
                  const Text(
                    'التقارير المرورية والإحصائيات',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'التصدير محاكاة حالياً، وسيُفعّل ربط PDF لاحقاً.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('تصدير التقرير'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'ملخص تجريبي محسوب من بيانات النظام الحالية.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: columns == 1 ? 3.2 : 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ReportCard(
                    title: 'إجمالي المخالفات',
                    value: '${violations.length}',
                    icon: Icons.assessment,
                    color: Colors.blue,
                  ),
                  _ReportCard(
                    title: 'الغرامات المحصّلة',
                    value: '${collected.toStringAsFixed(0)} د.ل',
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                  _ReportCard(
                    title: 'التظلمات قيد المراجعة',
                    value: '$disputed',
                    icon: Icons.hourglass_top,
                    color: Colors.orange,
                  ),
                  _ReportCard(
                    title: 'مركبات بالقائمة الأمنية',
                    value: '$wanted',
                    icon: Icons.security,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}