// // File: flutter_comments_firestore.dart
// // Comments saved under: feeds/{feedId}/comments
// // - Each comment/reply fields: { comment, userId, createdAt (server timestamp), likes: Map }
// // - Replies stored under: feeds/{feedId}/comments/{commentId}/replies

// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/dashboard_two.dart';
// import 'package:lgbt_togo/Features/Screens/Dashboard/Feeds/widget/header.dart';
// import 'package:lgbt_togo/Features/Utils/barrel/imports.dart'; // ProfileHeader

// class CommentScreen extends StatefulWidget {
//   final String feedId;
//   final String feedUserId;
//   const CommentScreen({
//     super.key,
//     required this.feedId,
//     required this.feedUserId,
//   });

//   @override
//   State<CommentScreen> createState() => _CommentScreenState();
// }

// class _CommentScreenState extends State<CommentScreen> {
//   final TextEditingController _newCommentController = TextEditingController();
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;

//   @override
//   void dispose() {
//     _newCommentController.dispose();
//     super.dispose();
//   }

//   CollectionReference<Map<String, dynamic>> commentsRef() {
//     return _firestore
//         .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
//         .doc(widget.feedId)
//         .collection('comments')
//         .withConverter<Map<String, dynamic>>(
//           fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
//           toFirestore: (map, _) => map,
//         );
//   }

//   Future<void> _postComment(String text) async {
//     final user = _auth.currentUser;
//     if (user == null) return; // handle not logged in in real app
//     final trimmed = text.trim();
//     if (trimmed.isEmpty) return;

//     final doc = {
//       'comment': trimmed,
//       'userId': user.uid,
//       'createdAt': FieldValue.serverTimestamp(),
//       'likes': <String, dynamic>{},
//     };

//     DocumentReference<Map<String, dynamic>>? docRef;
//     try {
//       // 1) create comment and capture its id
//       final addedRef = await commentsRef().add(doc);
//       // if you used withConverter, add() returns DocumentReference<Map<...>>
//       docRef = addedRef as DocumentReference<Map<String, dynamic>>?;

//       // clear the input immediately for UX
//       _newCommentController.clear();

//       // 2) increment the feed's commentsCount (atomic)
//       await _firestore
//           .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
//           .doc(widget.feedId)
//           .update({'commentsCount': FieldValue.increment(1)});
//     } catch (e) {
//       // handle error creating comment or updating counter
//       debugPrint('Failed to post comment or increment counter: $e');
//       // still clear input so user isn't stuck; you may want to show SnackBar instead
//       _newCommentController.clear();
//       return;
//     }

//     // 3) send notification with proper IDs
//     try {
//       // Make sure widget.feedUserId exists and is the feed owner's userId
//       final targetUserId = widget.feedUserId.toString();
//       if (targetUserId.isNotEmpty && docRef != null) {
//         // callSendNotificationToToken can be awaited or not; awaiting can slow UI.
//         // I'll start it without waiting so user sees immediate response. If you prefer
//         // to wait, add `await` in front.
//         unawaited(
//           callSendNotificationToToken(
//             context,
//             userId: targetUserId,
//             title: 'Someone commented on your post',
//             body: 'Tap to see',
//             parentcontentId: widget.feedId,
//             contentId: docRef.id,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Failed to send notification: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Comments')),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: commentsRef()
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Center(child: Text('Error'));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final docs = snapshot.data!.docs;
//                 if (docs.isEmpty) {
//                   return const Center(child: Text('No comments yet'));
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final doc = docs[index];
//                     return CommentTile(
//                       commentDoc: doc,
//                       fireStore: _firestore,
//                       auth: _auth,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // new comment input
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _newCommentController,
//                       textInputAction: TextInputAction.send,
//                       decoration: const InputDecoration(
//                         hintText: 'Write a comment...',
//                         border: OutlineInputBorder(),
//                         isDense: true,
//                       ),
//                       onSubmitted: (val) => _postComment(val),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () => _postComment(_newCommentController.text),
//                     child: const Text('Send'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CommentTile extends StatefulWidget {
//   final QueryDocumentSnapshot<Map<String, dynamic>> commentDoc;
//   final FirebaseFirestore fireStore;
//   final FirebaseAuth auth;

//   const CommentTile({
//     super.key,
//     required this.commentDoc,
//     required this.fireStore,
//     required this.auth,
//   });

//   @override
//   State<CommentTile> createState() => _CommentTileState();
// }

// class _CommentTileState extends State<CommentTile> {
//   bool _showReplyField = false;
//   final TextEditingController _replyController = TextEditingController();

//   /// Optimistic like state:
//   /// - null = no optimistic override (use server snapshot)
//   /// - true/false = optimistic override for whether current user liked
//   bool? _optimisticUserLiked;
//   int _optimisticDelta =
//       0; // +1 or -1 to apply to displayed like count immediately
//   bool _isProcessingLike = false;

//   // wait for server confirmation
//   bool _awaitingServerConfirm = false;
//   bool? _expectedUserLiked; // what we expect the server to show
//   Timer? _confirmTimer;

//   @override
//   void dispose() {
//     _replyController.dispose();
//     _confirmTimer?.cancel();
//     super.dispose();
//   }

//   CollectionReference<Map<String, dynamic>> repliesRef() {
//     return widget.commentDoc.reference
//         .collection('replies')
//         .withConverter<Map<String, dynamic>>(
//           fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
//           toFirestore: (map, _) => map,
//         );
//   }

//   Future<void> _postReply(String text) async {
//     final user = widget.auth.currentUser;
//     if (user == null) return;
//     if (text.trim().isEmpty) return;

//     final doc = {
//       'comment': text.trim(),
//       'userId': user.uid,
//       'createdAt': FieldValue.serverTimestamp(),
//       'likes': <String, dynamic>{},
//     };

//     await repliesRef().add(doc);
//     _replyController.clear();
//     setState(() => _showReplyField = false);
//   }

//   /// Optimistic toggle like for a comment document
//   Future<void> _onLikePressedOptimistic(DocumentReference docRef) async {
//     final user = widget.auth.currentUser;
//     if (user == null) return;
//     if (_isProcessingLike) return;
//     _isProcessingLike = true;

//     final uid = user.uid;

//     // best-effort fetch current server state
//     final snapshot = await docRef.get();
//     final data = snapshot.data() as Map<String, dynamic>? ?? {};
//     final likes = Map<String, dynamic>.from(data['likes'] ?? {});
//     final serverUserLiked = likes.containsKey(uid) && likes[uid] == true;

//     final newUserLiked = !serverUserLiked;
//     final delta = newUserLiked ? 1 : -1;

//     // apply optimistic UI
//     setState(() {
//       _optimisticUserLiked = newUserLiked;
//       _optimisticDelta = delta;
//       _awaitingServerConfirm = true;
//       _expectedUserLiked = newUserLiked;
//     });

//     // start a fallback timer to clear optimistic if confirmation never arrives
//     _confirmTimer?.cancel();
//     _confirmTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _optimisticUserLiked = null;
//           _optimisticDelta = 0;
//           _awaitingServerConfirm = false;
//           _expectedUserLiked = null;
//         });
//       }
//     });

//     try {
//       await widget.fireStore.runTransaction((tx) async {
//         final snap = await tx.get(docRef);
//         if (!snap.exists) return;
//         final d = snap.data() as Map<String, dynamic>? ?? {};
//         final curLikes = Map<String, dynamic>.from(d['likes'] ?? {});
//         if (curLikes.containsKey(uid) && curLikes[uid] == true) {
//           curLikes.remove(uid);
//         } else {
//           curLikes[uid] = true;
//         }
//         tx.update(docRef, {'likes': curLikes});
//       });

//       // don't clear optimistic immediately — wait for server snapshot to confirm.
//       // The build() logic below will detect server confirmation and clear state.
//     } catch (e) {
//       // rollback optimistic UI immediately on error
//       if (mounted) {
//         setState(() {
//           _optimisticUserLiked = null;
//           _optimisticDelta = 0;
//           _awaitingServerConfirm = false;
//           _expectedUserLiked = null;
//         });
//       }
//       debugPrint('Like transaction failed: $e');
//     } finally {
//       _isProcessingLike = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = widget.commentDoc.data();
//     final commentText = data['comment'] as String? ?? '';
//     final createdAt = (data['createdAt'] as Timestamp?)?.toDate(); // DateTime?
//     final likesMap = Map<String, dynamic>.from(data['likes'] ?? {});
//     final serverLikeCount = likesMap.length;
//     final currentUid = widget.auth.currentUser?.uid;
//     final serverUserLiked =
//         currentUid != null && likesMap.containsKey(currentUid);

//     // clear optimistic override if server now matches our expectation
//     if (_awaitingServerConfirm && _expectedUserLiked != null) {
//       final serverUserLikedNow = serverUserLiked;
//       if (serverUserLikedNow == _expectedUserLiked) {
//         _confirmTimer?.cancel();
//         if (mounted) {
//           setState(() {
//             _optimisticUserLiked = null;
//             _optimisticDelta = 0;
//             _awaitingServerConfirm = false;
//             _expectedUserLiked = null;
//           });
//         }
//       }
//     }

//     // If optimistic override present, prefer it for UI
//     final displayUserLiked = _optimisticUserLiked ?? serverUserLiked;
//     final displayLikeCount = (serverLikeCount + _optimisticDelta).clamp(
//       0,
//       1 << 60,
//     );

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ProfileHeader(
//               userId: data['userId'].toString(),
//               time: createdAt,
//               menuIcon: Icon(Icons.delete, color: AppColor().RED),
//               onMenuTap: () {
//                 // print("object: $data");
//                 final data = widget.commentDoc.data();
//                 final authorId = data['userId'] as String;
//                 _onDeletePressed(authorId);
//               },
//             ),

//             const SizedBox(height: 10),

//             Text(commentText),

//             const SizedBox(height: 8),

//             // ---------- Likes + Reply row (Row ensures like button is always visible) ----------
//             Row(
//               children: [
//                 // left side: like count + reply text
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Text(
//                         '$displayLikeCount likes',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       GestureDetector(
//                         onTap: () =>
//                             setState(() => _showReplyField = !_showReplyField),
//                         child: const Text(
//                           'Reply',
//                           style: TextStyle(fontSize: 13, color: Colors.blue),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // right side: like button always visible (optimistic UI on tap)
//                 IconButton(
//                   onPressed: () =>
//                       _onLikePressedOptimistic(widget.commentDoc.reference),
//                   icon: Icon(
//                     displayUserLiked ? Icons.favorite : Icons.favorite_border,
//                     color: displayUserLiked ? Colors.red : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),

//             if (_showReplyField) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _replyController,
//                       decoration: const InputDecoration(
//                         hintText: 'Write a reply...',
//                         isDense: true,
//                         border: OutlineInputBorder(),
//                       ),
//                       onSubmitted: (val) => _postReply(val),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () => _postReply(_replyController.text),
//                     child: const Text('Send'),
//                   ),
//                 ],
//               ),
//             ],

//             const SizedBox(height: 8),

//             StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//               stream: repliesRef()
//                   .orderBy('createdAt', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) return const SizedBox();
//                 if (!snapshot.hasData) return const SizedBox();

//                 final replyDocs = snapshot.data!.docs;
//                 if (replyDocs.isEmpty) return const SizedBox();

//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: replyDocs.length,
//                   itemBuilder: (context, index) {
//                     final replyDoc = replyDocs[index];
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8.0, left: 12),
//                       child: ReplyTile(
//                         replyDoc: replyDoc,
//                         fireStore: widget.fireStore,
//                         auth: widget.auth,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onDeletePressed(String authorId) async {
//     final currentUid = FIREBASE_AUTH_UID();
//     // widget.auth.currentUser?.uid;
//     // if (currentUid == null) return;
//     if (currentUid != authorId) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('You cannot delete this comment')),
//       );
//       return;
//     }

//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete comment?'),
//         content: const Text(
//           'Are you sure you want to delete this comment? This cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (ok == true) await _deleteComment();
//   }

//   Future<void> _deleteComment() async {
//     final feedRef = widget.fireStore
//         .collection('LGBT_TOGO_PLUS/FEEDS/LIST')
//         .doc(widget.commentDoc.reference.parent.parent!.id);
//     final commentRef = widget.commentDoc.reference;
//     try {
//       final repliesSnap = await commentRef.collection('replies').get();
//       for (final doc in repliesSnap.docs) {
//         await doc.reference.delete();
//       }
//       await commentRef.delete();
//       await feedRef.update({'commentsCount': FieldValue.increment(-1)});
//     } catch (e) {
//       debugPrint('Failed to delete comment: $e');
//     }
//   }
// }

// class ReplyTile extends StatefulWidget {
//   final QueryDocumentSnapshot<Map<String, dynamic>> replyDoc;
//   final FirebaseFirestore fireStore;
//   final FirebaseAuth auth;

//   const ReplyTile({
//     super.key,
//     required this.replyDoc,
//     required this.fireStore,
//     required this.auth,
//   });

//   @override
//   State<ReplyTile> createState() => _ReplyTileState();
// }

// class _ReplyTileState extends State<ReplyTile> {
//   /// optimistic fields for reply like
//   bool? _optimisticUserLiked;
//   int _optimisticDelta = 0;
//   bool _isProcessingLike = false;

//   /// server confirm fields for reply
//   bool _awaitingServerConfirm = false;
//   bool? _expectedUserLiked;
//   Timer? _confirmTimer;

//   @override
//   void dispose() {
//     _confirmTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _onLikePressedOptimistic(DocumentReference docRef) async {
//     final user = widget.auth.currentUser;
//     if (user == null) return;
//     if (_isProcessingLike) return;
//     _isProcessingLike = true;

//     final uid = user.uid;

//     // best-effort fetch
//     final snap = await docRef.get();
//     final data = snap.data() as Map<String, dynamic>? ?? {};
//     final likes = Map<String, dynamic>.from(data['likes'] ?? {});
//     final serverUserLiked = likes.containsKey(uid) && likes[uid] == true;
//     final newUserLiked = !serverUserLiked;
//     final delta = newUserLiked ? 1 : -1;

//     setState(() {
//       _optimisticUserLiked = newUserLiked;
//       _optimisticDelta = delta;
//       _awaitingServerConfirm = true;
//       _expectedUserLiked = newUserLiked;
//     });

//     // start fallback timer
//     _confirmTimer?.cancel();
//     _confirmTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _optimisticUserLiked = null;
//           _optimisticDelta = 0;
//           _awaitingServerConfirm = false;
//           _expectedUserLiked = null;
//         });
//       }
//     });

//     try {
//       await widget.fireStore.runTransaction((tx) async {
//         final s = await tx.get(docRef);
//         if (!s.exists) return;
//         final d = s.data() as Map<String, dynamic>? ?? {};
//         final curLikes = Map<String, dynamic>.from(d['likes'] ?? {});
//         if (curLikes.containsKey(uid) && curLikes[uid] == true) {
//           curLikes.remove(uid);
//         } else {
//           curLikes[uid] = true;
//         }
//         tx.update(docRef, {'likes': curLikes});
//       });

//       // don't clear optimistic immediately; wait for server snapshot confirmation
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _optimisticUserLiked = null;
//           _optimisticDelta = 0;
//           _awaitingServerConfirm = false;
//           _expectedUserLiked = null;
//         });
//       }
//       debugPrint('Reply like transaction failed: $e');
//     } finally {
//       _isProcessingLike = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = widget.replyDoc.data();
//     final text = data['comment'] as String? ?? '';
//     final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
//     final likesMap = Map<String, dynamic>.from(data['likes'] ?? {});
//     final serverLikeCount = likesMap.length;
//     final currentUid = widget.auth.currentUser?.uid;
//     final serverUserLiked =
//         currentUid != null && likesMap.containsKey(currentUid);

//     // clear optimistic override if server now matches our expectation
//     if (_awaitingServerConfirm && _expectedUserLiked != null) {
//       final serverUserLikedNow = serverUserLiked;
//       if (serverUserLikedNow == _expectedUserLiked) {
//         _confirmTimer?.cancel();
//         if (mounted) {
//           setState(() {
//             _optimisticUserLiked = null;
//             _optimisticDelta = 0;
//             _awaitingServerConfirm = false;
//             _expectedUserLiked = null;
//           });
//         }
//       }
//     }

//     final displayUserLiked = _optimisticUserLiked ?? serverUserLiked;
//     final displayLikeCount = (serverLikeCount + _optimisticDelta).clamp(
//       0,
//       1 << 60,
//     );

//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       color: Colors.grey[50],
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Reply header row (avatar, name/time) + like button on right
//             ProfileHeader(
//               userId: data['userId'].toString(),
//               time: createdAt,
//               menuIcon: Icon(
//                 displayUserLiked ? Icons.favorite : Icons.favorite_border,
//                 color: displayUserLiked ? Colors.red : Colors.grey,
//               ),
//               onMenuTap: () {
//                 _onLikePressedOptimistic(widget.replyDoc.reference);
//               },
//             ),
//             /*Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 14,
//                   child: Icon(Icons.person, size: 16),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'User: ${data['userId'] ?? 'unknown'}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                       if (createdAt != null)
//                         Text(
//                           _formatTimestamp(createdAt),
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),

//                 // Like button — visible and wired to optimistic handler
//                 IconButton(
//                   onPressed: () =>
//                       _onLikePressedOptimistic(widget.replyDoc.reference),
//                   icon: Icon(
//                     displayUserLiked ? Icons.favorite : Icons.favorite_border,
//                     size: 20,
//                     color: displayUserLiked ? Colors.red : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),*/
//             const SizedBox(height: 6),
//             Text(text),
//             const SizedBox(height: 6),
//             Text(
//               '$displayLikeCount likes',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// String _formatTimestamp(DateTime? dt) {
//   if (dt == null) return '';
//   final local = dt.toLocal();
//   final diff = DateTime.now().difference(local);

//   if (diff.inSeconds < 60) return "Just now";
//   if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
//   if (diff.inHours < 24) return "${diff.inHours}h ago";
//   if (diff.inDays == 1) return "Yesterday";
//   if (diff.inDays < 7) return "${diff.inDays}d ago";

//   final time =
//       '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
//   final date =
//       '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
//   return '$date $time';
// }
