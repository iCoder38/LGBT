import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.completeProfile.key),
        showBackButton: true,
      ),
      body: _UIKitWithBG(context),
    );
  }

  Widget _UIKitWithBG(BuildContext context) {
    return Stack(
      children: [
        // 🔳 Background image
        Positioned.fill(child: Image.asset(AppImage().BG_1, fit: BoxFit.cover)),
        _UIKIT(context),
      ],
    );
  }

  Widget _UIKIT(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // what your story
              CustomTextField(
                headerTitle: Localizer.get(AppText.whatsYourStory.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,
                minLines: 2,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                hintText: Localizer.get(AppText.whatsYourStory.key),
                controller: _controller.contWhatsYourStory,
                validator: (p0) => _controller.validateWhatsYourStory(p0 ?? ""),
              ),

              _spaceBetweenFieldsUIKit(12.0),

              // why are you here
              CustomTextField(
                headerTitle: Localizer.get(AppText.whyAreYouHere.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,

                hintText: Localizer.get(AppText.whyAreYouHere.key),
                controller: _controller.contWhyAreYouHere,
                validator: (p0) => _controller.validateWhyAreYourHere(p0 ?? ""),
              ),

              _spaceBetweenFieldsUIKit(12.0),

              // what you like
              CustomTextField(
                readOnly: true,
                headerTitle: Localizer.get(AppText.whatDoYouLike.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,
                suffixIcon: Icons.arrow_drop_down,
                hintText: Localizer.get(AppText.whatDoYouLike.key),
                controller: _controller.contWhatDoYouLike,
                validator: (p0) => _controller.validateWhatYouLike(p0 ?? ""),
                onTap: () {
                  AlertsUtils().showCustomBottomSheet(
                    context: context,
                    isMultiple: true,
                    message:
                        "Sports, Hiking, Biking, Working out, Traveling, Exploring cities, Painting/Drawing, Watching movies, Listening Music, Playing Instruments, Puzzle solving, Video games, Reading Books, Photography, Yoga/Meditation, Camping, Cooking and baking, Making new friends, Pet care, Gardening, Learning languages",
                    initialSelectedText: _controller.contWhatDoYouLike.text,
                    buttonText: Localizer.get(AppText.submit.key),
                    onItemSelected: (s) {
                      _controller.contWhatDoYouLike.text = s.toString();
                    },
                  );
                },
              ),

              _spaceBetweenFieldsUIKit(12.0),

              // YOUR BIOGRAPHY
              CustomTextField(
                headerTitle: Localizer.get(AppText.biography.key),
                titleLeftPadding: 22,
                footerText: Localizer.get(AppText.writeYourBiography.key),
                paddingLeft: 16,
                paddingRight: 16,
                minLines: 2,
                maxLines: 8,
                hintText: Localizer.get(AppText.biography.key),
                controller: _controller.contYourBiography,
                validator: (p0) => _controller.validateBiography(p0 ?? ""),
              ),
              _spaceBetweenFieldsUIKit(12.0),

              // THOUGHT OF THE DAY
              CustomTextField(
                headerTitle: Localizer.get(AppText.thought.key),
                titleLeftPadding: 22,
                footerText: Localizer.get(AppText.thoughtMessage.key),
                paddingLeft: 16,
                paddingRight: 16,
                minLines: 2,
                maxLines: 8,
                hintText: Localizer.get(AppText.thought.key),
                controller: _controller.contThoughtOfTheDay,
                validator: (p0) =>
                    _controller.validateThoughtOfTheDay(p0 ?? ""),
              ),
              _spaceBetweenFieldsUIKit(12.0),

              // CURRENT CITY
              CustomTextField(
                headerTitle: Localizer.get(AppText.currentCity.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.currentCity.key),
                controller: _controller.contCurrentCity,
                validator: (p0) => _controller.validateCurrentCity(p0 ?? ""),
              ),
              _spaceBetweenFieldsUIKit(12.0),

              // I AM
              CustomTextField(
                readOnly: true,
                headerTitle: Localizer.get(AppText.iAm.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,
                suffixIcon: Icons.arrow_drop_down,
                hintText: Localizer.get(AppText.iAm.key),
                controller: _controller.contIAM,
                validator: (p0) => _controller.validateIAM(p0 ?? ""),
                onTap: () {
                  AlertsUtils().showCustomBottomSheet(
                    context: context,
                    message:
                        "Lesbian,Transsexual,Transgender,Heterosexual,Homosexual,Bisexual,Asexual,Pansexual,Demisexual,Aromantic,Queer",
                    buttonText: 'Dismiss',
                    initialSelectedText: _controller.contIAM.text,
                    onItemSelected: (selectedItem) {
                      _controller.contIAM.text = selectedItem;
                    },
                  );
                },
              ),
              _spaceBetweenFieldsUIKit(12.0),

              // YOU BELIEF
              CustomTextField(
                headerTitle: Localizer.get(AppText.yourBelief.key),
                titleLeftPadding: 22,
                paddingLeft: 16,
                paddingRight: 16,

                hintText: Localizer.get(AppText.yourBelief.key),
                controller: _controller.yourBelief,
              ),
              _spaceBetweenFieldsUIKit(12.0),

              // DOB Field
              CustomTextField(
                headerTitle: Localizer.get(AppText.dob.key),
                readOnly: true,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.dob.key),
                controller: _controller.contDOB,
                suffixIcon: Icons.calendar_month,
                onTap: () async {
                  final now = DateTime.now();
                  final eighteenYearsAgo = DateTime(
                    now.year - 18,
                    now.month,
                    now.day,
                  );

                  // Restrict selection: min=1900, max=18 years ago
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: eighteenYearsAgo,
                    firstDate: DateTime(1900),
                    lastDate: eighteenYearsAgo,
                  );

                  if (selectedDate != null) {
                    _controller.contDOB.text = DateFormat(
                      GlobalUtils().APP_DATE_FORMAT,
                    ).format(selectedDate);
                  }
                },
                validator: (p0) => _controller.validatedob(p0 ?? ""),
              ),

              const SizedBox(height: 4),

              // Gender Field
              /*CustomTextField(
                readOnly: true,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.gender.key),
                controller: _controller.contGender,
                suffixIcon: Icons.arrow_drop_down_outlined,
                onTap: () {
                  AlertsUtils().showCustomBottomSheet(
                    context: context,
                    message: "Male,Female",
                    buttonText: 'Dismiss',
                    onItemSelected: (selectedItem) {
                      _controller.contGender.text = selectedItem;
                    },
                  );
                },
              ),
              const SizedBox(height: 4),*/

              // Sex Orientation
              /*CustomTextField(
                readOnly: true,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.sex.key),
                controller: _controller.contSexOrientation,
                suffixIcon: Icons.arrow_drop_down_outlined,
                onTap: () {
                  AlertsUtils().showCustomBottomSheet(
                    context: context,
                    message: "Sex1,Sex2",
                    buttonText: 'Dismiss',
                    onItemSelected: (selectedItem) {
                      _controller.contSexOrientation.text = selectedItem;
                    },
                  );
                },
              ),
              const SizedBox(height: 4),*/

              // Location
              /*CustomTextField(
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.location.key),
                controller: _controller.contLocation,
                suffixIcon: Icons.location_searching,
              ),
              const SizedBox(height: 4),*/

              // Interest In
              /*CustomTextField(
                readOnly: true,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.interestIn.key),
                controller: _controller.contInterestIn,
                suffixIcon: Icons.arrow_drop_down_outlined,
                onTap: () {
                  AlertsUtils().showCustomBottomSheet(
                    context: context,
                    message: "Interest1,Interes2",
                    buttonText: 'Dismiss',
                    onItemSelected: (selectedItem) {
                      _controller.contInterestIn.text = selectedItem;
                    },
                  );
                },
              ),*/

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: Localizer.get(AppText.submit.key),
                  color: AppColor().PRIMARY_COLOR,
                  textColor: AppColor().kWhite,
                  borderRadius: 30,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      AlertsUtils.showLoaderUI(
                        context: context,
                        title: Localizer.get(AppText.pleaseWait.key),
                      );
                      await Future.delayed(Duration(milliseconds: 400));
                      callCompleteProfile(context);
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spaceBetweenFieldsUIKit(double space) => SizedBox(height: space);

  // ====================== API ================================================
  // ====================== COMPLETE PROFILE
  Future<void> callCompleteProfile(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadCompleteprofile(
        action: ApiAction().EDIT_PROFILE,
        userId: userData['userId'].toString(),
        story: _controller.contWhatsYourStory.text.toString(),
        why_are_u_here: _controller.contWhyAreYouHere.text.toString(),
        thought_of_day: _controller.contThoughtOfTheDay.text.toString(),
        bio: _controller.contYourBiography.text.toString(),
        cityname: _controller.contCurrentCity.text.toString(),
        gender: _controller.contIAM.text.toString(),
        dob: _controller.contDOB.text.toString(),
        interest: _controller.contWhatDoYouLike.text.toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);

      // store locally
      await UserLocalStorage.saveUserData(response['data']);
      await Future.delayed(Duration(microseconds: 400));
      _uploadPost();
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // POST
  Future<Response?> _uploadPost() async {
    final String uploadUrl = BaseURL().baseUrl;

    try {
      final userData = await UserLocalStorage.getUserData();

      // 👇 always Text
      const String finalPostType = "Text";

      final Map<String, dynamic> body = {
        'action': 'postadd',
        'userId': userData['userId'].toString(),
        'postTitle': _controller.contThoughtOfTheDay.text.toString(),
        'postType': finalPostType,
      };

      body.forEach((key, value) {
        GlobalUtils().customLog("📤 $key = $value");
      });

      final response = await _dio.post(
        uploadUrl,
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // Navigator.pop(context);

      GlobalUtils().customLog("📬 RESPONSE STATUS: ${response.statusCode}");
      GlobalUtils().customLog("📬 RESPONSE DATA: ${response.data}");

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && data["status"] == "success") {
        Navigator.pop(context);

        // double back
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["msg"] ?? "Upload failed.")),
        );
      }

      return response;
    } catch (e, stack) {
      Navigator.pop(context);
      GlobalUtils().customLog("❌ ERROR: $e");
      GlobalUtils().customLog("❌ STACK TRACE: $stack");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      return null;
    }
  }

  // update user data in firestore
  /*void _alsoUpdateSettingInFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await UserService().addUserFields(uid, {"gender": "m"});
    GlobalUtils().customLog('✅ Firestore: Complete profile.');
  }*/
}
