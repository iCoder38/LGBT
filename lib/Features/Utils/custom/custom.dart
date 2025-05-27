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
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      textAlign: textAlign,
      style: GoogleFonts.montserrat(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
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
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// ====================== APP BAR ==============================================
// =============================================================================
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
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
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
