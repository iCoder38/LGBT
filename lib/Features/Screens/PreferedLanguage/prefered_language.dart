import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, required this.isBack});

  final bool isBack;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedLanguage = Localizer.currentLanguage;

  void selectLanguage(String langCode) async {
    setState(() {
      selectedLanguage = langCode;
      GlobalUtils().customLog("Language selector: $selectedLanguage");
    });

    await Localizer.setLanguage(langCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: customText(
          Localizer.get(AppText.preferedLanguage.key),
          16,
          context,
          color: AppColor().kWhite,
        ),
        // leading: widget.isBack
        //     ? Icon(Icons.menu, color: AppColor().kWhite)
        //     : SizedBox(),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(AppImage().BG_1, fit: BoxFit.cover),

          // Content with dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    Localizer.get(AppText.preferedLanguageAlert.key),
                    14,
                    context,
                    color: AppColor().kWhite,
                    isCentered: true,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // English option
                  LanguageOptionTile(
                    flagAsset: AppImage().flag_english,
                    language: 'ENGLISH',
                    isSelected: selectedLanguage == 'en',
                    onTap: () => selectLanguage('en'),
                  ),
                  const SizedBox(height: 16),

                  // French option
                  LanguageOptionTile(
                    flagAsset: AppImage().flag_french,
                    language: 'FRENCH',
                    isSelected: selectedLanguage == 'fr',
                    onTap: () => selectLanguage('fr'),
                  ),
                  const SizedBox(height: 40),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget.isBack == true) {
                          CustomFlutterToastUtils.showToast(
                            message: Localizer.get(AppText.updated.key),
                            backgroundColor: AppColor().GREEN,
                          );

                          await Localizer.setLanguage(selectedLanguage);
                          // NavigationUtils.pushTo(context, DashboardScreen());
                          _scaffoldKey.currentState?.openDrawer();
                        } else {
                          // Ensure selectedLanguage is saved
                          await Localizer.setLanguage(selectedLanguage);
                          NavigationUtils.pushTo(context, LoginScreen());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: customText(
                        Localizer.get(AppText.continueB.key),
                        18,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageOptionTile extends StatelessWidget {
  final String flagAsset;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionTile({
    super.key,
    required this.flagAsset,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Flag image
            Image.asset(flagAsset, width: 32, height: 32, fit: BoxFit.cover),
            const SizedBox(width: 12),

            // Language text
            Expanded(
              child: customText(
                language.toUpperCase(),
                18,
                context,
                color: AppColor().kBlack,
                fontWeight: FontWeight.w800,
              ),
            ),

            // Tick icon
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
