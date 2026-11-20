import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/app_colors.dart';

class VerifyCertificateView extends StatefulWidget {
  const VerifyCertificateView({super.key});

  @override
  State<VerifyCertificateView> createState() => _VerifyCertificateViewState();
}

class _VerifyCertificateViewState extends State<VerifyCertificateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _certNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool? _isVerified;
  Map<String, dynamic>? _certDetails;

  // قائمة أرقام الشهادات التجريبية المحددة مسبقاً
  final Map<String, Map<String, dynamic>> _mockDatabase = {
    'CERT-101': {
      'certNumber': 'CERT-101',
      'plateNumber': '5-184920',
      'ownerName': 'مـ. أ. الفيتوري', // عرض جزئي للاسم
      'issueDate': '2026/06/01',
      'expiryDate': '2026/12/01',
      'status': 'سارية (نتيجة تجريبية)',
    },
    'CERT-202': {
      'certNumber': 'CERT-202',
      'plateNumber': '3-44129',
      'ownerName': 'ع. م. الطاهر',
      'issueDate': '2026/05/15',
      'expiryDate': '2026/11/15',
      'status': 'سارية (نتيجة تجريبية)',
    },
  };

  @override
  void dispose() {
    _certNumberController.dispose();
    super.dispose();
  }

  void _verifyCertificate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _isVerified = null;
        _certDetails = null;
      });

      // محاكاة الاتصال بالنظام
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          final code = _certNumberController.text.trim().toUpperCase();
          
          // التحقق حصراً من الأرقام التجريبية المحددة (لا تقبل أي 6 خانات عشوائية)
          if (_mockDatabase.containsKey(code)) {
            _isVerified = true;
            _certDetails = _mockDatabase[code];
          } else {
            _isVerified = false;
          }
        });
      });
    }
  }

  // فتح نافذة مسح الرمز الفعلي عبر الكاميرا
  void _openQRScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح رمز الاستجابة السريع (QR)'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    _certNumberController.text = barcode.rawValue!;
                  });
                  Navigator.pop(context); // إغلاق الماسح بعد القراءة
                  _verifyCertificate(); // التشغيل التلقائي للتحقق
                  break;
                }
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق الإلكتروني من شهادة إبراء الذمة'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                      const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.blue, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'بوابة التحقق من صحة الشهادات المرورية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أدخل رقم الشهادة التجريبي (مثل CERT-101) أو امسح رمز الاستجابة السريع (QR Code).',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const Divider(height: 30),

                      // حقل إدخال رقم الشهادة مع زر الماسح الفعلي
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _certNumberController,
                              decoration: InputDecoration(
                                labelText: 'رقم الشهادة الرقمي (مثال: CERT-101)',
                                prefixIcon: const Icon(Icons.qr_code),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'الرجاء إدخال رقم الشهادة للتحقق' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () => _openQRScanner(context),
                            icon: const Icon(Icons.camera_alt, size: 28),
                            color: AppColors.primary,
                            tooltip: 'فتح الماسح الفعلي',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // زر التحقق
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : _verifyCertificate,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('تحقق من الصلاحية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // عرض نتيجة التحقق
                      if (_isVerified != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isVerified! ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isVerified! ? Colors.green.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: _isVerified!
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                                        SizedBox(width: 8),
                                        Text(
                                          'نتيجة تجريبية: الشهادة صالحة ومسجلة',
                                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Text('رقم الشهادة: ${_certDetails!['certNumber']}'),
                                    const SizedBox(height: 4),
                                    Text('رقم اللوحة: ${_certDetails!['plateNumber']}'),
                                    const SizedBox(height: 4),
                                    Text('اسم المالك: ${_certDetails!['ownerName']} (مخفي جزئياً للخصوصية)'),
                                    const SizedBox(height: 4),
                                    Text('تاريخ الإصدار: ${_certDetails!['issueDate']}'),
                                    const SizedBox(height: 4),
                                    Text('تاريخ الانتهاء: ${_certDetails!['expiryDate']}'),
                                    const SizedBox(height: 4),
                                    Text('الحالة: ${_certDetails!['status']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                )
                              : const Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red, size: 24),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'عذراً، رقم الشهادة التجريبي غير صحيح أو غير مسجل (جرب استخدام CERT-101).',
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
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