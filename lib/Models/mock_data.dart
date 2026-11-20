enum ViolationStatus { unpaid, paid, disputed, pending }

class MockViolation {
  MockViolation({
    required this.id,
    required this.plateNumber,
    required this.violationType,
    required this.amount,
    required this.points,
    required this.date,
    required this.status,
    this.nationalId,
    this.location,
    this.plateImage,
    this.sceneImage,
    this.isWanted = false,
  });

  final String id, plateNumber, violationType;
  final double amount;
  final int points;
  final DateTime date;
  ViolationStatus status; // أزلنا final لتعديل الحالة محلياً
  final String? nationalId, location, plateImage, sceneImage;
  final bool isWanted;
}

final mockViolationsList = <MockViolation>[
  MockViolation(
    id: 'V-2026-101',
    plateNumber: '5-184920',
    nationalId: '119950123456',
    violationType: 'تجاوز السرعة المقررة',
    amount: 150,
    points: 2,
    date: DateTime(2026, 10, 22, 15, 30),
    location: 'طريق الشط - طرابلس',
    status: ViolationStatus.unpaid,
  ),
  MockViolation(
    id: 'V-2026-102',
    plateNumber: '5-184920',
    nationalId: '119950123456',
    violationType: 'استخدام الهاتف أثناء القيادة',
    amount: 100,
    points: 1,
    date: DateTime(2026, 10, 20, 11, 15),
    location: 'طريق السكة - طرابلس',
    status: ViolationStatus.unpaid,
  ),
];