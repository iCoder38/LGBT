import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  // ✅ Save all user fields
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('userId', userData['userId']);
    prefs.setString('firstName', userData['firstName'] ?? '');
    prefs.setString('email', userData['email'] ?? '');
    prefs.setString('role', userData['role'] ?? '');
    prefs.setString('address', userData['address'] ?? '');
    prefs.setString('gender', userData['gender'] ?? '');
    prefs.setString('dob', userData['dob'] ?? '');
    prefs.setString('cityname', userData['cityname'] ?? '');
    prefs.setString('interests', userData['interests'] ?? '');
    prefs.setString('bio', userData['bio'] ?? '');
    prefs.setString('story', userData['story'] ?? '');
    prefs.setString('contactNumber', userData['contactNumber'] ?? '');
    prefs.setString('image', userData['image'] ?? '');
    prefs.setString('BImage', userData['BImage'] ?? '');
    prefs.setString('profile_ID_image', userData['profile_ID_image'] ?? '');
    prefs.setString('why_are_u_here', userData['why_are_u_here'] ?? '');
    prefs.setString('thought_of_day', userData['thought_of_day'] ?? '');
    prefs.setString('device', userData['device'] ?? '');
    prefs.setString('deviceToken', userData['deviceToken'] ?? '');
  }

  // ✅ Get all fields as a map
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'userId': prefs.getInt('userId') ?? 0,
      'firstName': prefs.getString('firstName') ?? '',
      'email': prefs.getString('email') ?? '',
      'role': prefs.getString('role') ?? '',
      'address': prefs.getString('address') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'dob': prefs.getString('dob') ?? '',
      'cityname': prefs.getString('cityname') ?? '',
      'interests': prefs.getString('interests') ?? '',
      'bio': prefs.getString('bio') ?? '',
      'story': prefs.getString('story') ?? '',
      'contactNumber': prefs.getString('contactNumber') ?? '',
      'image': prefs.getString('image') ?? '',
      'BImage': prefs.getString('BImage') ?? '',
      'profile_ID_image': prefs.getString('profile_ID_image') ?? '',
      'why_are_u_here': prefs.getString('why_are_u_here') ?? '',
      'thought_of_day': prefs.getString('thought_of_day') ?? '',
      'device': prefs.getString('device') ?? '',
      'deviceToken': prefs.getString('deviceToken') ?? '',
    };
  }

  // ✅ Clear all stored user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('firstName');
    await prefs.remove('email');
    await prefs.remove('role');
    await prefs.remove('address');
    await prefs.remove('gender');
    await prefs.remove('dob');
    await prefs.remove('cityname');
    await prefs.remove('interests');
    await prefs.remove('bio');
    await prefs.remove('story');
    await prefs.remove('contactNumber');
    await prefs.remove('image');
    await prefs.remove('BImage');
    await prefs.remove('profile_ID_image');
    await prefs.remove('why_are_u_here');
    await prefs.remove('thought_of_day');
    await prefs.remove('device');
    await prefs.remove('deviceToken');
  }
}

/*

// save
await UserLocalStorage.saveUserData(response['data']);

// get
final userData = await UserLocalStorage.getUserData();
print(userData['firstName']);

// clear
await UserLocalStorage.clearUserData();


*/
