import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/mock_data.dart';
import 'violations_table.dart';
import 'disputes_view.dart';
import 'watchlist_view.dart';
import 'audit_log_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _adminPages = const [
    DashboardOverviewTab(),
    ViolationsTable(),
    DisputesView(),
    WatchlistView(),
    AuditLogView(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;

        if (isSmallScreen) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: _adminPages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
                NavigationDestination(icon: Icon(Icons.table_chart_outlined), selectedIcon: Icon(Icons.table_chart), label: 'المخالفات'),
                NavigationDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: 'التظلمات'),
                NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning_amber), label: 'القائمة الأمنية'),
                NavigationDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: 'التدقيق'),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: Colors.white,
                elevation: 2,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: const IconThemeData(color: AppColors.primary),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('الرئيسية والإحصائيات')),
                  NavigationRailDestination(icon: Icon(Icons.table_chart_outlined), selectedIcon: Icon(Icons.table_chart), label: Text('إدارة المخالفات')),
                  NavigationRailDestination(icon: Icon(Icons.gavel_outlined), selectedIcon: Icon(Icons.gavel), label: Text('التظلمات والاعتراضات')),
                  NavigationRailDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning_amber), label: Text('القائمة الأمنية')),
                  NavigationRailDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: Text('سجل التدقيق')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _adminPages[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

class DashboardOverviewTab extends StatefulWidget {
  const DashboardOverviewTab({super.key});

  @override
  State<DashboardOverviewTab> createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  @override
  Widget build(BuildContext context) {
    final violations = mockViolationsList;
    final now = DateTime.now();

    final todayCount = violations.where((v) {
      final date = DateTime.tryParse(v.date.toString());
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;

    final unpaidViolations = violations.where((v) => v.status == ViolationStatus.unpaid).toList();
    final unpaidTotal = unpaidViolations.fold<double>(0, (sum, v) => sum + v.amount);
    final disputedCount = violations.where((v) => v.status == ViolationStatus.disputed).length;
    final paidCount = violations.where((v) => v.status == ViolationStatus.paid).length;
    final wantedCount = violations.where((v) => v.isWanted).map((v) => v.plateNumber).toSet().length;

    // حساب أكثر المواقع تسجيلاً للمخالفات
    final hotspots = <String, int>{};
    for (final v in violations) {
      final loc = v.location?.trim();
      if (loc != null && loc.isNotEmpty) {
        hotspots[loc] = (hotspots[loc] ?? 0) + 1;
      }
    }
    final sortedHotspots = hotspots.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تنبيه بأن الأرقام تجريبية
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تنبيه: كافة الإحصائيات والأرقام المعروضة في لوحة التحكم تجريبية وتتحدث تلقائياً بناءً على التفاعلات.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'لوحة تحكم الإدارة المركزية للمرور',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 5),
          const Text('ملخص المخالفات والتظلمات والمركبات الأمنية.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 26),

          // استخدام LayoutBuilder و Wrap لضمان عدم تجاوز الشاشات الصغيرة والتجاوب التام
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth >= 1000
                  ? (constraints.maxWidth - 48) / 4
                  : constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth > 0 ? cardWidth : 250,
                    child: _StatCard(title: 'مخالفات اليوم', value: '$todayCount', icon: Icons.receipt_long, color: Colors.blue),
                  ),
                  SizedBox(
                    width: cardWidth > 0 ? cardWidth : 250,
                    child: _StatCard(title: 'الغرامات غير المسددة', value: '${unpaidTotal.toStringAsFixed(0)} د.ل', icon: Icons.warning_amber, color: Colors.orange),
                  ),
                  SizedBox(
                    width: cardWidth > 0 ? cardWidth : 250,
                    child: _StatCard(title: 'التظلمات قيد المراجعة', value: '$disputedCount', icon: Icons.gavel, color: Colors.purple),
                  ),
                  SizedBox(
                    width: cardWidth > 0 ? cardWidth : 250,
                    child: _StatCard(title: 'مركبات بالقائمة الأمنية', value: '$wantedCount', icon: Icons.security, color: AppColors.danger),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),
          const Text('توزيع حالات المخالفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _StatusChart(paid: paidCount, unpaid: unpaidViolations.length, disputed: disputedCount),

          const SizedBox(height: 28),
          const Text('أكثر المواقع تسجيلاً للمخالفات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _HotspotsCard(hotspots: sortedHotspots),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChart extends StatelessWidget {
  const _StatusChart({required this.paid, required this.unpaid, required this.disputed});
  final int paid;
  final int unpaid;
  final int disputed;

  @override
  Widget build(BuildContext context) {
    final total = paid + unpaid + disputed;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: total == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'لا توجد بيانات كافية لعرض الرسم البياني حالياً.',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Column(
              children: [
                _bar('مسددة', paid, total, AppColors.success),
                const SizedBox(height: 12),
                _bar('غير مسددة', unpaid, total, AppColors.danger),
                const SizedBox(height: 12),
                _bar('قيد التظلّم', disputed, total, AppColors.warning),
              ],
            ),
    );
  }

  Widget _bar(String label, int count, int total, Color color) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : count / total,
            minHeight: 10,
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 30, child: Text('$count')),
      ],
    );
  }
}

class _HotspotsCard extends StatelessWidget {
  const _HotspotsCard({required this.hotspots});
  final List<MapEntry<String, int>> hotspots;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: hotspots.isEmpty
          ? const Text(
              'لا توجد مواقع مسجلة في البيانات التجريبية.',
              style: TextStyle(color: Colors.grey),
            )
          : Column(
              children: hotspots.take(5).map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(entry.key),
                  trailing: Chip(label: Text('${entry.value} مخالفة')),
                );
              }).toList(),
            ),
    );
  }
}