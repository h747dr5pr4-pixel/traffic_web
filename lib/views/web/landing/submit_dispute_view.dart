import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class SubmitDisputeView extends StatefulWidget {
  const SubmitDisputeView({super.key, required this.violationId, required this.plateNumber});

  final String violationId;
  final String plateNumber;

  @override
  State<SubmitDisputeView> createState() => _SubmitDisputeViewState();
}

class _SubmitDisputeViewState extends State<SubmitDisputeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _attachedFileName; // متغير لمحاكاة مرفق الدليل الاختياري

  @override
  void dispose() {
    _reasonController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _pickAttachment() {
    // محاكاة اختيار ملف صورة للدليل الاختياري
    setState(() {
      _attachedFileName = 'evidence_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرفاق صورة الدليل بنجاح (تجريبي)')),
    );
  }

  void _submitDispute() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // محاكاة إرسال الطلب تجريبياً
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return; // فحص mounted بعد الـ Future.delayed
        
        setState(() => _isSubmitting = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 28),
                SizedBox(width: 8),
                Text('تم تسجيل الطلب تجريبياً'),
              ],
            ),
            content: Text(
              'تم تسجيل طلب التظلم الخاص بالمخالفة رقم: ${widget.violationId} بنجاح في الواجهة التجريبية.\n'
              '${_attachedFileName != null ? "مع مرفق: $_attachedFileName" : "بدون مرفقات"}'
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // إغلاق النافذة
                  Navigator.pop(context); // العودة للخلف
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم اعتراض / تظلّم على مخالفة'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نموذج الطعن المروري الإلكتروني (واجهة تجريبية)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('رقم المخالفة: ${widget.violationId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('رقم اللوحة: ${widget.plateNumber}', style: const TextStyle(color: Colors.grey)),
                      const Divider(height: 30),

                      // سبب التظلم مع تحديد حد أقصى للطول (مثلاً 250 حرفاً)
                      TextFormField(
                        controller: _reasonController,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          labelText: 'سبب الاعتراض بالتفصيل',
                          hintText: 'اكتب سبب التظلم (بحد أقصى 250 حرفاً)...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'الرجاء كتابة سبب التظلم';
                          }
                          if (val.length > 250) {
                            return 'سبب التظلم يجب ألا يتجاوز 250 حرفاً';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // رقم الهاتف للتواصل (متحقق من الرقم الليبي 09xxxxxxxx)
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف للتواصل (مثال: 0912345678)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          // التحقق من أن الرقم يبدأ بـ 09 ويتكون من 10 أرقام (صيغة ليبية قياسية)
                          final libyanPhoneRegex = RegExp(r'^09\d{8}$');
                          if (!libyanPhoneRegex.hasMatch(val.trim())) {
                            return 'رقم الهاتف غير صحيح، يجب أن يكون بصيغة 09xxxxxxxx';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // مرفق دليل اختياري (صورة)
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickAttachment,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('إرفاق دليل (اختياري)'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _attachedFileName ?? 'لم يتم اختيار ملف',
                              style: TextStyle(
                                fontSize: 12,
                                color: _attachedFileName != null ? Colors.green.shade700 : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // تنبيه إرشادي تجريبي
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'ملاحظة: هذه واجهة تجريبية لعرض النموذج وتسجيل البيانات محلياً للاستعراض الأكاديمي.',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // زر الإرسال
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isSubmitting ? null : _submitDispute,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('إرسال التظلم للإدارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}