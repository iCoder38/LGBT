// lib/Features/Widgets/language_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

/// Language descriptor used by the sheet.
class LanguageItem {
  final String code; // e.g. 'en', 'fr'
  final String flagAsset; // AppImage().flag_english etc.
  final String labelKey; // AppText.english.key etc.

  const LanguageItem({
    required this.code,
    required this.flagAsset,
    required this.labelKey,
  });
}

/// Shows a reusable language selection bottom sheet and returns the selected language code,
/// or null if user dismissed.
Future<String?> showLanguageSelectionSheet(
  BuildContext context, {
  required bool isBack, // keep your original behavior toggle
  List<LanguageItem>? languages, // optional override list
}) async {
  // default languages if not supplied (English + French)
  final items =
      languages ??
      [
        LanguageItem(
          code: 'en',
          flagAsset: AppImage().flag_english,
          labelKey: "English", // <- see note below about keys
        ),
        LanguageItem(
          code: 'fr',
          flagAsset: AppImage().flag_french,
          labelKey: "French",
        ),
      ];

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return LanguageSelectionSheet(isBack: isBack, languages: items);
    },
  );

  // result is the selected language code or null
  return result;
}

/// The actual bottom-sheet widget (internal)
class LanguageSelectionSheet extends StatefulWidget {
  final bool isBack;
  final List<LanguageItem> languages;

  const LanguageSelectionSheet({
    super.key,
    required this.isBack,
    required this.languages,
  });

  @override
  State<LanguageSelectionSheet> createState() => _LanguageSelectionSheetState();
}

class _LanguageSelectionSheetState extends State<LanguageSelectionSheet> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = Localizer.currentLanguage; // current language code
  }

  void _select(String code) {
    setState(() => selectedLanguage = code);
  }

  Future<void> _onContinue() async {
    // Persist language
    await Localizer.setLanguage(selectedLanguage);

    // show toast / feedback
    CustomFlutterToastUtils.showToast(
      message: Localizer.get(AppText.updated.key),
      backgroundColor: AppColor().GREEN,
    );

    // close sheet and return language code
    if (!mounted) return;
    Navigator.of(context).pop(selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    // Sheet height: adapt to keyboard when isScrollControlled
    final media = MediaQuery.of(context);
    final sheetMaxHeight = media.size.height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: sheetMaxHeight),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: media.viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            Localizer.get(AppText.preferedLanguage.key),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColor().kBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Localizer.get(AppText.preferedLanguageAlert.key),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColor().GRAY),
          ),
          const SizedBox(height: 20),

          // Language list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.languages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final item = widget.languages[index];
                final label = Localizer.get(item.labelKey);
                final isSelected = selectedLanguage == item.code;

                return GestureDetector(
                  onTap: () => _select(item.code),
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor().PRIMARY_COLOR.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColor().PRIMARY_COLOR
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          item.flagAsset,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor().kBlack,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColor().PRIMARY_COLOR
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor().PRIMARY_COLOR,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                Localizer.get(AppText.continueB.key),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Optional: cancel/back area (keeps original isBack behavior)
          if (widget.isBack)
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                Localizer.get(AppText.cancel.key),
                style: TextStyle(color: AppColor().GRAY),
              ),
            ),
        ],
      ),
    );
  }
}
