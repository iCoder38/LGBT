import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Chat/message_bubble.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid.dart';

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
  // image
  File? imageFile;
  bool isImageSelected = false;

  String roomId = '';
  String reverseRoomId = '';

  String loginUserId = '';
  String friendidIs = '';

  String lastMessage = '';

  TextEditingController contTextSendMessage = TextEditingController();
  bool isChatReady = false;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> messageStream;

  bool parentChatDocExists = false;

  // chat tracker
  late String chatId;
  String loginUserNameIs = '';

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

    GlobalUtils().customLog(
      "Login userId: $loginUserId\nFriend Id: $friendidIs\nFriend Name: ${widget.friendName}",
    );

    createAndCheckRoomIDs();
  }

  @override
  void dispose() {
    _resetUnreadCounterOnExit();
    ChatTracker.lastOpenedChatId = chatId;
    super.dispose();
  }

  void _resetUnreadCounterOnExit() {
    chatId = loginUserId.compareTo(friendidIs) < 0
        ? '${loginUserId}_$friendidIs'
        : '${friendidIs}_$loginUserId';

    FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(loginUserId)
        .collection('chats')
        .doc(chatId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  void createAndCheckRoomIDs() async {
    final generatedRoomId = '$loginUserId+$friendidIs';
    final reversedRoomId = '$friendidIs+$loginUserId';
    final chatId = loginUserId.compareTo(friendidIs) < 0
        ? '${loginUserId}_$friendidIs'
        : '${friendidIs}_$loginUserId';

    roomId = generatedRoomId;
    reverseRoomId = reversedRoomId;

    FirebaseFirestore.instance
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
            onPressed: () {
              Navigator.pop(context);
            },
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
          color: Colors.transparent,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: messageStream, // ✅ Pre-initialized stream
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
        sendMessageuIKIT(), // ✅ Input bar remains pinned at bottom
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
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                        maxWidth: double.infinity,
                      ),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: Image.file(
                            imageFile!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          /*setState(() {
                            imageFile = null;
                            isImageSelected = false;
                          });*/
                        },
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

                    /* final result = await checkUserSubscriptionStatus();

                    if (result['isSubscribed']) {
                      final subInfo = result['data'];
                      customLog("Subscribed till: ${subInfo['tillTimestamp']}");
                      _handleImageSelection(
                        context,
                        subInfo['tillTimestamp'].toString(),
                      );
                    } else {
                      customLog("Not subscribed");
                      openPopupIfUserIsNotPremium(context);
                    }*/
                  },
                  icon: Icon(Icons.add, color: AppColor().kWhite),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardAppearance: Brightness.dark,
                      keyboardType: TextInputType.text,
                      controller: contTextSendMessage,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(color: AppColor().kWhite),
                      decoration: const InputDecoration(
                        hintText: 'write something',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: IconButton(
                      onPressed: () {
                        if (isImageSelected) {
                          GlobalUtils().customLog("User selected image");

                          // uploadChatImageWB(); // ← Uncomment if you're uploading
                        } else {
                          if (contTextSendMessage.text.isNotEmpty) {
                            sendMessageViaFirebase(
                              contTextSendMessage.text.trim(),
                              'iv',
                            );
                            lastMessage = contTextSendMessage.text.trim();
                            contTextSendMessage.clear();
                          }
                        }
                      },
                      icon: Icon(Icons.send, color: Colors.white),
                    ),

                    /*child: IconButton(
                      onPressed: () {
                        if (isImageSelected) {
                          GlobalUtils().customLog("User select image");

                          // uploadChatImageWB();
                        } else {
                          if (contTextSendMessage.text.isNotEmpty) {
                            sendMessageViaFirebase(
                              contTextSendMessage.text.toString().toString(),
                              'iv',
                            );
                            lastMessage = contTextSendMessage.text.toString();
                            contTextSendMessage.text = "";
                          }
                        }
                      },
                      icon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.send),
                      ),
                      /*AppImage().svgImage(
                        'send',
                        18.0,
                        18.0,
                        colorFilter: ColorFilter.mode(
                          AppColor().kWhiteColor,
                          BlendMode.srcIn,
                        ),
                      ),*/
                    ),*/
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

    chatId = currentUserId.compareTo(friendId) < 0
        ? '${currentUserId}_$friendId'
        : '${friendId}_$currentUserId';

    final chatUsers = [currentUserId, friendId];

    // Create parent doc only once
    if (!parentChatDocExists) {
      final docRef = FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId);

      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({'users': chatUsers});
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
      'users': chatUsers,
    };

    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(chatData);

    await _updateDialogsAsync(
      chatId,
      currentUserId,
      friendId,
      encryptedMessage,
      timeStamp,
      chatUsers,
    );
  }

  Future<void> _updateDialogsAsync(
    String chatId,
    String senderId,
    String receiverId,
    String lastMessage,
    int timestamp,
    List<String> users,
  ) async {
    try {
      GlobalUtils().customLog("🔄 Updating dialogs...");

      // Sender dialog
      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
          .doc(senderId)
          .collection('chats')
          .doc(chatId)
          .set({
            'chatId': chatId,
            'receiverId': receiverId,
            'receiverName': widget.friendName,
            'lastMessage': lastMessage,
            'timestamp': timestamp,
            'users': users,
          }, SetOptions(merge: true));

      // Receiver dialog
      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
          .doc(receiverId)
          .collection('chats')
          .doc(chatId)
          .set({
            'chatId': chatId,
            'receiverId': senderId,
            'receiverName': loginUserNameIs,
            'lastMessage': lastMessage,
            'timestamp': timestamp,
            'users': users,
            'unreadCount': FieldValue.increment(1),
          }, SetOptions(merge: true));

      GlobalUtils().customLog("✅ Dialogs updated successfully.");
    } catch (e) {
      GlobalUtils().customLog("❌ Dialog update failed: $e");
    }
  }
}
