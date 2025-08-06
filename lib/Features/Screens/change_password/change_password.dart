import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lgbt_togo/Features/Screens/change_password/controller.dart';
import 'package:lgbt_togo/Features/Screens/change_password/widget.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart'
    hide CustomTextField;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final ChangePasswordFormController _controller =
      ChangePasswordFormController();

  var storeLoginUserData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.changePassword.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      body: _UIBGImage(),
    );
  }

  Widget _UIBGImage() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // buildTextFieldTitle(context, 'Current password', true),
            CustomTextField(
              secureText: true,
              controller: _controller.contOldPassword,
              labelText: 'Current password',
              validator: (value) =>
                  _controller.validateOldPassword(value ?? ""),
            ),
            // buildTextFieldTitle(context, 'New password', true),
            CustomTextField(
              secureText: true,
              controller: _controller.contPassword,
              labelText: 'New password',
              validator: (value) => _controller.validatePassword(value ?? ""),
            ),
            // buildTextFieldTitle(context, 'Confirm password', true),
            CustomTextField(
              secureText: true,
              controller: _controller.contConfirmPassword,
              labelText: 'Confirm password',
              validator: (value) =>
                  _controller.validateConfirmPassword(value ?? ""),
            ),
            CustomButton(
              text: Localizer.get(AppText.submit.key),
              color: AppColor().kNavigationColor,
              textColor: Colors.white,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  callChangePasswordWB();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // api
  Future<void> callChangePasswordWB() async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    var payload = {
      "action": "changepassword",
      "userId": userData['userId'].toString(),
      "oldPassword": _controller.contOldPassword.text.toString(),
      "newPassword": _controller.contConfirmPassword.text.toString(),
    };
    GlobalUtils().customLog(payload);

    try {
      final response = await callCommonNetwordApi(payload);
      GlobalUtils().customLog(response);

      if (response['status'].toString().toLowerCase() == "success") {
        _controller.contOldPassword.text = "";
        _controller.contPassword.text = "";
        _controller.contConfirmPassword.text = "";

        // dismiss keyboard
        FocusScope.of(context).requestFocus(FocusNode());
        // dismiss alert
        Navigator.pop(context);
        // toast
        Fluttertoast.showToast(
          msg: response['msg'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // dismiss keyboard
        FocusScope.of(context).requestFocus(FocusNode());
        // dismiss alert
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: response['msg'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // showExceptionPopup(context: context, message: e.toString());
    } finally {
      // customLog('Finally');
    }
  }
}

Future<Map<String, dynamic>> callCommonNetwordApi(
  Map<String, String> data,
) async {
  // customLog("Payload: $data");
  try {
    final response = await http.post(
      Uri.parse(BaseURL().baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: data,
    );

    if (kDebugMode) {
      print("Service: HTTP response status: ${response.statusCode}");
    }

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {
        'success': false,
        'alertMessage': 'Error: ${response.statusCode}',
      };
    }
  } catch (error) {
    if (kDebugMode) {
      print("Service: Error occurred: $error");
    }
    return {'success': false, 'alertMessage': 'Error occurred: $error'};
  }
}
