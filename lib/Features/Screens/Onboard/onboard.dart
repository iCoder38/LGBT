// import 'package:lgbt_togo/Features/Screens/Splash/splash.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> onboardingData = [
      {
        'image': AppImage().SLIDER_1,
        'title': Localizer.get(AppText.onboard1Heading.key),
        'subtitle': Localizer.get(AppText.onboard1Message.key),
      },
      {
        'image': AppImage().SLIDER_3,
        'title': Localizer.get(AppText.onboard2Heading.key),
        'subtitle': Localizer.get(AppText.onboard2Message.key),
      },
      {
        'image': AppImage().SLIDER_2,
        'title': Localizer.get(AppText.onboard3Heading.key),
        'subtitle': Localizer.get(AppText.onboard3Message.key),
      },
      {
        'image': AppImage().SLIDER_4,
        'title': Localizer.get(AppText.onboard4Heading.key),
        'subtitle': Localizer.get(AppText.onboard4Message.key),
      },
      {
        'image': AppImage().SLIDER_5,
        'title': Localizer.get(AppText.onboard5Heading.key),
        'subtitle': Localizer.get(AppText.onboard5Message.key),
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          /// PageView for onboarding slides
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return buildPage(
                image: onboardingData[index]['image']!,
                title: onboardingData[index]['title']!,
                subtitle: onboardingData[index]['subtitle']!,
              );
            },
          ),

          /// Top bar with Skip button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      "<< ${Localizer.get(AppText.skip.key)} >>",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 239, 223, 79),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom section (title, subtitle, button, dots)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 30,
                top: 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      customText(
                        onboardingData[_currentPage]['title'] ?? '',
                        18,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      customText(
                        onboardingData[_currentPage]['subtitle'] ?? '',
                        14,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                        isCentered: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade600,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? Localizer.get(AppText.getStartedNow.key)
                          : Localizer.get(AppText.next.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingData.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.cyanAccent
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds each onboarding page
  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
      ],
    );
  }
}
