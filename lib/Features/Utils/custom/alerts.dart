import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
// import 'package:panara_dialogs/panara_dialogs.dart';

class AlertsUtils {
  Future<String?> showBottomSheetWithTwoBottom({
    required BuildContext context,
    required String message,
    required String yesTitle,
    VoidCallback? onYesTap, // ✅ optional
    VoidCallback? onDismissTap, // ✅ optional
    String? dismissTitle,
    Color? dismissButtonColor,
    Color? yesButtonColor,
  }) async {
    return await showDialog<String>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor().kWhite,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: customText(
                            message,
                            14.0,
                            context,
                            color: AppColor().kBlack,
                            textAlign: TextAlign.center,
                            isCentered: true,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (dismissTitle != null)
                            Expanded(
                              child: CustomContainer(
                                onTap: () {
                                  Navigator.pop(context, 'dismiss');
                                  if (onDismissTap != null) onDismissTap();
                                },
                                color: dismissButtonColor ?? AppColor().kBlack,
                                shadow: true,
                                child: customText(
                                  dismissTitle,
                                  14,
                                  context,
                                  color: AppColor().kWhite,
                                ),
                              ),
                            ),
                          Expanded(
                            child: CustomContainer(
                              onTap: () {
                                Navigator.pop(context, 'yes');
                                if (onYesTap != null) onYesTap();
                              },
                              color: yesButtonColor ?? AppColor().RED,
                              shadow: true,
                              child: customText(
                                yesTitle,
                                14,
                                context,
                                color: AppColor().kWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: customText(
                            "Tap anywhere to dismiss popup.",
                            10,
                            context,
                            color: AppColor().GRAY,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showExceptionPopup({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
  }) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  // height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: customText(
                            message,
                            14.0,
                            context,
                            color: AppColor().kWhite,
                            textAlign: TextAlign.center,
                            isCentered: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: customText(
                            "Tap anywhere to dismiss popup.",
                            10,
                            context,
                            color: AppColor().GRAY,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /*const SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () {
                    // dismissAlert(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      color: AppColor().kBlack,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: customText(
                            'Dismiss',
                            16,
                            context,

                            color: AppColor().kWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        );
      },
    );
  }

  void showCustomBottomSheet({
    required BuildContext context,
    required String message, // Comma-separated values
    required String buttonText, // Button label
    required Function(String selectedItem)? onItemSelected, // Callback
    String? initialSelectedText, // Optional: preselect item(s)
    Color? backgroundColor,
    bool isMultiple = false, // Multiple selection support
  }) async {
    final List<String> messageLines = message
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    int? selectedIndex;
    Set<int> selectedIndexes = {};

    // Initial selection logic
    if (initialSelectedText != null && initialSelectedText.isNotEmpty) {
      if (isMultiple) {
        final List<String> initialSelectedList = initialSelectedText
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        for (int i = 0; i < messageLines.length; i++) {
          if (initialSelectedList.contains(messageLines[i])) {
            selectedIndexes.add(i);
          }
        }
      } else {
        selectedIndex = messageLines.indexWhere(
          (element) => element == initialSelectedText,
        );
      }
    }

    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: backgroundColor ?? AppColor().kWhite,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: messageLines.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final line = entry.value;

                                    final isSelected = isMultiple
                                        ? selectedIndexes.contains(index)
                                        : selectedIndex == index;

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isMultiple) {
                                            if (selectedIndexes.contains(
                                              index,
                                            )) {
                                              selectedIndexes.remove(index);
                                            } else {
                                              selectedIndexes.add(index);
                                            }
                                          } else {
                                            selectedIndex = index;
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: customText(
                                                "• $line",
                                                16,
                                                context,
                                                color: isSelected
                                                    ? Colors.green
                                                    : AppColor().kBlack,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            CustomButton(
                              text: buttonText,
                              color: AppColor().PRIMARY_COLOR,
                              height: 50,
                              textColor: AppColor().kWhite,
                              onPressed: () {
                                if (isMultiple) {
                                  if (selectedIndexes.isNotEmpty) {
                                    final selectedItems = selectedIndexes
                                        .map((index) => messageLines[index])
                                        .toList();
                                    final selectedString = selectedItems.join(
                                      ', ',
                                    );
                                    Navigator.pop(context);
                                    if (onItemSelected != null) {
                                      onItemSelected(selectedString);
                                    }
                                  } else {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (selectedIndex != null) {
                                    final selectedItem =
                                        messageLines[selectedIndex!];
                                    Navigator.pop(context);
                                    if (onItemSelected != null) {
                                      onItemSelected(selectedItem);
                                    }
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: customText(
                                isMultiple
                                    ? "Tap multiple items to mark ✓"
                                    : "Tap one item to mark ✓",
                                10,
                                context,
                                color: AppColor().GRAY,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showCustomAlertWithTextfield({
    required BuildContext context,
    required String title,
    required String buttonText,
    required Function(String) onConfirm,
    String? hintText,
  }) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText ?? 'Enter name,email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close the dialog
                  onConfirm(controller.text); // return the input
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: customText(
                  buttonText,
                  16,
                  context,
                  color: AppColor().kWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showLoaderUI({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
    Color? backgroundColor,
    double borderRadius = 12.0,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
  }) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColor().PRIMARY_COLOR,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: SpinKitPouringHourGlass(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    customText(
                      title,
                      14.0,
                      context,
                      fontWeight: FontWeight.w400,
                      color: AppColor().kWhite,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> CustomInputSheet({
    required BuildContext context,
    required String title,
    required String buttonText,
    String? imageAsset,
    required Function(String) onSubmit,
  }) async {
    final TextEditingController _controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // important for keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageAsset != null) ...[
                  Image.asset(
                    imageAsset,
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                ],
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // TextField
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Button
                ElevatedButton(
                  onPressed: () {
                    String inputText = _controller.text.trim();
                    if (inputText.isNotEmpty) {
                      onSubmit(inputText);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// modern alert
class ReusableModernButton extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final PanaraDialogType dialogType;
  final Color buttonColor;

  const ReusableModernButton({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.dialogType,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModernDialog(context, title, message, buttonLabel, dialogType);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        backgroundColor: buttonColor,
      ),
      child: Text(buttonLabel, style: const TextStyle(color: Colors.white)),
    );
  }

  void showModernDialog(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    PanaraDialogType type,
  ) {
    PanaraInfoDialog.show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      onTapDismiss: () {
        Navigator.pop(context);
      },
      panaraDialogType: type,
    );
  }
}
