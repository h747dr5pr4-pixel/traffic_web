import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../models/mock_data.dart';

class ClearanceCertificateView extends StatefulWidget {
  final String plateNumber;

  const ClearanceCertificateView({super.key, required this.plateNumber});

  @override
  State<ClearanceCertificateView> createState() =>
      _ClearanceCertificateViewState();
}

class _ClearanceCertificateViewState extends State<ClearanceCertificateView> {
  final GlobalKey _certificateKey = GlobalKey();
  bool _isExporting = false;

  late final DateTime _issuedAt;
  late final String _issueDate;
  late final String _reference;

  @override
  void initState() {
    super.initState();
    _issuedAt = DateTime.now();
    _issueDate = _issuedAt
        .toIso8601String()
        .substring(0, 16)
        .replaceFirst('T', ' ');
    final plateDigits = widget.plateNumber.replaceAll(RegExp(r'[^0-9]'), '');
    _reference =
        'TRF-CERT-${plateDigits.isEmpty ? "000" : plateDigits}-${_issuedAt.year}';
  }

  Future<void> _exportPdf() async {
    final boundary =
        _certificateKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;

    if (boundary == null || _isExporting) return;

    setState(() => _isExporting = true);

    try {
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (data == null) throw Exception('تعذر تجهيز صورة الشهادة');

      final pdfBytes = data.buffer.asUint8List();
      final document = pw.Document();

      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Center(
            child: pw.Image(pw.MemoryImage(pdfBytes), fit: pw.BoxFit.contain),
          ),
        ),
      );

      await Printing.layoutPdf(
        name: 'traffic_certificate_$_reference.pdf',
        onLayout: (_) => document.save(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إنشاء ملف PDF. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // التعديل هنا: منع الإصدار في حال وجود مخالفة غير مسددة أو تظلّم معلق قيد المراجعة
    final hasActiveViolations = mockViolationsList.any(
      (v) =>
          v.plateNumber.trim().toLowerCase() ==
              widget.plateNumber.trim().toLowerCase() &&
          (v.status == ViolationStatus.unpaid ||
              v.status == ViolationStatus.disputed),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('شهادة إبراء ذمة مرورية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: hasActiveViolations
                ? _buildBlockedMessage()
                : Column(
                    children: [
                      RepaintBoundary(
                        key: _certificateKey,
                        child: _buildCertificate(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportPdf,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _isExporting
                                ? 'جارٍ تجهيز الشهادة...'
                                : 'طباعة أو حفظ PDF',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedMessage() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 56, color: AppColors.danger),
            const SizedBox(height: 14),
            const Text(
              'لا يمكن إصدار الشهادة حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'توجد مخالفات غير مسددة أو تظلّمات قيد المراجعة مسجلة على هذه المركبة.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('رجوع'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificate() {
    final qrData = 'DEMO|$_reference|${widget.plateNumber}|$_issueDate';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Text(
              'تنبيه: وثيقة تجريبية لمشروع التخرج — غير رسمية وغير معتمدة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'جامعة الرفاق الأهلية',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'مشروع نظام إدارة المعاملات المرورية',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          const Center(
            child: Text(
              'شهادة إبراء ذمة مرورية رقمية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'تفيد بيانات النظام التجريبي بعدم وجود مخالفات مالية غير مسددة '
            'أو تظلّمات معلقة على المركبة الموضحة بياناتها أدناه حتى تاريخ إصدار هذه الوثيقة.',
            style: TextStyle(height: 1.5, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _certRow('رقم اللوحة:', widget.plateNumber),
          _certRow('الرقم المرجعي:', _reference),
          _certRow('تاريخ الإصدار:', _issueDate),
          _certRow('الحالة:', 'سجل خالٍ من الغرامات والتظلمات المعلقة'),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'رمز التحقق الرقمي (QR)\n$_reference',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 82,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
