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

  // Mengirim pesan
  Future<void> sendMessage(String chatId, String text) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || text.trim().isEmpty) return;

    final batch = _firestore.batch();
    
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    
    batch.set(messageRef, {
      'senderId': uid,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': uid,
    });

    await batch.commit();
  }

  // Membuat atau mendapatkan chat room
  Future<String> getOrCreateChatRoom(String reportId, String reporterId, String reporterName, String itemName) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) throw Exception('User not logged in');

    // Cek apakah chat sudah ada
    final existingChat = await _firestore
        .collection('chats')
        .where('reportId', isEqualTo: reportId)
        .where('participants', arrayContains: currentUid)
        .get();

    // Filter manual untuk memastikan kedua partisipan ada (karena array-contains hanya bisa satu)
    for (var doc in existingChat.docs) {
      List participants = doc['participants'];
      if (participants.contains(reporterId)) {
        return doc.id;
      }
    }

    // Jika belum ada, buat baru
    final newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      'reportId': reportId,
      'itemName': itemName,
      'participants': [currentUid, reporterId],
      'participantNames': {
        currentUid: _auth.currentUser?.displayName ?? 'User',
        reporterId: reporterName,
      },
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChatRef.id;
  }
}
