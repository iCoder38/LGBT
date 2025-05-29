import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> set(String path, Map<String, dynamic> data) =>
      _firestore.doc(path).set(data);

  Future<void> update(String path, Map<String, dynamic> data) =>
      _firestore.doc(path).update(data);

  Future<void> delete(String path) => _firestore.doc(path).delete();

  Future<Map<String, dynamic>?> get(String path) async {
    final doc = await _firestore.doc(path).get();
    return doc.exists ? doc.data() : null;
  }
}
