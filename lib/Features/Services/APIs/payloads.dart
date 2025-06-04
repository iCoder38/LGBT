class ApiPayloads {
  static Map<String, dynamic> CommonPayloadWithUserId(String userId) {
    return {'userId': userId};
  }

  // ========================= CHECK USER ======================================
  static Map<String, dynamic> CheckUserPayload(String userId) {
    return {'userId': userId};
  }

  /*
action:registration
//email:abx@mailinator.com
//firstName:kumar
//contactNumber:1986543218
//password:1234568
//dob:2000-12-26
//bio:HWY i am using
//gender:Male
//interests:Male
//story:YES
//why_are_u_here:noting
//thought_of_day:Good
//cityname:NOIDA
 */
  // ========================= REGISTRATION ====================================
  static Map<String, dynamic> PayloadRegistration({
    required String action,
    required String email,
    required String firstName,
    required String contactNumber,
    required String password,
  }) {
    return {
      'action': action,
      'email': email,
      'firstName': firstName,
      'contactNumber': contactNumber,
      'password': password,
    };
  }
}
