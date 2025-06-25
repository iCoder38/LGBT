import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class _FriendlyChatScreenState extends State<FriendlyChatScreen>
    with WidgetsBindingObserver {
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

  Timer? _typingTimer;

  String currentUserId = '';
  // loginUserId;
  String friendId = '';
  // widget.friendId;

  // store read message in cache
  final Set<String> _markedReadMessages = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    retrieveUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetUnreadCounterOnExit();
    ChatTracker.lastOpenedChatId = chatId;
    updateTypingStatus(chatId, loginUserId, false);
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      updateTypingStatus(chatId, loginUserId, false);
    }
  }

  void retrieveUser() async {
    userData = await UserLocalStorage.getUserData();
    loginUserId = FIREBASE_AUTH_UID();
    // userData['userId'].toString();
    loginUserNameIs = userData['firstName'].toString();
    friendidIs = widget.friendId.toString();

    GlobalUtils().customLog(
      "LoginUserId: $loginUserId\nFriendUserId: $friendidIs",
    );

    // store for chat and dialogs
    currentUserId = loginUserId;
    friendId = friendidIs;
    // return;
    chatId = currentUserId.compareTo(friendidIs) < 0
        ? '${currentUserId}_$friendidIs'
        : '${friendidIs}_$currentUserId';

    await createMessageStreamAndInit();
  }

  createMessageStreamAndInit() async {
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
        .orderBy('time_stamp', descending: false)
        .limit(20)
        .snapshots();

    setState(() {
      isChatReady = true;
    });

    // reset
    await resetUnreadCounter(chatId, loginUserId);
  }

  Future<void> resetUnreadCounter(String chatId, String userId) async {
    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatId);

    final snapshot = await dialogRef.get();

    if (!snapshot.exists) return;

    List<dynamic> counterList = snapshot.data()?['unreadMessageCounter'] ?? [];

    // Remove the user's counter entry from the list
    counterList.removeWhere((entry) => entry['userId'] == userId);

    // Update Firestore with the new list
    await dialogRef.set({
      'unreadMessageCounter': counterList,
    }, SetOptions(merge: true));

    GlobalUtils().customLog("✅ unreadCounter reset for $loginUserId");
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
    if (!isChatReady) {
      return const Scaffold();
    }
    return WillPopScope(
      onWillPop: () async {
        _resetUnreadCounterOnExit();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor().kWhite,
        appBar: AppBar(
          backgroundColor: AppColor().kWhite,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: AppColor().kBlack),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              resetUnreadCounter(chatId, loginUserId);
            },
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.friendName,
                  style: TextStyle(
                    color: AppColor().kBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
                    .doc(chatId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                    return const SizedBox();
                  }

                  final data = snapshot.data!.data()!;
                  final typingMap = data['typingStatus'] ?? {};
                  final isTyping = typingMap[friendId] == true;

                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
                        .doc(friendId)
                        .snapshots(),
                    builder: (context, statusSnap) {
                      if (!statusSnap.hasData ||
                          statusSnap.data!.data() == null) {
                        return const SizedBox();
                      }

                      final status = statusSnap.data!.data()!;
                      final isOnline = status['isOnline'] ?? false;
                      final Timestamp? lastSeen = status['lastSeen'];

                      String statusText = isTyping
                          ? "typing..."
                          : isOnline
                          ? "Online"
                          : lastSeen != null
                          ? "Offline. Last seen: ${_formatTimestamp(lastSeen)}"
                          : "Offline";

                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: isTyping
                                  ? Colors.greenAccent
                                  : isOnline
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: isTyping
                                  ? Colors.greenAccent
                                  : isOnline
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        body: _UIKit(context),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final isToday =
        now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;

    if (isToday) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
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

              // date before chat
              final groupedMessages = groupMessagesByDate(messages);
              final dateKeys = groupedMessages.keys.toList();

              return ListView.builder(
                reverse: true,
                itemCount: dateKeys.length,
                itemBuilder: (context, index) {
                  final dateLabel = dateKeys[index];
                  final dateMessages = groupedMessages[dateLabel]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      ...dateMessages.map((msg) {
                        final data = msg.data();

                        // message reads
                        if (data['receiverId'] == loginUserId &&
                            !(data['readBy'] ?? []).contains(loginUserId) &&
                            !_markedReadMessages.contains(data['messageId'])) {
                          _markedReadMessages.add(data['messageId']);
                          markMessageAsRead(msg);
                        }

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
                          isSent: true,
                          readBy: data['readBy'] ?? [],
                        );
                      }),
                    ],
                  );
                },
              );

              /*ListView.builder(
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
              );*/
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
                          setState(() {
                            imageFile = null;
                            isImageSelected = false;
                          });
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColor().kWhite,
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
            color: AppColor().kWhite,
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    HapticFeedback.lightImpact();
                    final picker = ImagePicker();
                    final pickedImage = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (pickedImage != null) {
                      setState(() {
                        imageFile = File(pickedImage.path);
                        isImageSelected = true;
                      });
                    }
                  },
                  icon: Icon(Icons.add, color: AppColor().kBlack),
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
                      style: TextStyle(color: AppColor().kBlack),
                      decoration: const InputDecoration(
                        hintText: 'write something',
                      ),
                      onChanged: (value) {
                        // ✅ Start typing indication
                        updateTypingStatus(chatId, loginUserId, true);

                        // ✅ Reset typing timer
                        _typingTimer?.cancel();
                        _typingTimer = Timer(const Duration(seconds: 2), () {
                          updateTypingStatus(chatId, loginUserId, false);
                        });
                      },
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
                          uploadChatImageWB(); // ← If using image uploads
                        } else if (contTextSendMessage.text.isNotEmpty) {
                          sendMessageViaFirebase(
                            contTextSendMessage.text.trim(),
                            'iv',
                          );
                          lastMessage = contTextSendMessage.text.trim();
                          contTextSendMessage.clear();

                          // ✅ Clear typing after message sent
                          updateTypingStatus(chatId, loginUserId, false);
                          _typingTimer?.cancel();
                        }
                      },
                      icon: Icon(Icons.send, color: AppColor().kBlack),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // to upload
  void uploadChatImageWB() async {
    if (imageFile == null) return;

    final fileName = "${Uuid().v4()}.jpg";
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(chatId)
        .child(fileName);

    await ref.putFile(imageFile!);
    final imageUrl = await ref.getDownloadURL();

    final timeStamp = GlobalUtils().currentTimeStamp();
    final messageId = Uuid().v4();
    final sortedUsers = [loginUserId, friendidIs]..sort();

    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set({
          'messageId': messageId,
          'senderId': loginUserId,
          'senderName': loginUserNameIs,
          'receiverId': friendidIs,
          'receiverName': widget.friendName,
          'message': imageUrl,
          'type': 'image',
          'time_stamp': timeStamp,
          'users': sortedUsers,
        });

    await checkAndUpdateDialog(
      senderId: loginUserId,
      senderName: loginUserNameIs,
      receiverId: friendidIs,
      receiverName: widget.friendName,
      lastMessage: "[📷 Image]",
      timestamp: timeStamp,
    );

    await incrementUnreadCounter(chatId, friendidIs);

    setState(() {
      imageFile = null;
      isImageSelected = false;
    });
  }

  void sendMessageViaFirebase(String encryptedMessage, String iv) async {
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

    // normal message
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
      'readBy': [FIREBASE_AUTH_UID()],
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

    // update counter
    // 2. ✅ Increment unread counter for the receiver
    await incrementUnreadCounter(chatId, friendId);
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

      // dialog
      await dialogRef.set({
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'users': sortedIds,
        // 'unreadMessageCounter': [
        //   {'userId': receiverId, 'counter': 1},
        // ],
      }, SetOptions(merge: true));

      GlobalUtils().customLog("✅ Dialog saved or updated: $chatId");
    } catch (e) {
      GlobalUtils().customLog("❌ Failed to update dialog: $e");
    }
  }

  // typing status
  void updateTypingStatus(String chatId, String userId, bool isTyping) async {
    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatId);

    await dialogRef.set({
      'typingStatus': {userId: isTyping},
    }, SetOptions(merge: true));
  }

  // update counter
  Future<void> incrementUnreadCounter(String chatId, String receiverId) async {
    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatId);

    final snapshot = await dialogRef.get();

    if (!snapshot.exists) return;

    List<dynamic> counterList = snapshot.data()?['unreadMessageCounter'] ?? [];

    bool found = false;

    // Increment counter for matching userId
    final updatedList = counterList.map((entry) {
      if (entry['userId'] == receiverId) {
        found = true;
        return {'userId': receiverId, 'counter': (entry['counter'] ?? 0) + 1};
      }
      return entry;
    }).toList();

    // If receiverId wasn't found, add new entry
    if (!found) {
      updatedList.add({'userId': receiverId, 'counter': 1});
    }

    // Update Firestore
    await dialogRef.set({
      'unreadMessageCounter': updatedList,
    }, SetOptions(merge: true));
  }

  // MARK MESSAGE  AS READ
  void markMessageAsRead(DocumentSnapshot msg) async {
    final data = msg.data() as Map<String, dynamic>;
    final messageId = data['messageId'];
    final currentUserId = FIREBASE_AUTH_UID();

    final List readBy = data['readBy'] ?? [];
    if (!readBy.contains(currentUserId)) {
      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
            'readBy': FieldValue.arrayUnion([currentUserId]),
          });
    }
  }
}

// HELPER
Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
groupMessagesByDate(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
) {
  final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> grouped =
      {};

  for (var msg in messages) {
    final timestamp = msg.data()['time_stamp'];
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    grouped.putIfAbsent(label, () => []).add(msg);
  }

  return grouped;
}
