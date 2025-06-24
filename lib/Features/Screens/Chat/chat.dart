import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Chat/message_bubble.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:uuid/uuid.dart';

class ChatTracker {
  static String? lastOpenedChatId;
}

class FriendlyChatScreen extends StatefulWidget {
  const FriendlyChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  final String friendId;
  final String friendName;

  @override
  State<FriendlyChatScreen> createState() => _FriendlyChatScreenState();
}

class _FriendlyChatScreenState extends State<FriendlyChatScreen> {
  File? imageFile;
  bool isImageSelected = false;

  String loginUserId = '';
  String loginUserNameIs = '';
  String friendidIs = '';
  String lastMessage = '';

  TextEditingController contTextSendMessage = TextEditingController();
  bool isChatReady = false;
  bool parentChatDocExists = false;

  late final String chatId;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> messageStream;
  var userData;

  @override
  void initState() {
    super.initState();
    retrieveUser();
  }

  void retrieveUser() async {
    userData = await UserLocalStorage.getUserData();
    loginUserId = userData['userId'].toString();
    loginUserNameIs = userData['firstName'].toString();
    friendidIs = widget.friendId.toString();

    chatId = loginUserId.compareTo(friendidIs) < 0
        ? '${loginUserId}_$friendidIs'
        : '${friendidIs}_$loginUserId';

    createMessageStreamAndInit();
  }

  void createMessageStreamAndInit() async {
    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(loginUserId)
        .collection('chats')
        .doc(chatId)
        .set({'unreadCount': 0}, SetOptions(merge: true));

    messageStream = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .orderBy('time_stamp', descending: true)
        .limit(20)
        .snapshots();

    setState(() {
      isChatReady = true;
    });
  }

  @override
  void dispose() {
    _resetUnreadCounterOnExit();
    ChatTracker.lastOpenedChatId = chatId;
    super.dispose();
  }

  void _resetUnreadCounterOnExit() {
    FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(loginUserId)
        .collection('chats')
        .doc(chatId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _resetUnreadCounterOnExit();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF1C1C1C),
        appBar: AppBar(
          title: customText("Chats", 16, context, color: AppColor().kWhite),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.chevron_left, color: AppColor().kWhite),
          ),
          backgroundColor: Color(0xFF1C1C1C),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: _UIKit(context),
      ),
    );
  }

  Widget _UIKit(BuildContext context) {
    if (!isChatReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0, bottom: 80),
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: messageStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final data = messages[index].data();

                  return MessageBubble(
                    currentUserId: loginUserId,
                    senderId: data['senderId'],
                    senderName: data['senderName'],
                    receiverId: data['receiverId'],
                    receiverName: data['receiverName'],
                    type: data['type'],
                    message: data['message'],
                    attachment: '',
                    timeStamp: int.parse(data['time_stamp'].toString()),
                  );
                },
              );
            },
          ),
        ),
        sendMessageuIKIT(),
      ],
    );
  }

  Align sendMessageuIKIT() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isImageSelected && imageFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(imageFile!, fit: BoxFit.contain),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() {
                          imageFile = null;
                          isImageSelected = false;
                        }),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            color: AppColor().kBlack,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    // Handle media add if needed
                  },
                  icon: Icon(Icons.add, color: AppColor().kWhite),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardAppearance: Brightness.dark,
                      controller: contTextSendMessage,
                      style: TextStyle(color: AppColor().kWhite),
                      decoration: const InputDecoration(
                        hintText: 'write something',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      if (contTextSendMessage.text.isNotEmpty) {
                        sendMessageViaFirebase(
                          contTextSendMessage.text.trim(),
                          'iv',
                        );
                        lastMessage = contTextSendMessage.text.trim();
                        contTextSendMessage.clear();
                      }
                    },
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessageViaFirebase(String encryptedMessage, String iv) async {
    final currentUserId = loginUserId;
    final friendId = widget.friendId;
    final messageId = const Uuid().v4();
    final timeStamp = GlobalUtils().currentTimeStamp();
    final sortedUsers = [currentUserId, friendId]..sort();

    if (!parentChatDocExists) {
      final docRef = FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({'users': sortedUsers});
      }
      parentChatDocExists = true;
    }

    final chatData = {
      'messageId': messageId,
      'senderId': currentUserId,
      'senderName': loginUserNameIs,
      'receiverId': friendId,
      'receiverName': widget.friendName,
      'message': encryptedMessage,
      'iv': iv,
      'time_stamp': timeStamp,
      'type': 'text_message',
      'users': sortedUsers,
    };

    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(chatData);

    await checkAndUpdateDialog(
      senderId: currentUserId,
      senderName: loginUserNameIs,
      receiverId: friendId,
      receiverName: widget.friendName,
      lastMessage: encryptedMessage,
      timestamp: timeStamp,
    );
  }

  Future<void> checkAndUpdateDialog({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String lastMessage,
    required int timestamp,
  }) async {
    try {
      final sortedIds = [senderId, receiverId]..sort();
      final chatId = "${sortedIds[0]}_${sortedIds[1]}";

      final dialogRef = FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
          .doc(chatId);

      await dialogRef.set({
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'users': sortedIds,
      }, SetOptions(merge: true));

      GlobalUtils().customLog("✅ Dialog saved or updated: $chatId");
    } catch (e) {
      GlobalUtils().customLog("❌ Failed to update dialog: $e");
    }
  }
}
