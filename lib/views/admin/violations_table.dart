import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/mock_data.dart';
import '../web/landing/violation_details_view.dart';

class ViolationsTable extends StatefulWidget {
  const ViolationsTable({super.key});

  @override
  State<ViolationsTable> createState() => _ViolationsTableState();
}

class _ViolationsTableState extends State<ViolationsTable> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'الكل';
  int _currentPage = 0;
  static const int _rowsPerPage = 5;

  List<MockViolation> get _filteredViolations {
    final query = _searchController.text.trim().toLowerCase();

    return mockViolationsList.where((violation) {
      final matchesQuery = query.isEmpty ||
          violation.plateNumber.toLowerCase().contains(query) ||
          violation.violationType.toLowerCase().contains(query) ||
          (violation.nationalId?.toLowerCase().contains(query) ?? false);

      final matchesFilter = switch (_selectedFilter) {
        'غير مسددة' => violation.status == ViolationStatus.unpaid,
        'مسددة' => violation.status == ViolationStatus.paid,
        'قيد التظلّم' => violation.status == ViolationStatus.disputed,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  String _statusLabel(ViolationStatus status) {
    if (status == ViolationStatus.paid) return 'مسددة';
    if (status == ViolationStatus.disputed) return 'قيد التظلّم';
    return 'غير مسددة';
  }

  Color _statusColor(ViolationStatus status) {
    if (status == ViolationStatus.paid) return AppColors.success;
    if (status == ViolationStatus.disputed) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final violations = _filteredViolations;
    final totalPages =
        violations.isEmpty ? 1 : (violations.length / _rowsPerPage).ceil();
    final pageIndex = _currentPage.clamp(0, totalPages - 1).toInt();

    final pageItems = violations
        .skip(pageIndex * _rowsPerPage)
        .take(_rowsPerPage)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة ومتابعة المخالفات المرورية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final searchWidth =
                  constraints.maxWidth < 320 ? constraints.maxWidth : 300.0;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: searchWidth,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() => _currentPage = 0),
                      decoration: InputDecoration(
                        hintText: 'ابحث برقم اللوحة أو المخالفة...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        isDense: true,
                      ),
                    ),
                  ),
                  ...['الكل', 'غير مسددة', 'مسددة', 'قيد التظلّم'].map(
                    (filter) {
                      final selected = _selectedFilter == filter;

                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : Colors.black87,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                            _currentPage = 0;
                          });
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          Expanded(
            child: pageItems.isEmpty
                ? const Center(
                    child: Text('لا توجد مخالفات مطابقة للبحث أو التصفية'),
                  )
                : ListView.builder(
                    itemCount: pageItems.length,
                    itemBuilder: (context, index) {
                      final violation = pageItems[index];
                      final color = _statusColor(violation.status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () {
  showDialog(
    context: context,
     builder: (context) => ViolationDetailsDialog(
      violation: violation,
    ),
  );
},
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(
                              violation.status == ViolationStatus.paid
                                  ? Icons.check
                                  : violation.status ==
                                          ViolationStatus.disputed
                                      ? Icons.hourglass_top
                                      : Icons.warning_amber,
                              color: color,
                            ),
                          ),
                          title: Text(
                            '${violation.plateNumber} — ${violation.violationType}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'الغرامة: ${violation.amount} د.ل'
                            '  •  ${violation.location ?? 'الموقع غير محدد'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Chip(
                            label: Text(
                              _statusLabel(violation.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            backgroundColor: color,
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'صفحة ${pageIndex + 1} من $totalPages'
                  ' • النتائج: ${violations.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              OutlinedButton(
                onPressed: pageIndex > 0
                    ? () => setState(() => _currentPage = pageIndex - 1)
                    : null,
                child: const Text('السابق'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: pageIndex < totalPages - 1
                    ? () => setState(() => _currentPage = pageIndex + 1)
                    : null,
                child: const Text('التالي'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}