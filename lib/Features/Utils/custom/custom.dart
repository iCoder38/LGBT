import 'dart:io';

import 'package:lgbt_togo/Features/Models/post.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/custom/video_player.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:share_plus/share_plus.dart';

Widget customText(
  String text,
  double fontSize,
  BuildContext context, {
  String fontFamilyCode = 'p', // 'p' = Poppins, 'm' = Montserrat
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
  bool isCentered = false,
  bool isCrossedOut = false,
  TextAlign? textAlign, // ✅ New optional textAlign
}) {
  final style = fontFamilyCode == 'm'
      ? GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          decoration: isCrossedOut ? TextDecoration.lineThrough : null,
        )
      : GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          decoration: isCrossedOut ? TextDecoration.lineThrough : null,
        );

  final textWidget = Text(
    text,
    style: style,
    textAlign: textAlign, // ✅ Applied here
  );

  return isCentered ? Center(child: textWidget) : textWidget;
}

class CustomContainer extends StatelessWidget {
  final String? text;
  final String? textFontFamily;
  final FontWeight? textFontWeight;
  final double? fontSize;
  final Color color;
  final VoidCallback? onTap;
  final IconData? icon;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final bool shadow;
  final Widget? child;

  const CustomContainer({
    super.key,
    this.text,
    this.textFontFamily,
    this.textFontWeight,
    this.fontSize,
    required this.color,
    this.onTap,
    this.icon,
    this.margin,
    this.height,
    this.width,
    this.borderRadius,
    this.textColor,
    this.iconColor,
    this.borderColor, // Initialize border color
    required this.shadow,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(16.0),
        height: height ?? 50.0,
        width: width ?? MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: 2.5,
                ) // Apply border if color is provided
              : null, // No border if borderColor is null
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(2.0, 2.0),
                  ),
                ]
              : [],
        ),
        child: Center(
          child:
              child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (text != null)
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: fontSize ?? 16.0,
                        fontWeight: textFontWeight ?? FontWeight.w400,
                        color: textColor ?? Colors.white,
                        fontFamily: textFontFamily,
                      ),
                    ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: iconColor ?? Colors.white),
                  ],
                ],
              ),
        ),
      ),
    );
  }
}

// ====================== TEXT FIELD ==========================================
// =============================================================================

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final bool isCentered;
  final TextAlign textAlign;

  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingTop;
  final double? paddingBottom;

  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  final int minLines;
  final int? maxLines;
  final bool expands;

  // ✅ Header title
  final String? headerTitle;
  final double titleLeftPadding;

  // ✅ Footer text
  final String? footerText;
  final double footerLeftPadding;
  final double footerRightPadding;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.isCentered = false,
    this.textAlign = TextAlign.start,
    this.paddingLeft,
    this.paddingRight,
    this.paddingTop,
    this.paddingBottom,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.minLines = 1,
    this.maxLines,
    this.expands = false,
    this.headerTitle,
    this.titleLeftPadding = 22,
    this.footerText,
    this.footerLeftPadding = 22,
    this.footerRightPadding = 22,
  });

  @override
  Widget build(BuildContext context) {
    final fieldPadding = EdgeInsets.only(
      left: paddingLeft ?? 0,
      right: paddingRight ?? 0,
      top: paddingTop ?? 0,
      bottom: paddingBottom ?? 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerTitle != null)
          Padding(
            padding: EdgeInsets.only(left: titleLeftPadding),
            child: customText(
              headerTitle!,
              14,
              context,
              color: AppColor().kWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (headerTitle != null) const SizedBox(height: 6),

        // ⬇️ TextField
        Padding(
          padding: fieldPadding,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            textAlign: textAlign,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            minLines: expands ? null : minLines,
            maxLines: expands ? null : maxLines ?? 5,
            expands: expands,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines != null && maxLines! > 1 ? 12 : 18,
                horizontal: 20,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.montserrat(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(suffixIcon, color: Colors.deepPurple),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // ⬇️ Optional footer
        if (footerText != null)
          Padding(
            padding: EdgeInsets.only(
              left: footerLeftPadding,
              right: footerRightPadding,
              top: 0,
            ),
            child: customText(
              footerText!,
              10,
              context,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
              isCentered: true,
            ),
          ),
      ],
    );
  }
}

// ====================== APP BAR ==============================================
// =============================================================================
// Replace ONLY the CustomAppBar class in your file with this.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final IconData? backIcon;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;
  final VoidCallback? onBackPressed;

  // NEW: show an image at center instead of title.
  final String? centerImageUrl; // network image URL
  final String? centerImageAsset; // local asset path
  final double centerImageSize; // width & height for center image
  final VoidCallback? onCenterTap; // optional tap on center widget

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.backIcon,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
    this.onBackPressed,
    this.centerImageUrl,
    this.centerImageAsset,
    this.centerImageSize = 36,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build center widget: image (network or asset) wins over title.
    Widget centerWidget;
    if (centerImageUrl != null && centerImageUrl!.trim().isNotEmpty) {
      centerWidget = SizedBox(
        width: centerImageSize,
        height: centerImageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(centerImageSize / 2),
          child: GestureDetector(
            onTap: onCenterTap,
            child: Image.network(
              centerImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.image_not_supported, color: Colors.white),
            ),
          ),
        ),
      );
    } else if (centerImageAsset != null &&
        centerImageAsset!.trim().isNotEmpty) {
      centerWidget = SizedBox(
        width: centerImageSize,
        height: centerImageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(centerImageSize / 2),
          child: GestureDetector(
            onTap: onCenterTap,
            child: Image.asset(centerImageAsset!, fit: BoxFit.cover),
          ),
        ),
      );
    } else {
      centerWidget = GestureDetector(
        onTap: onCenterTap,
        child: customText(
          title,
          16,
          context,
          fontWeight: FontWeight.w600,
          color: AppColor().kWhite,
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColor().kNavigationColor,
      elevation: 0,
      centerTitle: centerTitle,
      title: centerWidget,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                backIcon ?? Icons.arrow_back,
                color: AppColor().kWhite,
              ),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.pop(context, 'reload');
                }
              },
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ====================== BUTTON ==============================================
// =============================================================================
class CustomButton extends StatelessWidget {
  final String text; // Mandatory parameter
  final double? height;
  final double? width;
  final Color? color;
  final double? textFontWidth;
  final Color? textColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final bool enableShadow; // Enable or disable shadow

  const CustomButton({
    super.key,
    required this.text,
    this.height,
    this.width,
    this.color,
    this.textFontWidth,
    this.textColor,
    this.borderRadius = 12.0,
    this.textStyle,
    this.onPressed,
    this.enableShadow = false, // Default is no shadow
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 60,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enableShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ]
              : [], // No shadow if false
        ),
        alignment: Alignment.center,
        child: customText(
          text,
          textFontWidth ?? 14,
          context,
          fontWeight: FontWeight.w400,
          color: textColor ?? AppColor().kBlack,
        ),
      ),
    );
  }
}

// ====================== RICH TEXT ============================================
// =============================================================================

class CustomMultiColoredText extends StatelessWidget {
  final String? text1;
  final String? text2;
  final String? text3;

  final Color? color1;
  final Color? color2;
  final Color? color3;

  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily; // 'm' for Montserrat, 'p' for Poppins

  final TextAlign textAlign;

  final VoidCallback? onTap2;
  final VoidCallback? onTap3;

  const CustomMultiColoredText({
    super.key,
    this.text1,
    this.text2,
    this.text3,
    this.color1,
    this.color2,
    this.color3,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'm',
    this.textAlign = TextAlign.center,
    this.onTap2,
    this.onTap3,
  });

  TextStyle getTextStyle(Color? color) {
    final font = fontFamily == 'p'
        ? GoogleFonts.poppins
        : GoogleFonts.montserrat;
    return font(
      color: color ?? Colors.black,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];

    if (text1 != null) {
      spans.add(TextSpan(text: text1, style: getTextStyle(color1)));
    }

    if (text2 != null) {
      spans.add(
        TextSpan(
          text: text2,
          style: getTextStyle(color2),
          recognizer: onTap2 != null
              ? (TapGestureRecognizer()..onTap = onTap2)
              : null,
        ),
      );
    }

    if (text3 != null) {
      spans.add(
        TextSpan(
          text: text3,
          style: getTextStyle(color3),
          recognizer: onTap3 != null
              ? (TapGestureRecognizer()..onTap = onTap3)
              : null,
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: spans),
    );
  }
}

// ====================== FEEDS START ==========================================
// =============================================================================
class FeedUtils {
  static List<String> prepareFeedImagePaths(Map<String, dynamic> postJson) {
    return [
      postJson['image_1'] ?? '',
      postJson['image_2'] ?? '',
      postJson['image_3'] ?? '',
      postJson['image_4'] ?? '',
      postJson['image_5'] ?? '',
    ].map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}

class CustomFeedPostCardHorizontal extends StatelessWidget {
  final String userName;
  final String userImagePath;
  final String timeAgo;
  final String postTitle;
  final List<String> feedImagePaths;
  final String totalLikes;
  final String totalComments;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onUserTap;
  final VoidCallback onCardTap;
  final VoidCallback onMenuTap;
  final bool youLiked;
  final String type;
  final bool ishoriz;

  const CustomFeedPostCardHorizontal({
    super.key,
    required this.userName,
    required this.userImagePath,
    required this.timeAgo,
    required this.feedImagePaths,
    required this.totalLikes,
    required this.totalComments,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onUserTap,
    required this.onCardTap,
    required this.onMenuTap,
    required this.youLiked,
    required this.postTitle,
    required this.type,
    required this.ishoriz,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> mediaPaths = feedImagePaths.isNotEmpty
        ? feedImagePaths
        : [];

    return InkWell(
      onTap: onCardTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFeedHeaderProfile(
            context: context,
            imagePath: userImagePath,
            userName: userName,
            timeAgo: timeAgo,
            onClick: onUserTap,
            onMorePressed: onMenuTap,
            postType: type,
            isHoriz: ishoriz,
          ),
          const SizedBox(height: 8),

          /// ✅ Post Title (link preview or text)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Builder(
              builder: (context) {
                final bool isLink =
                    postTitle.contains("http://") ||
                    postTitle.contains("https://") ||
                    postTitle.contains("www.");

                if (isLink) {
                  final link = RegExp(
                    r'(https?:\/\/[^\s]+)|(www\.[^\s]+)',
                  ).stringMatch(postTitle.trim())!;
                  final normalizedLink = link.startsWith("http")
                      ? link
                      : "https://$link";

                  return WhatsAppLinkPreview(url: normalizedLink);
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 16),
                    child: ReadMoreText(
                      postTitle,
                      trimMode: TrimMode.Line,
                      trimLines: 2,
                      trimLength: 240,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      colorClickableText: Colors.pink,
                      trimCollapsedText: '...Show more',
                      trimExpandedText: ' show less',
                    ),
                  );
                }
              },
            ),
          ),

          /// ✅ Media
          if (mediaPaths.isEmpty)
            const SizedBox()
          else if (mediaPaths.length == 1)
            Builder(
              builder: (context) {
                final String mediaUrl = mediaPaths.first.toLowerCase();
                final bool isVideo =
                    mediaUrl.endsWith(".mp4") ||
                    mediaUrl.endsWith(".mov") ||
                    mediaUrl.endsWith(".webm") ||
                    mediaUrl.endsWith(".avi") ||
                    mediaUrl.endsWith(".mkv");

                if (isVideo) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomVideoPlayer(videoUrl: mediaPaths.first),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FutureBuilder<String?>(
                              future: VideoUtils.getVideoThumbnail(
                                mediaPaths.first,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.file(
                                    File(snapshot.data!),
                                    width: double.infinity,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  );
                                }

                                return Image.asset(
                                  AppImage().LOGO,
                                  width: double.infinity,
                                  height: 300,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomFullScreenImageViewer(
                            imageUrls: mediaPaths,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: mediaPaths.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Image.asset(AppImage().LOGO, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                }
              },
            )
          else
            SizedBox(
              height: 240,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: mediaPaths.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String imagePath = entry.value;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CustomFullScreenImageViewer(
                              imageUrls: mediaPaths,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 240,
                        height: 240,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                Image.asset(AppImage().LOGO, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 8),

          /// ✅ Like / Comment / Share
          CustomFeedLikeCommentShare(
            context: context,
            totalLikes: totalLikes,
            totalComments: totalComments,
            youLiked: youLiked,
            onLikeTap: onLikeTap,
            onCommentTap: onCommentTap,
            onShareTap: onShareTap,
          ),

          const Divider(height: 24),
        ],
      ),
    );
  }
}

// CustomFeedHeaderProfile
Widget CustomFeedHeaderProfile({
  required BuildContext context,
  required String imagePath,
  required String userName,
  required String timeAgo,
  required bool isHoriz,
  required VoidCallback onClick,
  required VoidCallback onMorePressed,
  required String postType,
}) {
  // Set fallback image (logo) if imagePath is empty or invalid
  final String displayImagePath =
      (imagePath.isEmpty || !imagePath.startsWith('http'))
      ? AppImage().LOGO
      : imagePath;

  return CustomContainer(
    margin: EdgeInsets.zero,
    color: AppColor().TRANSPARENT,
    shadow: false,
    height: 50,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onClick, // Profile picture tap triggers user tap
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SizedBox(
                height: 50,
                width: 50,
                child: displayImagePath.startsWith('http')
                    ? Image.network(displayImagePath, fit: BoxFit.cover)
                    : Image.asset(displayImagePath, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomMultiColoredText(
                text1: "$userName ",
                text2: postType == "Image"
                    ? "shared a new photo"
                    : postType == "Video"
                    ? "shared a new video"
                    : "shared a text",
                color2: AppColor().GRAY,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                onTap2: onClick,
              ),

              const SizedBox(height: 4),
              customText(
                GlobalUtils().formatTimeAgoFromServer(timeAgo),
                10,
                context,
                color: AppColor().GRAY,
              ),
            ],
          ),
        ),
        !isHoriz
            ? SizedBox()
            : IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.more_horiz_sharp),
              ),
      ],
    ),
  );
}

Widget CustomFeedLikeCommentShare({
  required BuildContext context,
  required String totalLikes,
  required String totalComments,
  required VoidCallback onLikeTap,
  required VoidCallback onCommentTap,
  required VoidCallback onShareTap,
  required bool youLiked,
}) {
  final int likeCountSafe = int.tryParse(totalLikes.trim()) ?? 0;

  return CustomContainer(
    color: AppColor().TRANSPARENT,
    shadow: false,
    margin: EdgeInsets.zero,
    borderRadius: 0,
    child: Row(
      children: [
        // ✅ LIKE
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LikeButton(
                isLiked: youLiked,
                likeCount: likeCountSafe,
                circleColor: const CircleColor(
                  start: Color(0xff00ddff),
                  end: Color(0xff0099cc),
                ),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Colors.pink,
                  dotSecondaryColor: Colors.white,
                ),
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.favorite,
                    size: 18,
                    color: isLiked ? Colors.red : AppColor().GRAY,
                  );
                },
                countBuilder: (int? count, bool isLiked, String text) {
                  final displayCount = count ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: customText(
                      "$displayCount ${displayCount == 1 ? "Like" : "Likes"}",
                      12,
                      context,
                      color: AppColor().kBlack,
                    ),
                  );
                },
                onTap: (bool isLiked) async {
                  onLikeTap();
                  return !isLiked;
                },
              ),
            ],
          ),
        ),

        // ✅ COMMENT
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.comment_outlined, size: 16),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onCommentTap,
                child: customText("$totalComments Comments", 12, context),
              ),
            ],
          ),
        ),

        // ✅ SHARE
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share, size: 16),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onShareTap,
                child: customText("Share", 12, context),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ====================== FEEDS END ============================================
// =============================================================================

// Example shimmer loader
class ShimmerLoader extends StatelessWidget {
  final double width;

  const ShimmerLoader({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: 40, color: Colors.grey.shade300);
  }
}

Widget CustomCacheImageForUserProfile({
  required String imageURL,
  int memCacheHeight = 140,
  int memCacheWidth = 140,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(25),
    child: CachedNetworkImage(
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      imageUrl: imageURL,
      fit: BoxFit.cover,
      placeholder: (context, url) => SizedBox(
        height: 40,
        width: 40,
        child: ShimmerLoader(width: MediaQuery.of(context).size.width),
      ),
      errorWidget: (context, url, error) => Image.asset(AppImage().LOGO),
    ),
  );
}

// ====================== USER PROFILE TILE ====================================
// =============================================================================

class CustomUserProfileThreeButtonTile extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onImageTap;
  final VoidCallback onVideoTap;
  final int selectedIndex;

  const CustomUserProfileThreeButtonTile({
    super.key,
    required this.onMenuTap,
    required this.onImageTap,
    required this.onVideoTap,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: EdgeInsets.zero,
      borderRadius: 0,
      color: AppColor().GRAY,
      shadow: false,
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: onMenuTap,
              icon: Icon(
                Icons.list_alt_outlined,
                color: selectedIndex == 0
                    ? AppColor().PRIMARY_COLOR
                    : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: onImageTap,
              icon: Icon(
                Icons.image,
                color: selectedIndex == 1
                    ? AppColor().PRIMARY_COLOR
                    : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: onVideoTap,
              icon: Icon(
                Icons.play_circle_fill_outlined,
                color: selectedIndex == 2
                    ? AppColor().PRIMARY_COLOR
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const CustomFullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<CustomFullScreenImageViewer> createState() =>
      _CustomFullScreenImageViewerState();
}

class _CustomFullScreenImageViewerState
    extends State<CustomFullScreenImageViewer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(child: Image.network(widget.imageUrls[index])),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== CUSTOM USER TILE =====================================
// =============================================================================

class CustomUserTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap; // ✅ Optional tap callback

  const CustomUserTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap, // ✅ Assign in constructor
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap, // ✅ Used here
      leading: leading,
      title: customText(title, 16, context, fontWeight: FontWeight.w600),
      subtitle: customText(subtitle, 12, context, color: AppColor().GRAY),
      trailing: trailing,
    );
  }
}

// ====================== CUSTOM PRIVACY TILE ==================================
// =============================================================================

class CustomPrivacyTile extends StatelessWidget {
  final String title;
  final String selectedOption;
  final Function(String) onUpdate;

  const CustomPrivacyTile({
    super.key,
    required this.title,
    required this.selectedOption,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: customText(title, 12, context),
          trailing: CustomContainer(
            color: AppColor().PURPLE,
            shadow: false,
            borderRadius: 12,
            height: 30,
            width: 100,
            margin: EdgeInsets.zero,
            onTap: () {
              AlertsUtils().showCustomBottomSheet(
                context: context,
                message: "Private,Public",
                buttonText: "Update",
                initialSelectedText: selectedOption,
                onItemSelected: (value) {
                  onUpdate(value);
                },
              );
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    selectedOption,
                    12,
                    context,
                    color: AppColor().kWhite,
                    fontWeight: FontWeight.w400,
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColor().kWhite),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

// ====================== CUSTOM NOTIFICATION TILE =============================
// =============================================================================

class CustomNotificationTile extends StatelessWidget {
  final String title;
  final String selectedOption;
  final Function(dynamic) onUpdate;

  const CustomNotificationTile({
    super.key,
    required this.title,
    required this.selectedOption,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: customText(title, 12, context),
          trailing: CustomContainer(
            color: AppColor().PURPLE,
            shadow: false,
            borderRadius: 12,
            height: 30,
            width: 100,
            margin: EdgeInsets.zero,
            onTap: () {
              AlertsUtils().showCustomBottomSheet(
                context: context,
                message: "True, False",
                buttonText: "Update",
                initialSelectedText: selectedOption.toString(),
                onItemSelected: (value) {
                  onUpdate(value);
                },
              );
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    selectedOption.toString(),
                    12,
                    context,
                    color: AppColor().kWhite,
                    fontWeight: FontWeight.w400,
                  ),
                  Icon(Icons.arrow_drop_down, color: AppColor().kWhite),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class CustomFlutterToastUtils {
  static void showToast({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 14.0,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: toastLength,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}

// whatapp link view

class WhatsAppLinkPreview extends StatefulWidget {
  final String url;

  const WhatsAppLinkPreview({super.key, required this.url});

  @override
  State<WhatsAppLinkPreview> createState() => _WhatsAppLinkPreviewState();
}

class _WhatsAppLinkPreviewState extends State<WhatsAppLinkPreview> {
  Metadata? _metadata;

  @override
  void initState() {
    super.initState();
    _fetchMeta();
  }

  Future<void> _fetchMeta() async {
    final data = await MetadataFetch.extract(widget.url);
    if (mounted) {
      setState(() {
        _metadata = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_metadata == null) return const SizedBox();

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(widget.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_metadata?.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  _getFullImageUrl(widget.url, _metadata!.image!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            if (_metadata?.title != null)
              Text(
                _metadata!.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (_metadata?.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _metadata!.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              widget.url,
              style: const TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

String _getFullImageUrl(String baseUrl, String rawImageUrl) {
  if (rawImageUrl.startsWith('http')) return rawImageUrl;

  try {
    final uri = Uri.parse(baseUrl);
    final host = uri.origin;
    return '$host${rawImageUrl.startsWith('/') ? '' : '/'}$rawImageUrl';
  } catch (e) {
    return rawImageUrl;
  }
}

// show video player

// ====================== SOCIAL MEDIA BUTTON ==================================
// =============================================================================
class SocialMediaButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback onPressed;

  const SocialMediaButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
