import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AuditLogView extends StatefulWidget {
  const AuditLogView({super.key});

  @override
  State<AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<AuditLogView> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _auditLogs = const [
    {
      'id': 'LOG-901',
      'action': 'إضافة مخالفة جديدة',
      'user': 'رجل المرور: عمار المصراتي',
      'details': 'رقم اللوحة: 5-184920 (تجاوز السرعة)',
      'time': '2026-10-29 15:30',
    },
    {
      'id': 'LOG-902',
      'action': 'تقديم تظلّم رقمي',
      'user': 'المواطن (بوابة الويب)',
      'details': 'رقم الإشعار: V-2026-101 (خطأ في رصد الموقع)',
      'time': '2026-10-29 16:10',
    },
    {
      'id': 'LOG-903',
      'action': 'إضافة مركبة للقائمة الأمنية',
      'user': 'المشرف الرئيسي',
      'details': 'رقم اللوحة: 3-99211 (حجز إداري)',
      'time': '2026-10-28 10:05',
    },
  ];

  List<Map<String, String>> get _filteredLogs {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _auditLogs;

    return _auditLogs.where((log) {
      return log.values.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = _filteredLogs;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سجل التدقيق والتتبع المركزي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'عرض الحركات المسجلة لضمان الشفافية ومتابعة إجراءات النظام.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ابحث بالإجراء أو المستخدم أو التفاصيل...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'عدد السجلات: ${logs.length}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('لا توجد سجلات مطابقة للبحث'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.history,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            log['action']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${log['id']} • ${log['user']}\n'
                              '${log['details']}\n'
                              '${log['time']}',
                              style: const TextStyle(height: 1.6),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}