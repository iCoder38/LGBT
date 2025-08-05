// import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

Widget buildTextFieldTitle(context, String title, bool isMandatory) {
  return Column(
    children: [
      const SizedBox(height: 20),
      Row(
        children: [
          const SizedBox(width: 16.0),
          customText(
            isMandatory == true ? '$title*' : title,
            14,
            context,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    ],
  );
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/////////////// TEXTFIELD
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool secureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? initialText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? padding; // ✅ Optional padding

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.secureText = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
    this.initialText,
    this.inputFormatters,
    this.padding, // ✅ Added to constructor
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();

    if (widget.initialText != null && widget.controller == null) {
      _internalController.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          widget.padding ??
          const EdgeInsets.only(left: 14.0, right: 14.0, top: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: TextFormField(
          obscureText: widget.secureText,
          controller: _internalController,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            labelText: widget.labelText,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters ?? [],
        ),
      ),
    );
  }
}
