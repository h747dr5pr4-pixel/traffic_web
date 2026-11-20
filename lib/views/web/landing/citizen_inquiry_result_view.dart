import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'payment_gateway_view.dart';
import 'submit_dispute_view.dart';
import 'clearance_certificate_view.dart';

class CitizenInquiryResultView extends StatefulWidget {
  const CitizenInquiryResultView({super.key, required this.queryValue});

  final String queryValue;

  @override
  State<CitizenInquiryResultView> createState() => _CitizenInquiryResultViewState();
}

class _CitizenInquiryResultViewState extends State<CitizenInquiryResultView> {
  bool _isLoading = true;
  bool _hasError = false;
  
  // التعريف الصحيح لقائمة المخالفات لمنع خطأ Undefined name
  List<Map<String, dynamic>> _violations = <Map<String, dynamic>>[];
  Map<String, dynamic>? _vehicleInfo;
  bool _isNationalIdSearch = false;

  @override
  void initState() {
    super.initState();
    _fetchInquiryData();
  }

  void _fetchInquiryData() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        final query = widget.queryValue.trim();
        
        _isNationalIdSearch = query.length == 11 && int.tryParse(query) != null;

        if (query == '5-184920' || query == '19901012345') {
          _vehicleInfo = {
            'plateNumber': '5-184920',
            'ownerName': _isNationalIdSearch ? 'محمد أحمد الفيتوري' : 'مواطن (محجوب لحماية الخصوصية)',
            'carModel': 'تويوتا كورولا - بيضاء',
            'status': 'غير بريء الذمة (توجد مخالفات)',
          };
          _violations = [
            {
              'id': 'V-1092',
              'type': 'الإقلاع الخطير / تجاوز السرعة',
              'amount': 150.0,
              'date': '2026/05/10',
              'location': 'طريق الشط - طرابلس',
              'status': 'غير مسددة',
            },
            {
              'id': 'V-1093',
              'type': 'وقوف في ممنوع الوقوف',
              'amount': 100.0,
              'date': '2026/05/12',
              'location': 'طريق السكة - طرابلس',
              'status': 'غير مسددة',
            },
          ];
        } else if (query == 'empty' || query == '0000') {
          _vehicleInfo = {
            'plateNumber': query,
            'ownerName': _isNationalIdSearch ? 'مواطن تجريبي' : 'مواطن (محجوب لحماية الخصوصية)',
            'carModel': 'مركبة عامة',
            'status': 'بريء الذمة (لا توجد مخالفات)',
          };
          _violations = [];
        } else {
          _hasError = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاستعلام المروري (تجريبي)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBodyContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري الاستعلام عن بيانات المركبة والمخالفات من منظومة المرور...', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    if (_hasError) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('عذراً، لم يتم العثور على سجلات مطابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('القيم المدخلة (${widget.queryValue}) غير مسجلة أو صيغة الاستعلام خاطئة.', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: const Text('العودة للخلف'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Text(
              'تنبيه أكاديمي: كافة البيانات والمعروضات أدناه استعراضية تجريبية لغرض مناقشة مشروع التخرج.',
              style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('رقم اللوحة: ${_vehicleInfo!['plateNumber']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Chip(
                        label: Text(_vehicleInfo!['status']),
                        backgroundColor: _violations.isEmpty ? Colors.green.shade100 : Colors.red.shade100,
                        labelStyle: TextStyle(color: _violations.isEmpty ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('مالك المركبة: ${_vehicleInfo!['ownerName']}'),
                  const SizedBox(height: 4),
                  Text('نوع المركبة: ${_vehicleInfo!['carModel']}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_violations.isEmpty) ...[
            Card(
              elevation: 3,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تهانينا! المركبة خالية من أي مخالفات مرورية.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                              SizedBox(height: 4),
                              Text('بإمكانك الآن إصدار شهادة إبراء الذمة الرقمية رسمياً.', style: TextStyle(color: Colors.black87, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClearanceCertificateView(
                                plateNumber: _vehicleInfo!['plateNumber'],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.verified),
                        label: const Text('إصدار شهادة إبراء الذمة الرقمية'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Text('قائمة المخالفات المسجلة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _violations.length,
              itemBuilder: (context, index) {
                final v = _violations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('رقم المخالفة: ${v['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${v['amount']} د.ل', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('نوع المخالفة: ${v['type']}'),
                        Text('الموقع: ${v['location']} | التاريخ: ${v['date']}'),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade800),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubmitDisputeView(
                                      violationId: v['id'],
                                      plateNumber: _vehicleInfo!['plateNumber'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.gavel, size: 16),
                              label: const Text('تقديم تظلم (تجريبي)'),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentGatewayView(
                                      plateNumber: _vehicleInfo!['plateNumber'],
                                      totalAmount: v['amount'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.payment, size: 16),
                              label: const Text('سداد فوري (تجريبي)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}