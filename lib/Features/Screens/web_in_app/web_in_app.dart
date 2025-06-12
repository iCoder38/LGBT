import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class WebInAppScreen extends StatefulWidget {
  const WebInAppScreen({super.key, required this.URL});

  final String URL;

  @override
  State<WebInAppScreen> createState() => _WebInAppScreenState();
}

class _WebInAppScreenState extends State<WebInAppScreen> {
  // web
  late final WebViewController _controllerWeb;

  @override
  void initState() {
    super.initState();

    _controllerWeb = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.URL.toString()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.web.key),
        showBackButton: true,
      ),
      body: WebViewWidget(controller: _controllerWeb),
    );
  }
}
