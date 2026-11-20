import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/mock_data.dart';

class ViolationDetailsDialog extends StatefulWidget {
  const ViolationDetailsDialog({super.key, required this.violation});
  
  // تأكد من اسم الكلاس الخاص بالمخالفة في مشروعك (MockViolation أو ViolationModel)
  final MockViolation violation;

  @override
  State<ViolationDetailsDialog> createState() => _ViolationDetailsDialogState();
}

class _ViolationDetailsDialogState extends State<ViolationDetailsDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isRejecting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirmApproval(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم اعتماد المخالفة وتوثيقها في النظام بنجاح')),
    );
  }

  void _confirmRejection(BuildContext context) {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال سبب الرفض أولاً')),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم رفض المخالفة بنجاح. السبب: $reason')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تدقيق تفاصيل المخالفة والصورة'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // محاكاة صورة الأدلة أو الرادار
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'صورة الدليل / الرادار مسجلة',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // تفاصيل المخالفة
              Text('رقم المخالفة: ${widget.violation.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('رقم اللوحة: ${widget.violation.plateNumber}'),
              const SizedBox(height: 6),
              Text('نوع المخالفة: ${widget.violation.violationType}'),
              const SizedBox(height: 6),
              Text('قيمة الغرامة: ${widget.violation.amount} د.ل'),
              const SizedBox(height: 6),
              Text('تاريخ المخالفة: ${widget.violation.date}'),
              const SizedBox(height: 6),
              Text('الموقع: ${widget.violation.location ?? "غير محدد"}'),
              const SizedBox(height: 14),

              // حقل إدخال سبب الرفض يظهر فقط عند النقر على رفض
              if (_isRejecting) ...[
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'سبب الرفض الإلزامي',
                    hintText: 'اكتب سبب رفض المخالفة هنا...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
        if (!_isRejecting) ...[
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() => _isRejecting = true);
            },
            child: const Text('رفض المخالفة'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _confirmApproval(context),
            child: const Text('اعتماد نهائي'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => setState(() => _isRejecting = false),
            child: const Text('رجوع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _confirmRejection(context),
            child: const Text('تأكيد الرفض'),
          ),
        ],
      ],
    );
  }
}