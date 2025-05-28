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
}
