import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AlertsUtils {
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
    String? initialSelectedText, // Optional: preselect item
    Color? backgroundColor,
  }) async {
    final List<String> messageLines = message
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    int? selectedIndex = initialSelectedText != null
        ? messageLines.indexWhere((element) => element == initialSelectedText)
        : null;

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
                          children: [
                            ...messageLines.asMap().entries.map((entry) {
                              final index = entry.key;
                              final line = entry.value;
                              final isSelected = selectedIndex == index;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
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
                            }),

                            const SizedBox(height: 16),

                            CustomButton(
                              text: buttonText,
                              color: AppColor().PRIMARY_COLOR,
                              height: 50,
                              textColor: AppColor().kWhite,
                              onPressed: () {
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
                              },
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: customText(
                                "Tap on one item to mark ✓",
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
}
