import 'package:flutter/material.dart';
import 'package:traffic_web/core/app_colors.dart';
import 'package:traffic_web/views/admin/dashboard_view.dart';
import 'package:traffic_web/views/web/landing/landing_view.dart';

void main() => runApp(const TrafficApp());

class TrafficApp extends StatelessWidget {
  const TrafficApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'نظام إدارة المعاملات المرورية',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
    ),
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl,
      child: child ?? const SizedBox.shrink(),
    ),
    initialRoute: '/',
    routes: {
      '/': (_) => const LandingView(),
      '/admin-dashboard': (_) => const DashboardView(),
    },
  );
}
