import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ContentText extends StatelessWidget {
  final String text;

  const ContentText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink(); // agar empty text ho to kuch na dikhao
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: customText(
        text,
        13,
        context,
        color: AppColor().kBlack,
        textAlign: TextAlign.start,
      ),
    );
  }
}
