import 'package:fluttertoast/fluttertoast.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

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
  final Color? borderColor; // New optional border color
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
                  width: 1.5,
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
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final IconData? backIcon;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;
  final VoidCallback? onBackPressed;

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
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColor().kNavigationColor,
      elevation: 0,
      centerTitle: centerTitle,
      title: customText(
        title,
        16,
        context,
        fontWeight: FontWeight.w600,
        color: AppColor().kWhite,
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(backIcon ?? Icons.arrow_back, color: titleColor),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!(); // Custom behavior
                } else {
                  Navigator.pop(context); // Default fallback
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
      child: Padding(
        padding: const EdgeInsets.only(right: 14.0, left: 14.0, top: 8.0),
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

class CustomFeedPostCard extends StatelessWidget {
  final String userName;
  final String userImagePath;
  final String timeAgo;
  final String feedImagePath;
  final String totalLikes;
  final String totalComments;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onUserTap;
  final VoidCallback onCardTap;
  final VoidCallback onMenuTap;

  const CustomFeedPostCard({
    super.key,
    required this.userName,
    required this.userImagePath,
    required this.timeAgo,
    required this.feedImagePath,
    required this.totalLikes,
    required this.totalComments,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onUserTap,
    required this.onCardTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: feedImagePath.startsWith('http')
                ? Image.network(feedImagePath, fit: BoxFit.cover)
                : Image.asset(feedImagePath, fit: BoxFit.cover),
          ),
          CustomFeedLikeCommentShare(
            context: context,
            totalLikes: totalLikes,
            totalComments: totalComments,
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
  required VoidCallback onClick,
  required VoidCallback onMorePressed,
}) {
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
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 50,
                width: 50,
                child: imagePath.startsWith('http')
                    ? Image.network(imagePath, fit: BoxFit.cover)
                    : Image.asset(imagePath, fit: BoxFit.cover),
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
                text2: "shared a new photo",
                color2: AppColor().GRAY,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                onTap2: onClick,
              ),
              const SizedBox(height: 4),
              customText(timeAgo, 10, context, color: AppColor().GRAY),
            ],
          ),
        ),
        IconButton(
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
}) {
  return CustomContainer(
    color: AppColor().TRANSPARENT,
    shadow: false,
    margin: EdgeInsets.zero,
    borderRadius: 0,
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: onLikeTap,
                icon: const Icon(Icons.favorite_border),
              ),
              customText("$totalLikes likes", 12, context),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: onCommentTap,
                icon: const Icon(Icons.comment_outlined),
              ),
              customText("$totalComments comments", 12, context),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              IconButton(onPressed: onShareTap, icon: const Icon(Icons.share)),
              customText("Share", 12, context),
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
    borderRadius: BorderRadius.circular(14.0),
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
      errorWidget: (context, url, error) => const Icon(Icons.error),
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

  const CustomUserTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                message: "Friends,Only me,Nobody",
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

// ====================== CUSTOM NOTIFICATION TILE ==================================
// =============================================================================

class CustomNotificationTile extends StatelessWidget {
  final String title;
  final bool selectedOption;
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
                message: "true, false",
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
