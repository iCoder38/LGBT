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

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  /// Loads post using your server API via callPostDetails (uses ApiService().postRequest)
  Future<void> _loadPost() async {
    _loading = true;
    await callPostDetails(widget.postId);
  }

  /// Updated to return the API response map (instead of void) so _loadPost can inspect it.
  /// Reuses your ApiService payload wrapper.
  Future<void> callPostDetails(String id) async {
    final userData = await UserLocalStorage.getUserData();
    // dismiss keyboard
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
      // if (status == 'success') {
      // assume server returns post data inside response['data'] or similar
      setState(() {
        isFailed = false;
      });
      // return response;
    } else {
      GlobalUtils().customLog("Big False");
      // show error and throw so caller knows
      // final msg = response['msg']?.toString() ?? 'Failed to load post details';
      // AlertsUtils().showExceptionPopup(context: context, message: msg);
      setState(() {
        _loading = true;
        isFailed = true;
      });
      // Navigator.pop(context);
      // throw Exception("");
    }
  }

  void _sharePost(PostModel post) {
    // Use your canonical web url or app-deep-link; replace domain below
    final url = 'https://api.lgbttogo.com/post/${widget.postId}';
    final text = '${post.title}\n\nRead more: $url';
    Share.share(text);
  }

  void _copyLinkToClipboard() {
    final url = 'https://api.lgbttogo.com/post/${widget.postId}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return Scaffold(
        // appBar: AppBar(title: const Text('Loading post...')),
        body: isFailed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: customText(
                      "Something went wrong...",
                      12,
                      context,
                      color: AppColor().RED,
                    ),
                  ),
                  CustomButton(
                    text: "Home",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load post.\n$_errorMessage',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPost,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Success state: _post should be non-null
    final post = _post!;
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title.isNotEmpty ? post.title : 'Post'),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => _sharePost(post),
          ),
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.link),
            onPressed: _copyLinkToClipboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPost();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (post.authorName != null)
                  Text(
                    'By ${post.authorName}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                const Spacer(),
                Text(
                  post.publishedAtFormatted(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SelectableText(post.body),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Liked (demo)')),
                    );
                  },
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Like'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Open external browser if desired
                    // launchUrlString('https://example.com/post/${widget.postId}');
                  },
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in browser'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Debug: Raw data'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    jsonEncode(post.rawJson),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    // Adjust field extraction depending on your backend
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
