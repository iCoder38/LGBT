import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  final String id;
  final String userId;
  final String type; // "Text" | "Image" | "Video"
  final String? message;
  final List<String>? imageUrls;
  final DateTime? createdAt;

  Feed({
    required this.id,
    required this.userId,
    required this.type,
    this.message,
    this.imageUrls,
    this.createdAt,
  });

  factory Feed.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return Feed(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: (data['type'] as String?) ?? 'Text',
      message: data['message'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: ts?.toDate(),
    );
  }
}
