import 'package:intl/intl.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/custom/alerts.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.completeProfile.key),
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 10), // Spacer(),
              CustomTextField(
                readOnly: true,
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.dob.key),
                controller: _controller.contDOB,
                suffixIcon: Icons.calendar_month,
                onTap: () async {
                  final selectedDate = await GlobalUtils().pickDateOfBirth(
                    context,
                  );
                  if (selectedDate != null) {
                    _controller.contDOB.text = DateFormat(
                      GlobalUtils().APP_DATE_FORMAT,
                    ).format(selectedDate);
                  }
                },
              ),
              SizedBox(height: 4),
              CustomTextField(
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
                    onItemSelected: (String selectedItem) {
                      GlobalUtils().customLog("✅ You selected: $selectedItem");
                      _controller.contGender.text = selectedItem;
                    },
                  );
                },
              ),
              SizedBox(height: 4),
              CustomTextField(
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
                    onItemSelected: (String selectedItem) {
                      GlobalUtils().customLog("✅ You selected: $selectedItem");
                      _controller.contSexOrientation.text = selectedItem;
                    },
                  );
                },
              ),
              SizedBox(height: 4),
              CustomTextField(
                paddingLeft: 16,
                paddingRight: 16,
                hintText: Localizer.get(AppText.location.key),
                controller: _controller.contLocation,
                suffixIcon: Icons.location_searching,
              ),
              SizedBox(height: 4),
              CustomTextField(
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
                    onItemSelected: (String selectedItem) {
                      GlobalUtils().customLog("✅ You selected: $selectedItem");
                      _controller.contInterestIn.text = selectedItem;
                    },
                  );
                },
              ),
              CustomButton(
                text: Localizer.get(AppText.submit.key),
                color: AppColor().PRIMARY_COLOR,
                textColor: AppColor().kWhite,
                borderRadius: 30,
              ),

              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // local widgets
}
