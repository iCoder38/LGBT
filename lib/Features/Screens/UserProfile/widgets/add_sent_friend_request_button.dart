import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/widgets.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AddSentFriendButton extends StatefulWidget {
  final String receiverId; // jis user ko request bhejni hai
  final EdgeInsets padding; // optional padding

  const AddSentFriendButton({
    super.key,
    required this.receiverId,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  State<AddSentFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<AddSentFriendButton> {
  bool _isRequestSent = false;
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isRequestSent || _isLoading) return;

    // 🔴 UI turant change
    setState(() {
      _isRequestSent = true;
      _isLoading = true;
    });

    try {
      final userData = await UserLocalStorage.getUserData();

      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadSendRequest(
          action: ApiAction().FRIEND_REQUEST,
          senderId: userData['userId'].toString(),
          receiverId: widget.receiverId,
          status: '1',
        ),
      );

      GlobalUtils().customLog("Friend request response: $response");

      if (response['status'].toString().toLowerCase() == "success") {
        CustomFlutterToastUtils.showToast(
          message: response['msg'],
          backgroundColor: AppColor().GREEN,
        );
      } else {
        // ❌ rollback agar fail ho
        setState(() => _isRequestSent = false);
        AlertsUtils().showExceptionPopup(
          context: context,
          message: response['msg'].toString(),
        );
      }
    } catch (e) {
      // ❌ rollback agar error ho
      setState(() => _isRequestSent = false);
      GlobalUtils().customLog("Friend request error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTap: _handleTap,
        child: AddFriendBadge(
          text: _isRequestSent ? "Sent" : "Add Friends",
          backgroundColor: _isRequestSent ? Colors.orange : AppColor().PURPLE,
          borderColor: Colors.transparent,
        ),
      ),
    );
  }
}
