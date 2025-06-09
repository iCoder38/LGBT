class CommentModel {
  final int commentId;
  final int userId;
  final int postId;
  final String comment;
  final int status;
  final String created;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.postId,
    required this.comment,
    required this.status,
    required this.created,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] ?? 0,
      userId: json['userId'] ?? 0,
      postId: json['postId'] ?? 0,
      comment: json['comment'] ?? '',
      status: json['stataus'] ?? 0, // NOTE: typo → "stataus"
      created: json['created'] ?? '',
    );
  }
}
