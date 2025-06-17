class UserModel {
  final String firstName;
  final String email;
  final String contactNumber;
  final String bImage;
  final String profilePicture;

  UserModel({
    required this.firstName,
    required this.email,
    required this.contactNumber,
    required this.bImage,
    required this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      bImage: json['BImage'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'email': email,
      'contactNumber': contactNumber,
      'BImage': bImage,
      'profile_picture': profilePicture,
    };
  }
}
