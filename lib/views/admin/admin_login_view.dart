import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
// استيراد شاشات لوحات التحكم الخاصة بالأدوار (تأكد من مساراتها في مشروعك)
// import '../admin/audit_log_view.dart';
// import '../admin/disputes_view.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // محاكاة الاتصال بنظام المصادقة التجريبي
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() => _isLoading = false);

        final username = _usernameController.text.trim().toLowerCase();
        final password = _passwordController.text.trim();

        // بيانات تجريبية للاختبار والمناقشة
        if (password == '123456') {
          String assignedRole = '';
          Widget targetScreen;

          if (username == 'admin') {
            assignedRole = 'مدير النظام (Admin)';
            // targetScreen = const DashboardView(); // استبدلها بشاشة مدير النظام الفعلية
            targetScreen = const _PlaceholderDashboard(
              title: 'لوحة تحكم مدير النظام',
            );
          } else if (username == 'officer') {
            assignedRole = 'ضابط مرور ميداني (Officer)';
            targetScreen = const _PlaceholderDashboard(
              title: 'لوحة ضابط المرور الميداني',
            );
          } else if (username == 'finance') {
            assignedRole = 'موظف الشؤون المالية (Finance)';
            targetScreen = const _PlaceholderDashboard(
              title: 'لوحة الشؤون المالية والسداد',
            );
          } else if (username == 'disputes') {
            assignedRole = 'موظف فض المنازعات (Disputes)';
            targetScreen = const _PlaceholderDashboard(
              title: 'لوحة إدارة وتدقيق التظلمات',
            );
          } else {
            setState(() {
              _errorMessage =
                  'اسم المستخدم غير مسجل. جرب: admin, officer, finance, disputes';
            });
            return;
          }

          // رسالة نجاح وتوجيه فعلي للوحة المناسبة
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تسجيل الدخول بنجاح. الصلاحية المحددة: $assignedRole',
              ),
            ),
          );

          // الانتقال للوحة المخصصة مع إزالة شاشة تسجيل الدخول من المكدس
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => targetScreen),
          );
        } else {
          setState(() {
            _errorMessage = 'كلمة المرور غير صحيحة (استخدم: 123456 للتجربة)';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // خلفية داكنة للأنظمة الأمنية
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الشعار والأيقونة
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                size: 48,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'بوابة إدارة المرور الأمنية',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'تسجيل دخول الموظفين (واجهة تجريبية)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 40),

                      // تنبيه تجريبي يوضح الحسابات الافتراضية للمناقشة
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Text(
                          'للتجربة: استخدم (admin, officer, finance, disputes) وكلمة المرور: 123456',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // عرض رسالة الخطأ إن وجدت
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // اسم المستخدم / المعرف الوظيفي
                      const Text(
                        'اسم المستخدم أو المعرف الوظيفي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'admin / officer / finance / disputes',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'الحقل مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // كلمة المرور
                      const Text(
                        'كلمة المرور',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (val) => val == null || val.length < 4
                            ? 'كلمة المرور قصيرة جداً'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // زر تسجيل الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'تسجيل الدخول للنظام',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

// شاشة مؤقتة للتوجه إليها عند نجاح الدخول (يمكنك استبدالها بشاشاتك الفعلية)
class _PlaceholderDashboard extends StatelessWidget {
  const _PlaceholderDashboard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard_customize,
              size: 64,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'تم تسجيل الدخول بنجاح والتوجه للوحة المخصصة (واجهة تجريبية).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}
