import '../models/user_model.dart';
import '../models/report_model.dart';

class AppService {
  // Dummy current user
  static final User currentUser = User(
    id: '1',
    name: 'Budi Santoso',
    email: 'budi.santoso@kampus.ac.id',
    phone: '+62812345678',
    address: 'Gedung Balkiromati Lt. 2, Universitas',
    totalReports: 12,
    foundCount: 8,
    claimedCount: 2,
  );

  // Dummy reports data
  static final List<Report> allReports = [
    Report(
      id: '1',
      title: 'Laptop ASUS',
      category: 'Elektronik',
      description: 'Laptop ASUS ROG berwarna hitam dengan stiker gaming',
      location: 'Perpustakaan Pusat',
      dateCreated: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'HILANG',
      userId: '1',
    ),
    Report(
      id: '2',
      title: 'Kunci Motor Honda',
      category: 'Kunci',
      description: 'Kunci motor dengan ring hitam, temuan di parkir teknik',
      location: 'Parkir Teknik',
      dateCreated: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'DITEMUKAN',
      userId: '2',
    ),
    Report(
      id: '3',
      title: 'Dompet Kulit Coklat',
      category: 'Dompet/Tas',
      description: 'Dompet kulit coklat berisi KTM dan kartu kredit',
      location: 'Kantin Utama',
      dateCreated: DateTime.now().subtract(const Duration(days: 1)),
      status: 'HILANG',
      userId: '1',
    ),
  ];

  // Get user reports
  static List<Report> getUserReports(String userId, String type) {
    return allReports
        .where((r) => r.userId == userId && (type == 'semua' || r.status == type))
        .toList();
  }

  // Get report by ID
  static Report? getReportById(String id) {
    try {
      return allReports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search reports
  static List<Report> searchReports(String query) {
    if (query.isEmpty) return allReports;
    return allReports
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()) ||
            r.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get reports by category
  static List<Report> getByCategory(String category) {
    return allReports.where((r) => r.category == category).toList();
  }
}
