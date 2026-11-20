import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class PaymentGatewayView extends StatefulWidget {
  const PaymentGatewayView({super.key, required this.plateNumber, required this.totalAmount});

  final String plateNumber;
  final double totalAmount;

  @override
  State<PaymentGatewayView> createState() => _PaymentGatewayViewState();
}

class _PaymentGatewayViewState extends State<PaymentGatewayView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      // محاكاة الاتصال ببوابة الدفع المصرفية
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() => _isProcessing = false);
        
        // عرض رسالة نجاح السداد (محاكاة تجريبية)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('نجاح محاكاة السداد التجريبي'),
              ],
            ),
            content: Text('تمت محاكاة سداد مبلغ ${widget.totalAmount} د.ل للمركبة رقم: ${widget.plateNumber} بنجاح (عملية تجريبية للمناقشة الأكاديمية).'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // إغلاق النافذة
                  Navigator.pop(context); // العودة لصفحة النتائج
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
        title: const Text('بوابة السداد الإلكتروني الآمن (تجريبي)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                      // تنبيه واضح للمناقشة أن البوابة تجريبية
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'هذه البوابة تجريبية للاستعراض الأكاديمي، ولا يتم فيها سداد مبالغ حقيقية.',
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'تفاصيل الدفع للغرامات المرورية',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('رقم اللوحة: ${widget.plateNumber}', style: const TextStyle(color: Colors.grey)),
                      Text('إجمالي المبلغ المطلوب: ${widget.totalAmount} د.ل', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const Divider(height: 30),

                      // رقم البطاقة (بيانات وهمية للاختبار)
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'رقم البطاقة المصرفية (تجارية)',
                          hintText: '4532 •••• •••• 8821',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.length < 16 ? 'أدخل 16 رقماً وهمياً صحيحاً' : null,
                      ),
                      const SizedBox(height: 16),

                      // اسم حامل البطاقة
                      TextFormField(
                        controller: _cardHolderController,
                        decoration: const InputDecoration(
                          labelText: 'اسم حامل البطاقة',
                          hintText: 'محمد أحمد',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
                      ),
                      const SizedBox(height: 16),

                      // تاريخ الانتهاء و الـ CVV مع التحقق من الصيغة
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'تاريخ الانتهاء',
                                hintText: '12/28',
                                prefixIcon: Icon(Icons.date_range),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(val)) {
                                  return 'صيغة خاطئة (استخدم MM/YY)';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '382',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: (val) => val == null || val.length < 3 ? 'أدخل 3 أرقام' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // زر تأكيد السداد
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isProcessing ? null : _processPayment,
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text('إتمام السداد التجريبي (${widget.totalAmount} د.ل)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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