import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'payment_gateway_view.dart';

class CitizenProfileView extends StatefulWidget {
  const CitizenProfileView({super.key});

  @override
  State<CitizenProfileView> createState() => _CitizenProfileViewState();
}

class _CitizenProfileViewState extends State<CitizenProfileView> {
  final _controller = TextEditingController();
  bool _searched = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // تصحيح نوع القائمة إلى الشكل السليم
  List _citizenVehicles = [];

  @override
  void dispose() {
    _controller.dispose(); // إضافة dispose لتفريغ الذاكرة
    super.dispose();
  }

  void _searchCitizen() {
    final text = _controller.text.trim();
    
    // التحقق من أن الرقم الوطني مكون من 11 رقماً حصراً
    if (text.length != 11 || int.tryParse(text) == null) {
      setState(() {
        _errorMessage = 'الرجاء إدخال رقم وطني صحيح مكون من 11 رقماً';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _searched = true;
        // بيانات تجريبية للمناقشة الأكاديمية
        _citizenVehicles = [
          {'plate': '5-184920', 'model': 'تويوتا كورولا', 'violationsCount': 2, 'totalDue': 250.0},
          {'plate': '3-99211', 'model': 'هيونداي النترا', 'violationsCount': 0, 'totalDue': 0.0},
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي وسجل المركبات (تجريبي)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                // تنبيه أكاديمي بأن النظام تجريبي
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    'تنبيه أكاديمي: استعلام سجل المواطن ومركباته (واجهة تجريبية للمناقشة).',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text('استعلام سجل المواطن ومركباته برقم الوطني', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        decoration: InputDecoration(
                          labelText: 'الرقم الوطني (11 رقماً)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.badge),
                          errorText: _errorMessage,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                      onPressed: _isLoading ? null : _searchCitizen,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('بحث'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (_searched) ...[
                  const Text('المركبات المسجلة باسم المواطن:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ..._citizenVehicles.map((v) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      // استخدام Wrap لتفادي تجاوز العرض على الهواتف والشاشات الصغيرة
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 10,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_car, color: Colors.blueAccent),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('رقم اللوحة: ${v['plate']} (${v['model']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('عدد المخالفات: ${v['violationsCount']} | المترتبات: ${v['totalDue']} د.ل', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          v['totalDue'] > 0
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentGatewayView(
                                          plateNumber: v['plate'],
                                          totalAmount: v['totalDue'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('سداد شامل (تجريبي)'),
                                )
                              : const Chip(label: Text('بريء الذمة', style: TextStyle(color: Colors.green)), backgroundColor: Colors.greenAccent),
                        ],
                      ),
                    ),
                  )),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}