import 'package:lgbt_togo/Features/Models/post.dart';
import 'package:lgbt_togo/Features/Models/user.dart';

class CommentModel {
  final int commentId;
  final int userId;
  final int postId;
  final String comment;
  final int status;
  final String created;
  final PostModel? post;
  final UserModel? user;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.status,
    required this.created,
    this.post,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] ?? 0,
      userId: json['userId'] ?? 0,
      postId: json['postId'] ?? 0,
      comment: json['comment'] ?? '',
      status: json['stataus'] ?? 0, // typo is intentional for API compatibility
      created: json['created'] ?? '',
      post: json['post'] != null ? PostModel.fromJson(json['post']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
