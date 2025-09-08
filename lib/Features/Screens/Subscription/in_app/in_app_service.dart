import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> validateAndroidOnServer({
  required String purchaseToken,
  String packageName = 'com.dev.android.lgbt',
  String productId = 'premium_monthly_09',
  String phpUrl =
      'https://thebluebamboo.in/APIs/Anamak_APIs/lgbt_in_app_android_receipt.php',
}) async {
  final phpEndpoint = Uri.parse(phpUrl);

  final res = await http.post(
    phpEndpoint,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'packageName': packageName,
      'productId': productId,
      'purchaseToken': purchaseToken,
    }),
  );
  print('PHP RESP ${res.statusCode}: ${res.body}');

  if (res.statusCode != 200 || res.body.isEmpty) return false;
  final m = jsonDecode(res.body);
  return m is Map && m['success'] == true && m['data']?['isSubscribed'] == true;
}
