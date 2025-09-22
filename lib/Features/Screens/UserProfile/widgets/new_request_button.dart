import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/widgets.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'add_sent_friend_request_button.dart';
// import 'friend_status_button.dart';

class NewRequestButton extends StatefulWidget {
  final String requestId;
  final String receiverId;
  final EdgeInsets padding;

  const NewRequestButton({
    super.key,
    required this.requestId,
    required this.receiverId,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  State<NewRequestButton> createState() => _NewRequestButtonState();
}

class _NewRequestButtonState extends State<NewRequestButton> {
  bool _isLoading = false;
  String _status = "pending"; // "pending", "friends", "none"

  Future<void> _callAcceptRejectWB(BuildContext context, String status) async {
    try {
      setState(() => _isLoading = true);

      final userData = await UserLocalStorage.getUserData();

      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadAcceptReject(
          action: ApiAction().ACCEPT_REJECT,
          userId: userData['userId'].toString(),
          requestId: widget.requestId,
          status: status,
        ),
      );

      GlobalUtils().customLog("Friend request response: $response");

      if (response['status'].toString().toLowerCase() == "success") {
        if (status == "2") {
          // ✅ Accepted → friends
          setState(() => _status = "friends");
        } else if (status == "3") {
          // ❌ Declined → back to Add Friend
          setState(() => _status = "none");
        }

        CustomFlutterToastUtils.showToast(
          message: response['msg'],
          backgroundColor: AppColor().GREEN,
        );
      } else {
        AlertsUtils().showExceptionPopup(
          context: context,
          message: response['msg'].toString(),
        );
      }
    } catch (e) {
      GlobalUtils().customLog("Friend request error: $e");
      AlertsUtils().showExceptionPopup(context: context, message: e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Friends
    if (_status == "friends") {
      return FriendStatusButton(
        padding: widget.padding,
        title: "Friends",
        textColor: AppColor().GREEN,
      );
    }

    // ❌ Back to Add Friend
    if (_status == "none") {
      return AddSentFriendButton(receiverId: widget.receiverId);
    }

    // 🕒 Pending request (default UI)
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          // ✅ Confirm Button (flex:2)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => _callAcceptRejectWB(context, "2"),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : customText(
                          "Confirm",
                          12,
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ❌ Decline Button (flex:1)
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => _callAcceptRejectWB(context, "3"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.close, color: Colors.black, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
