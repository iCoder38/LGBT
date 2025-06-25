import 'package:lgbt_togo/Features/Screens/Chat/enlarge_image.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class MessageBubble extends StatelessWidget {
  final String currentUserId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String type; // 'text' or 'image'
  final String message;
  final String? attachment;
  final int timeStamp;
  final bool isSent; // ✅ NEW

  const MessageBubble({
    super.key,
    required this.currentUserId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.message,
    this.attachment,
    required this.timeStamp,
    required this.isSent, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) {
    final isSender = senderId == currentUserId;
    final alignment = isSender ? Alignment.bottomRight : Alignment.bottomLeft;
    final margin = isSender
        ? const EdgeInsets.only(right: 10, left: 40.0, top: 12.0)
        : const EdgeInsets.only(right: 40, left: 10.0, top: 12.0);
    final borderRadius = isSender
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topRight: Radius.circular(16),
          );

    return Column(
      crossAxisAlignment: isSender
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: alignment,
          child: Container(
            margin: margin,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(31, 43, 66, 1),
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.all(16),
            child: type == "image"
                ? GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullImageViewScreen(imageUrl: attachment ?? ''),
                        ),
                      );
                    },
                    child: _buildImageContent(context),
                  )
                : customText(message, 14.0, context, color: AppColor().kWhite),
          ),
        ),
        Align(
          alignment: isSender ? Alignment.bottomRight : Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 4.0),
            child: Row(
              mainAxisAlignment: isSender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                customText(
                  GlobalUtils.convertTimeStampTo12HourFormat(timeStamp),
                  8,
                  context,
                  color: AppColor().GRAY,
                ),
                if (isSender) ...[
                  const SizedBox(width: 4.0),
                  isSent
                      ? const Icon(Icons.check, size: 14, color: Colors.grey)
                      : const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: AppColor().kBlack),
      child: Column(
        children: [
          CustomContainer(
            margin: const EdgeInsets.only(left: 8),
            color: AppColor().kBlack,
            shadow: false,
            height: 80,
            width: 140,
            child: Row(
              children: [
                const SizedBox(width: 8),
                customText("Image", 12.0, context, color: AppColor().kWhite),
              ],
            ),
          ),
          if (message.isNotEmpty)
            CustomContainer(
              margin: const EdgeInsets.only(top: 1),
              width: 120,
              color: AppColor().kBlack,
              shadow: false,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: customText(message, 10, context),
              ),
            ),
        ],
      ),
    );
  }
}
