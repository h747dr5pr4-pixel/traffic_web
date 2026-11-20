import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import 'citizen_inquiry_result_view.dart';
import 'citizen_profile_view.dart';
import 'traffic_guide_view.dart';
import 'verify_certificate_view.dart'; // استيراد صفحة التحقق من الشهادة
import '../../admin/admin_login_view.dart'; // استيراد صفحة تسجيل دخول الإدارة

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0; // 0: برقم اللوحة، 1: بالرقم الوطني

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // لون خلفية ملكي داكن
      body: Stack(
        children: [
          // 1. مؤشر الاتصال الآمن في الزاوية العلوية اليسرى
          Positioned(
            top: 20,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                  SizedBox(width: 8),
                  Text(
                    'النظام الآمن متصل',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // أزرار الزاوية العلوية اليمنى (دخول الإدارة + الملف الشخصي للمواطن) - تستخدم Wrap لتتراص على الهاتف
          Positioned(
            top: 20,
            right: 24,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 4,
                children: [
                  // زر الملف الشخصي وسجل المركبات
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CitizenProfileView()),
                      );
                    },
                    icon: const Icon(Icons.person, color: Colors.white70, size: 18),
                    label: const Text(
                      'الملف الشخصي',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  // زر دخول الإدارة (يوجه إلى صفحة تسجيل الدخول)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminLoginView()),
                      );
                    },
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white70,
                      size: 18,
                    ),
                    label: const Text(
                      'دخول الإدارة',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24), // مسافة علوية كافية لعدم تداخل الأزرار المطلقة على الشاشات الصغيرة
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2. الشعار الرسمي (صورة)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/Logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.account_balance,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // عنوان المنظومة
                    const Text(
                      'منظومة إدارة المعاملات المرورية للمركبات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'البوابة الإلكترونية الموحدة لخدمات المركبات والمخالفات المرورية (تجريبي)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // 3. الشريط الإعلاني والتنبيه الحكومي (Ticker)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: Colors.amberAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'تنويه: تم إطلاق خدمة إصدار شهادات إبراء الذمة رقمياً للمركبات المبرأة من المخالفات.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // صندوق البحث والاستعلام الرئيسي
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // تبديل طرق الاستعلام
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 300,
                                child: ChoiceChip(
                                  label: const Center(
                                    child: Text('استعلام برقم اللوحة'),
                                  ),
                                  selected: _selectedTab == 0,
                                  onSelected: (val) =>
                                      setState(() => _selectedTab = 0),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _selectedTab == 0
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 300,
                                child: ChoiceChip(
                                  label: const Center(
                                    child: Text('استعلام بالرقم الوطني'),
                                  ),
                                  selected: _selectedTab == 1,
                                  onSelected: (val) =>
                                      setState(() => _selectedTab = 1),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _selectedTab == 1
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // حقل الإدخال
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: _selectedTab == 0
                                  ? 'أدخل رقم اللوحة (مثال: 5-184920)'
                                  : 'أدخل الرقم الوطني للمواطن (11 رقماً)',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // زر الاستعلام (يوجه كلاهما إلى صفحة نتائج الاستعلام الشاملة)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final query = _searchController.text.trim();
                                if (query.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'الرجاء إدخال البيانات المطلوبة للبحث',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CitizenInquiryResultView(
                                      queryValue: query,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text(
                                'استعلام فوري (تجريبي)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. قسم الخدمات السريعة (مربوط بالصفحات الحقيقية)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _buildQuickServiceCard(
                            context,
                            icon: Icons.menu_book,
                            title: 'دليل المخالفات',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TrafficGuideView(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: _buildQuickServiceCard(
                            context,
                            icon: Icons.person_search,
                            title: 'سجل المركبات',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CitizenProfileView(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: _buildQuickServiceCard(
                            context,
                            icon: Icons.verified_user,
                            title: 'التحقق من شهادة',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VerifyCertificateView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // الفوتر
                    const Text(
                      'منظومة إدارة المعاملات المرورية للمركبات',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'جميع الحقوق محفوظة © 2026 • الدعم الفني والخصوصية',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amberAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}