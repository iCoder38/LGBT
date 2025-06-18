import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, this.postDetails});

  final postDetails;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool screenLoader = true;
  List<CommentModel> arrComments = [];

  final TextEditingController _commentController = TextEditingController();
  var userData;
  @override
  void initState() {
    super.initState();
    initUserData();
  }

  initUserData() async {
    userData = await UserLocalStorage.getUserData();

    callComment(context);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void callComment(context) async {
    await Future.delayed(Duration(milliseconds: 400));
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    await callCommentWB(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Essential for keyboard handling
      appBar: CustomAppBar(
        title: Localizer.get(AppText.comments.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: screenLoader ? const SizedBox() : _UIKIT(context)),
            _commentInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _UIKIT(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: arrComments.length,
      itemBuilder: (context, index) {
        final CommentModel comment = arrComments[index];
        return ListTile(
          leading: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColor().GRAY,
              shape: BoxShape.circle,
            ),
            child: CustomCacheImageForUserProfile(
              imageURL: comment.user?.profilePicture ?? '',
            ),
          ),
          title: customText(
            // widget.postDetails["user"]["firstName"].toString(),
            comment.user?.firstName ?? 'Anonymous',
            16,
            context,
            fontWeight: FontWeight.w600,
          ),
          //subtitle: customText(comment.comment, 14, context),
          subtitle: Padding(
            key: const Key('showMore'),
            padding: const EdgeInsets.all(0),
            child: ReadMoreText(
              comment.comment,
              trimMode: TrimMode.Line,
              trimLines: 3,
              trimLength: 240,
              // preDataText: 'AMANDA',
              // preDataTextStyle: const TextStyle(fontWeight: FontWeight.w500),
              style: const TextStyle(color: Colors.black),
              colorClickableText: Colors.pink,
              trimCollapsedText: '...Show more',
              trimExpandedText: ' show less',
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              GlobalUtils().customLog(comment.userId);
              GlobalUtils().customLog(userData["userId"].toString());
              if (comment.userId.toString() == userData["userId"].toString()) {
                AlertsUtils().showBottomSheetWithTwoBottom(
                  context: context,
                  message: "Delete this comment",
                  onYesTap: () async {
                    AlertsUtils.showLoaderUI(
                      context: context,
                      title: Localizer.get(AppText.pleaseWait.key),
                    );
                    await Future.delayed(const Duration(milliseconds: 600));
                    await callDeleteCommentWB(
                      context,
                      comment.commentId.toString(),
                    );
                  },
                  yesTitle: 'Delete',
                );
              }
            },
            icon: const Icon(Icons.more_horiz),
          ),
        );
      },
    );
  }

  Widget _commentInputField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor().kWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor().GRAY),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "Write a comment...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColor().PURPLE,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () async {
                final commentText = _commentController.text.trim();
                if (commentText.isNotEmpty) {
                  GlobalUtils().customLog("Send comment: $commentText");

                  _commentController.clear();
                  FocusScope.of(context).unfocus();

                  await callPostCommentWB(context, commentText);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ====================== API ================================================
  Future<void> callCommentWB(BuildContext context) async {
    final userData = await UserLocalStorage.getUserData();

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadCommentList(
        action: ApiAction().COMMENTS_LIST,
        userId: userData['userId'].toString(),
        postId: widget.postDetails["postId"].toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      List<CommentModel> commentList = (response["data"] as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();

      Navigator.pop(context);

      setState(() {
        arrComments = commentList;
        screenLoader = false;
      });
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // delete comment
  Future<void> callDeleteCommentWB(
    BuildContext context,
    String commentId,
  ) async {
    final userData = await UserLocalStorage.getUserData();

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadCommentDelete(
        action: ApiAction().COMMENTS_DELETE,
        userId: userData['userId'].toString(),
        commentId: commentId,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ Comment DELETE success");
      callCommentWB(context);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // post comment
  Future<void> callPostCommentWB(BuildContext context, String text) async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadCommentPosts(
        action: ApiAction().COMMENT_POST,
        userId: userData['userId'].toString(),
        postId: widget.postDetails["postId"].toString(),
        comment: text,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ Comment POSTED success");
      callCommentWB(context);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
