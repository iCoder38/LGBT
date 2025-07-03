import 'package:lgbt_togo/Features/Screens/Chat/enlarge_image.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class MessageBubble extends StatelessWidget {
  final String currentUserId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String type;
  final String message;
  final String? attachment;
  final int timeStamp;
  final bool isSent;
  final List<dynamic> readBy;
  final bool isUploading; // for images

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
    required this.isSent,
    required this.readBy,
    this.isUploading = false,
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

    final hasReceiverRead = readBy.contains(receiverId);
    final hasSenderRead = readBy.contains(senderId);
    final hasBothRead = hasReceiverRead && hasSenderRead;

    Icon getTickIcon() {
      if (!isSent) {
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
      } else if (hasBothRead) {
        return const Icon(Icons.done_all, size: 16, color: Colors.blue);
      } else {
        return const Icon(Icons.done, size: 14, color: Colors.grey);
      }
    }

    Widget _buildBubbleContent() {
      if (type == "sticker") {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            message,
            width: 140,
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 50),
          ),
        );
      } else if (type == "image") {
        return GestureDetector(
          onTap: () {
            if (!isUploading && message.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImageViewScreen(imageUrl: message),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isUploading
                ? Container(
                    width: 180,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Image.network(
                    message,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 180,
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 180,
                      height: 180,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
          ),
        );
      } else {
        return customText(message, 14.0, context, color: AppColor().kWhite);
      }
    }

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
              color: type == "text_message"
                  ? const Color.fromRGBO(31, 43, 66, 1)
                  : Colors.transparent,
              borderRadius: borderRadius,
            ),
            padding: type == "text_message"
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(2),
            child: _buildBubbleContent(),
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
                if (isSender) ...[const SizedBox(width: 4.0), getTickIcon()],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
