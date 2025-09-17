import 'dart:convert';

import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  bool _loading = true;
  bool isFailed = false;
  String? _errorMessage;
  dynamic postJson;
  dynamic postJsonUser;
  final List<String> feedImagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    // nothing asynchronous to cancel here, but if you later add timers/streams,
    // cancel them here. Rely on `mounted` checks in async callbacks.
    super.dispose();
  }

  /// Loads post using your server API via callPostDetails (uses ApiService().postRequest)
  Future<void> _loadPost() async {
    // show loading in a safe way
    if (mounted) {
      setState(() {
        _loading = true;
        isFailed = false;
        _errorMessage = null;
      });
    }

    await callPostDetails(widget.postId);
  }

  /// Loads post details and updates UI only when mounted.
  Future<void> callPostDetails(String id) async {
    try {
      final userData = await UserLocalStorage.getUserData();

      // dismiss keyboard (safe even if not mounted)
      FocusScope.of(context).requestFocus(FocusNode());

      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadPostDetails(
          action: "postdetail",
          userId: userData['userId'].toString(),
          postId: id.toString(),
        ),
      );

      GlobalUtils().customLog(response);

      if (response['status'].toString().toLowerCase() == "success") {
        postJson = response["data"];
        postJsonUser = postJson["user"];

        // reset images list (important when widget rebuilds)
        feedImagePaths.clear();

        if (postJson['image_1']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['image_1'].toString());
        }
        if (postJson['image_2']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['image_2'].toString());
        }
        if (postJson['video']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['video'].toString());
        }

        GlobalUtils().customLog(postJsonUser);

        // Only update state when still mounted
        if (!mounted) return;
        setState(() {
          isFailed = false;
          _loading = false;
        });
      } else {
        GlobalUtils().customLog("Big False");
        if (!mounted) return;
        setState(() {
          _loading = false;
          isFailed = true;
          _errorMessage = response['message']?.toString() ?? 'Failed to load';
        });
      }
    } catch (e, st) {
      GlobalUtils().customLog('callPostDetails error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        isFailed = true;
        _errorMessage = 'Something went wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _loading
          ? const CustomAppBar(title: "")
          : CustomAppBar(
              title: "Details",
              showBackButton: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                icon: Icon(Icons.chevron_left),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : isFailed
          ? _errorUI()
          : _UIKIT(context),
    );
  }

  Widget _errorUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage ?? 'Failed to load post'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _loadPost(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  CustomFeedPostCardHorizontal _UIKIT(BuildContext context) {
    return CustomFeedPostCardHorizontal(
      userName: postJsonUser?['firstName'] ?? '',
      userImagePath: postJsonUser?['profile_picture'] ?? '',
      timeAgo: postJson?['created'] ?? '',
      feedImagePaths: feedImagePaths,
      totalLikes: postJson?['totalLike']?.toString() ?? '0',
      totalComments: postJson?['totalComment']?.toString() ?? '0',
      onLikeTap: () {
        if (!mounted) return;
        setState(() {
          int currentLikes =
              int.tryParse(postJson['totalLike'].toString()) ?? 0;
          if (postJson['youliked'] == 1) {
            postJson['youliked'] = 0;
            if (currentLikes > 0)
              postJson['totalLike'] = (currentLikes - 1).toString();
          } else {
            postJson['youliked'] = 1;
            postJson['totalLike'] = (currentLikes + 1).toString();
          }
        });

        String statusToSend = postJson['youliked'] == 0 ? "2" : "1";
        // callLikeUnlikeWB(...)
      },
      onCommentTap: () {
        NavigationUtils.pushTo(context, CommentsScreen(postDetails: postJson));
      },
      onShareTap: () {
        final url =
            'https://lgbt-togo.web.app/post/${postJson['postId'].toString()}';
        final text = (postJson['postTitle']?.toString()?.isEmpty ?? true)
            ? 'LGBT-TOGO\n\nTap to open: $url'
            : '${postJson['postTitle'].toString()}\n\nTap to open: $url';
        Share.share(text);
      },
      onUserTap: () {
        NavigationUtils.pushTo(
          context,
          UserProfileScreen(profileData: postJson, isFromRequest: false),
        );
      },
      onCardTap: () => GlobalUtils().customLog("Full feed tapped index !"),
      onMenuTap: () async {
        final userData = await UserLocalStorage.getUserData();
        if (userData['userId'].toString() == postJson['userId'].toString()) {
          AlertsUtils().showCustomBottomSheet(
            context: context,
            message: "Delete post",
            buttonText: "Confirm",
            onItemSelected: (s) {
              if (s == "Delete post") {
                // callDeletePostWB(context, postJson['postId'].toString());
              }
            },
          );
        } else {
          AlertsUtils().showCustomBottomSheet(
            context: context,
            message: "Report post",
            buttonText: "Select",
            onItemSelected: (s) {
              // callReportWB(context, postJson['postId'].toString());
            },
          );
        }
      },
      youLiked: postJson['youliked'] == 1,
      postTitle: postJson['postTitle'].toString(),
      type: postJson["postType"].toString(),
      ishoriz: false,
    );
  }
}

/// Basic PostModel — adapt fields to match your API's response.
class PostModel {
  final String id;
  final String title;
  final String body;
  final String? authorName;
  final String? imageUrl;
  final DateTime? publishedAt;
  final Map<String, dynamic> rawJson;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    this.authorName,
    this.imageUrl,
    this.publishedAt,
    required this.rawJson,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? json['postId']?.toString() ?? '',
      title: json['title']?.toString() ?? json['postTitle']?.toString() ?? '',
      body: json['body']?.toString() ?? json['postBody']?.toString() ?? '',
      authorName: json['author'] is Map
          ? json['author']['name']?.toString()
          : json['author']?.toString(),
      imageUrl:
          json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['thumbnail']?.toString(),
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString())
                : null),
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  String publishedAtFormatted() {
    if (publishedAt == null) return '';
    return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
  }
}
