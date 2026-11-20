import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class TrafficGuideView extends StatelessWidget {
  const TrafficGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة تجريبية لمخالفات المرور والغرامات بتعريف دقيق
    final List<Map<String, String>> trafficViolationsGuide = [
      {
        'code': 'V-01',
        'title': 'تجاوز الإشارة الحمراء',
        'amount': '200 د.ل',
        'points': '4 نقاط',
        'category': 'خطيرة',
      },
      {
        'code': 'V-02',
        'title': 'القيادة بسرعة مفرطة تجاوز السرعة المحددة',
        'amount': '150 د.ل',
        'points': '3 نقاط',
        'category': 'خطيرة',
      },
      {
        'code': 'V-03',
        'title': 'استخدام الهاتف المحمول أثناء القيادة',
        'amount': '100 د.ل',
        'points': '2 نقاط',
        'category': 'متوسطة',
      },
      {
        'code': 'V-04',
        'title': 'عدم ربط حزام الأمان',
        'amount': '50 د.ل',
        'points': '1 نقطة',
        'category': 'بسيطة',
      },
      {
        'code': 'V-05',
        'title': 'وقوف في الأماكن الممنوعة (في الأماكن المحظورة)',
        'amount': '75 د.ل',
        'points': '1 نقطة',
        'category': 'بسيطة',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل المخالفات المرورية والغرامات (تجريبي)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'دليل تجريبي للمخالفات واللائحة المرورية',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'يستعرض هذا الدليل التجريبي جدول المخالفات المرورية وقيم الغرامات المالية ونقاط السائقين المقررة.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Divider(height: 30),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trafficViolationsGuide.length,
                    itemBuilder: (context, index) {
                      final item = trafficViolationsGuide[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          // استخدام Wrap بدلاً من Row لتفادي تجاوز العرض على الشاشات والهواتف الضيقة
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 10,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                    child: Text(item['code']!, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 300,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text('التصنيف: ${item['category']} | خصم النقاط: ${item['points']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  item['amount']!,
                                  style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}