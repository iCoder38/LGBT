import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AppColor {
  Color kWhite = Colors.white;
  Color kNavigationColor = parseColor("#DB1C41");
}

Color parseColor(dynamic input) {
  if (input is String) {
    // Handle hex: "#DB1C41" or "DB1C41"
    String hex = input.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add full opacity
    }
    return Color(int.parse(hex, radix: 16));
  } else if (input is List<int> && input.length == 3) {
    // Handle RGB: [R, G, B]
    return Color.fromARGB(255, input[0], input[1], input[2]);
  } else {
    throw ArgumentError('Invalid color input. Use hex string or RGB list.');
  }
}
