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
