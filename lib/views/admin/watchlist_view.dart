import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class WatchlistView extends StatefulWidget {
  const WatchlistView({super.key});

  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  final List<Map<String, String>> _watchlist = [
    {'plate': '5-184920', 'reason': 'مركبة مطلوبة أمنياً', 'status': 'مبلغ عنها'},
    {'plate': '3-99211', 'reason': 'انتهاء رخصة السير', 'status': 'حجز إداري'},
  ];
  
  List<Map<String, String>> _filteredWatchlist = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredWatchlist = _watchlist;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredWatchlist = _watchlist
          .where((item) => item['plate']!.contains(query) || item['reason']!.contains(query))
          .toList();
    });
  }

  void _showAddVehicleDialog() {
    final plateController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مركبة للقائمة الأمنية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'رقم اللوحة (إلزامي)',
                hintText: 'مثال: 5-184920',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإدراج / البلاغ (إلزامي)',
                hintText: 'مثال: مركبة مشبوهة / بلاغ سرقة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final plate = plateController.text.trim();
              final reason = reasonController.text.trim();

              if (plate.isEmpty || reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الرجاء تعبئة رقم اللوحة وسبب الإدراج'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }

              // التحقق من عدم تكرار رقم اللوحة
              final exists = _watchlist.any((item) => item['plate'] == plate);
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('رقم اللوحة مسجل مسبقاً في القائمة الأمنية!'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              setState(() {
                _watchlist.add({
                  'plate': plate,
                  'reason': reason,
                  'status': 'نشط',
                });
                // إعادة تطبيق البحث الحالي بدلاً من تصفيره
                _filterSearch(_searchController.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(Map<String, String> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من إزالة المركبة (${item['plate']}) من القائمة الأمنية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                _watchlist.remove(item);
                // إعادة تطبيق البحث الحالي للحفاظ على نتائج الفلترة
                _filterSearch(_searchController.text);
              });
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // استخدام Wrap لتفادي تجاوز العرض على الشاشات الصغيرة
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text(
                'إدارة القائمة الأمنية للمركبات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: _showAddVehicleDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مركبة للقائمة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _filterSearch,
            decoration: InputDecoration(
              hintText: 'ابحث برقم اللوحة أو سبب البلاغ...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredWatchlist.isEmpty
                ? const Center(child: Text('لا توجد نتائج مطابقة'))
                : ListView.builder(
                    itemCount: _filteredWatchlist.length,
                    itemBuilder: (context, index) {
                      final item = _filteredWatchlist[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.danger,
                            child: Icon(Icons.warning_amber, color: Colors.white),
                          ),
                          title: Text('رقم اللوحة: ${item['plate']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('السبب: ${item['reason']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(item['status']!, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                backgroundColor: AppColors.danger,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmRemove(item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}