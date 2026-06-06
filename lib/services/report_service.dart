import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UPLOAD: Upload image to Firebase Storage
  Future<String?> uploadReportImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('reports').child(fileName);
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // CREATE: Lapor Barang Hilang
  Future<void> createLostReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String publicDescription,
    required bool hasPrivateDescription,
    required String privateDescription,
    required List<Map<String, String>> secretQuestions,
    String? imageUrl,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      await _firestore.collection('reports').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'itemName': itemName,
        'category': category,
        'dateLost': date,
        'location': location,
        'publicDescription': publicDescription,
        'hasPrivateDescription': hasPrivateDescription,
        'privateDescription': hasPrivateDescription ? privateDescription : '',
        'secretQuestions': secretQuestions,
        'imageUrl': imageUrl,
        'status': 'HILANG',
        'type': 'LOST',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Pemicu Matchmaking
      _checkMatchmaking(itemName, category, 'LOST', currentUser.uid);

    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  // CREATE: Lapor Barang Temuan
  Future<void> createFoundReport({
    required String itemName,
    required String category,
    required String date,
    required String location,
    required String description,
    required String storageStatus,
    String? imageUrl,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login terlebih dahulu.');
      }

      await _firestore.collection('reports').add({
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'itemName': itemName,
        'category': category,
        'dateFound': date,
        'location': location,
        'publicDescription': description,
        'storageStatus': storageStatus,
        'imageUrl': imageUrl,
        'status': 'DITEMUKAN',
        'type': 'FOUND',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Pemicu Matchmaking
      _checkMatchmaking(itemName, category, 'FOUND', currentUser.uid);

    } catch (e) {
      throw Exception('Gagal menyimpan laporan temuan: $e');
    }
  }

  // --- PRIVATE HELPERS ---

  // Logika Matchmaking Otomatis
  Future<void> _checkMatchmaking(String name, String category, String type, String currentUid) async {
    final oppositeType = type == 'LOST' ? 'FOUND' : 'LOST';
    
    // Cari laporan dengan tipe berlawanan dan kategori sama
    final matches = await _firestore.collection('reports')
        .where('type', isEqualTo: oppositeType)
        .where('category', isEqualTo: category)
        .get();

    for (var doc in matches.docs) {
      final matchName = doc['itemName'].toString().toLowerCase();
      final searchName = name.toLowerCase();

      // Cek kemiripan simpel (jika mengandung kata yang sama)
      if (matchName.contains(searchName) || searchName.contains(matchName)) {
        // Kirim notifikasi sistem ke kedua belah pihak
        final otherUid = doc['userId'];
        
        await _firestore.collection('notifications').add({
          'uids': [currentUid, otherUid],
          'title': 'Kecocokan Ditemukan!',
          'message': 'Ada laporan "${doc['itemName']}" yang mungkin cocok dengan barang Anda.',
          'reportId': doc.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // READ: Get single report by ID
  Future<Map<String, dynamic>?> getReportById(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  // READ: Get all reports stream (real-time)
  Stream<QuerySnapshot> getAllReportsStream() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // READ: Search reports by keyword (case-insensitive)
  Stream<QuerySnapshot> searchReportsStream(String keyword) {
    if (keyword.isEmpty) {
      return getAllReportsStream();
    }

    return _firestore
        .collection('reports')
        .where('itemName', isGreaterThanOrEqualTo: keyword)
        .where('itemName', isLessThan: keyword + '\uf8ff')
        .orderBy('itemName')
        .snapshots();
  }

  // READ: Get user's own reports (real-time)
  Stream<QuerySnapshot> getUserReportsStream(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // READ: Get user profile (combine Auth + Firestore user data)
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();

      return {
        'uid': uid,
        'email': user?.email,
        'displayName': user?.displayName ?? user?.email?.split('@')[0] ?? 'Pengguna',
        'photoUrl': user?.photoURL,
        'stats': (data?['stats'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        'phone': data?['phone'] ?? '',
        'address': data?['address'] ?? '',
      };
    } catch (e) {
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  // --- CLAIM & VERIFICATION SYSTEM ---

  // SUBMIT: Penemu mengirim klaim (jawaban pertanyaan rahasia + bukti)
  Future<void> submitClaim({
    required String reportId,
    required String reporterId, // Akun pemilik barang
    required String itemName,
    required List<Map<String, String>> answers, // Jawaban penemu
    String? proofImageUrl,
    String? privateDescription,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Silakan login dahulu');

      await _firestore.collection('claims').add({
        'reportId': reportId,
        'reporterId': reporterId,
        'claimantId': user.uid,
        'claimantEmail': user.email,
        'itemName': itemName,
        'answers': answers,
        'proofImageUrl': proofImageUrl,
        'privateDescription': privateDescription,
        'status': 'PENDING',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim klaim: $e');
    }
  }

  // READ: Dapatkan klaim masuk untuk laporan user tertentu
  Stream<QuerySnapshot> getIncomingClaimsStream(String userId) {
    return _firestore
        .collection('claims')
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE: Pemilik barang menyetujui atau menolak klaim
  Future<void> updateClaimStatus(String claimId, String reportId, String status) async {
    try {
      final batch = _firestore.batch();
      
      // 1. Update status klaim
      final claimRef = _firestore.collection('claims').doc(claimId);
      batch.update(claimRef, {'status': status});

      // 2. Jika disetujui, update status barang
      if (status == 'APPROVED') {
        final reportRef = _firestore.collection('reports').doc(reportId);
        batch.update(reportRef, {'status': 'SELESAI / CLAIMED'});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal memperbarui status: $e');
    }
  }

  // --- ADMIN FEATURES ---

  // READ: Statistik Admin (Live)
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final reports = await _firestore.collection('reports').get();
      final users = await _firestore.collection('users').get();
      final claims = await _firestore.collection('claims').where('status', isEqualTo: 'APPROVED').get();

      return {
        'totalReports': reports.docs.length,
        'totalUsers': users.docs.length,
        'resolvedReports': claims.docs.length,
        'activeLost': reports.docs.where((d) => d['status'] == 'HILANG').length,
      };
    } catch (e) {
      return {
        'totalReports': 0,
        'totalUsers': 0,
        'resolvedReports': 0,
        'activeLost': 0,
      };
    }
  }

  // DELETE: Admin menghapus laporan bermasalah
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus laporan: $e');
    }
  }
}
