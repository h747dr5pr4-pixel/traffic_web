import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class DisputesView extends StatefulWidget {
  const DisputesView({super.key});

  @override
  State<DisputesView> createState() => _DisputesViewState();
}

class _DisputesViewState extends State<DisputesView> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _disputes = [
    {
      'id': 'DISP-101',
      'violationId': 'V-2026-101',
      'citizen': 'محمد أحمد الفيتوري',
      'plate': '5-184920',
      'reason': 'خطأ في رصد الجهاز الآلي للسرعة، كنت ملتزماً بالسرعة المحددة.',
      'status': 'قيد المراجعة',
      'date': '2026-10-29 16:10',
    },
    {
      'id': 'DISP-102',
      'violationId': 'V-2026-105',
      'citizen': 'علي سالم الزروق',
      'plate': '3-99211',
      'reason': 'السيارة كانت معطلة وتم قطرها بشاحنة نقل.',
      'status': 'قيد المراجعة',
      'date': '2026-10-28 11:20',
    },
  ];

  List<Map<String, String>> get _filteredDisputes {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return _disputes;

    return _disputes.where((item) {
      return item.values.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _confirmDecision(
    Map<String, String> item,
    String newStatus,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$newStatus التظلّم؟'),
        content: Text('هل أنت متأكد من قرارك بشأن ${item['id']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => item['status'] = newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث حالة التظلّم إلى: $newStatus'),
        backgroundColor:
            newStatus == 'مقبول' ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disputes = _filteredDisputes;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gavel_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'إدارة التظلّمات والاعتراضات المرورية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'راجع الطلبات واتخذ قرار القبول أو الرفض.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ابحث برقم التظلّم أو اللوحة أو اسم المواطن...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'عدد الطلبات: ${disputes.length}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: disputes.isEmpty
                ? const Center(child: Text('لا توجد تظلّمات مطابقة'))
                : ListView.builder(
                    itemCount: disputes.length,
                    itemBuilder: (context, index) {
                      final item = disputes[index];
                      final status = item['status']!;
                      final isPending = status == 'قيد المراجعة';
                      final statusColor = status == 'مقبول'
                          ? AppColors.success
                          : status == 'مرفوض'
                              ? AppColors.danger
                              : AppColors.warning;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['id']} — إشعار ${item['violationId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor:
                                        statusColor.withValues(alpha: 0.12),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(
                                'المواطن: ${item['citizen']}  |  اللوحة: ${item['plate']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'سبب التظلّم: ${item['reason']}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'تاريخ التقديم: ${item['date']}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (isPending) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _confirmDecision(
                                        item,
                                        'مرفوض',
                                      ),
                                      icon: const Icon(Icons.close),
                                      label: const Text('رفض'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                      ),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () => _confirmDecision(
                                        item,
                                        'مقبول',
                                      ),
                                      icon: const Icon(Icons.check),
                                      label: const Text('قبول'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
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