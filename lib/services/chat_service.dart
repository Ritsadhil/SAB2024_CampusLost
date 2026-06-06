import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan daftar percakapan user saat ini
  Stream<QuerySnapshot> getConversationsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // Mendapatkan stream pesan dalam sebuah chat room
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Menandai chat sebagai sudah dibaca
  Future<void> markAsRead(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadBy': FieldValue.arrayRemove([uid])
    });
  }

  // Mendapatkan jumlah chat yang belum dibaca
  Stream<int> getUnreadCountStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _firestore
        .collection('chats')
        .where('unreadBy', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mengirim pesan
  Future<void> sendMessage(String chatId, String text) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || text.trim().isEmpty) return;

    // Ambil data chat untuk mengetahui siapa yang harus ditandai unread
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final List participants = chatDoc.data()?['participants'] ?? [];
    
    // Semua participant kecuali pengirim dianggap belum baca
    final unreadBy = participants.where((p) => p != uid).toList();

    final batch = _firestore.batch();
    
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    
    final timestamp = FieldValue.serverTimestamp();

    batch.set(messageRef, {
      'senderId': uid,
      'text': text.trim(),
      'createdAt': timestamp,
    });

    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': text.trim(),
      'lastMessageAt': timestamp,
      'lastSenderId': uid,
      'unreadBy': FieldValue.arrayUnion(unreadBy),
      'updatedAt': timestamp,
    });

    await batch.commit();
  }

  // Membuat atau mendapatkan chat room
  Future<String> getOrCreateChatRoom(String reportId, String reporterId, String reporterName, String itemName) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) throw Exception('User not logged in');

    final existingChat = await _firestore
        .collection('chats')
        .where('reportId', isEqualTo: reportId)
        .where('participants', arrayContains: currentUid)
        .get();

    for (var doc in existingChat.docs) {
      List participants = doc['participants'];
      if (participants.contains(reporterId)) {
        return doc.id;
      }
    }

    final newChatRef = _firestore.collection('chats').doc();
    final timestamp = FieldValue.serverTimestamp();
    
    await newChatRef.set({
      'reportId': reportId,
      'itemName': itemName,
      'participants': [currentUid, reporterId],
      'participantNames': {
        currentUid: _auth.currentUser?.displayName ?? 'User',
        reporterId: reporterName,
      },
      'lastMessage': '',
      'lastMessageAt': timestamp,
      'createdAt': timestamp,
      'unreadBy': [],
    });

    return newChatRef.id;
  }

  // Khusus untuk bantuan admin
  Future<String> getOrCreateAdminChat() async {
    const adminId = 'admin_support_system';
    const adminName = 'Admin CampusLost';
    return await getOrCreateChatRoom('SUPPORT', adminId, adminName, 'Bantuan Teknis');
  }
}
