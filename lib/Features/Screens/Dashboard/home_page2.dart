import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class HomePage2Screen extends StatefulWidget {
  const HomePage2Screen({super.key, required this.isBack});
  final bool isBack;
  @override
  State<HomePage2Screen> createState() => _HomePage2ScreenState();
}

class _HomePage2ScreenState extends State<HomePage2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerImageAsset: AppImage().LOGO,
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        showBackButton: widget.isBack,
      ),
    );
  }
}
