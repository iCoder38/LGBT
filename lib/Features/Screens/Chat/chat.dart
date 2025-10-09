import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lgbt_togo/Features/Screens/Chat/message_bubble.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/my_profile.dart';
import 'package:lgbt_togo/Features/Services/Firebase/utils.dart';
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
    required this.senderImage,
    required this.receiverImage,
  });

  final String friendId;
  final String friendName;
  final String senderImage;
  final String receiverImage;

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
  String friendId = '';

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
    // set typing to false (transient collection)
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
    loginUserNameIs = userData['firstName'].toString();
    friendidIs = widget.friendId.toString();

    GlobalUtils().customLog(
      "LoginUserId: $loginUserId\nFriendUserId: $friendidIs",
    );

    // store for chat and dialogs
    currentUserId = loginUserId;
    friendId = friendidIs;

    chatId = currentUserId.compareTo(friendidIs) < 0
        ? '${currentUserId}_$friendidIs'
        : '${friendidIs}_$currentUserId';

    await createMessageStreamAndInit();
  }

  Future<void> createMessageStreamAndInit() async {
    try {
      // NOTE: removed early dialog/unread creation. We do NOT create dialog on init.
      // Setup messages path
      final messagePath = FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId)
          .collection('messages');

      final testSnapshot = await messagePath.get();

      // Setup stream
      messageStream = messagePath
          .orderBy('time_stamp', descending: true)
          .limit(20)
          .snapshots();

      // mark chat ready
      setState(() {
        isChatReady = true;
      });

      // Reset unread counter in DIALOG if it exists (keeps server tidy)
      await resetUnreadCounter(chatId, loginUserId);

      GlobalUtils().customLog(
        "✅ Message stream and unread reset done for $chatId",
      );
    } catch (e) {
      GlobalUtils().customLog("❌ createMessageStreamAndInit failed: $e");
    }
  }

  Future<void> resetUnreadCounter(String chatId, String userId) async {
    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatId);

    // get from server to avoid cache confusion
    final snapshot = await dialogRef.get(
      const GetOptions(source: Source.server),
    );

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
              final hasText = contTextSendMessage.text.trim().isNotEmpty;
              final hasImage = isImageSelected && imageFile != null;

              if (hasImage) {
                // Send image with optional text caption
                uploadChatImageWB();
              } else if (hasText) {
                // Send only text message
                sendMessageViaFirebase(contTextSendMessage.text.trim(), 'iv');
                lastMessage = contTextSendMessage.text.trim();
                contTextSendMessage.clear();
                updateTypingStatus(chatId, loginUserId, false);
                _typingTimer?.cancel();
              } else {
                // Just close screen if nothing to send
                Navigator.pop(context);
              }
            },
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {
          //       showProfileFullScreenSheet(context, friendId.toString());
          //     },
          //     icon: Icon(Icons.person),
          //   ),
          // ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
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
              // ------ Typing status: now read from transient CHAT/TYPING/<chatId> doc ------
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('LGBT_TOGO_PLUS')
                    .doc('CHAT')
                    .collection('TYPING')
                    .doc(chatId)
                    .snapshots(),
                builder: (context, typingSnap) {
                  if (!typingSnap.hasData || typingSnap.data!.data() == null) {
                    return const SizedBox();
                  }

                  final typingData = typingSnap.data!.data()!;
                  final bool isTyping = typingData[friendId] == true;

                  if (!isTyping) return const SizedBox();

                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Text(
                        "typing...",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        body: SafeArea(top: true, bottom: true, child: _UIKit(context)),
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
          margin: const EdgeInsets.only(bottom: 80),
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: messageStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(Localizer.get(AppText.noMessageYet.key)),
                );
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                padding: const EdgeInsets.only(bottom: 40),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final data = msg.data();

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
                    timeStamp: int.tryParse(data['time_stamp'].toString()) ?? 0,
                    isSent: true,
                    readBy: data['readBy'] ?? [],
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
    // read system bottom inset (gesture/navigation bar) and add a small extra gap
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double extraGap = 8.0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + extraGap),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isImageSelected && imageFile != null
                      ? Padding(
                          key: const ValueKey("imagePreview"),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.grey[200],
                                  child: Image.file(
                                    imageFile!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
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
                                    child: const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black,
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
                        )
                      : const SizedBox.shrink(key: ValueKey("noImage")),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: AppColor().kWhite,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          AlertsUtils().showCustomBottomSheet(
                            context: context,
                            message: "Camera,Gallery,Gifts",
                            buttonText: "Select",
                            onItemSelected: (s) async {
                              // ... same as your current code ...
                            },
                          );
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
                            decoration: InputDecoration(
                              hintText: Localizer.get(
                                AppText.writeSomething.key,
                              ),
                            ),
                            onChanged: (value) {
                              updateTypingStatus(chatId, loginUserId, true);
                              _typingTimer?.cancel();
                              _typingTimer = Timer(
                                const Duration(seconds: 2),
                                () {
                                  updateTypingStatus(
                                    chatId,
                                    loginUserId,
                                    false,
                                  );
                                },
                              );
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
                              if (isImageSelected && imageFile != null) {
                                uploadChatImageWB();
                              } else if (contTextSendMessage.text.isNotEmpty) {
                                sendMessageViaFirebase(
                                  contTextSendMessage.text.trim(),
                                  'iv',
                                );
                                lastMessage = contTextSendMessage.text.trim();
                                contTextSendMessage.clear();
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
          ),
        ),
      ),
    );
  }

  // ---------- SEND STICKER ----------
  void sendStickerMessage(String assetPath) async {
    final messageId = const Uuid().v4();
    final timeStamp = GlobalUtils().currentTimeStamp();
    final sortedUsers = [currentUserId, friendId]..sort();

    final chatData = {
      'messageId': messageId,
      'senderId': currentUserId,
      'senderName': loginUserNameIs,
      'receiverId': friendId,
      'receiverName': widget.friendName,
      'message': assetPath,
      'type': 'sticker',
      'time_stamp': timeStamp,
      'users': sortedUsers,
      'readBy': [FIREBASE_AUTH_UID()],
    };

    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(chatData);

    // create dialog only now (if needed), update lastMessage and counters
    final bool dialogCreated = await ensureDialogExists(
      senderId: currentUserId,
      senderName: loginUserNameIs,
      receiverId: friendId,
      receiverName: widget.friendName,
      timestamp: timeStamp,
      initialLastMessage: "[💬 Sticker]",
    );

    if (dialogCreated) {
      GlobalUtils().customLog(
        "🎉 First-time dialog created for $chatId (sticker)",
      );

      /// UPDATE USER POST POINTS DATA IN CLOUD
      await UserService().updateUser(FIREBASE_AUTH_UID(), {
        "levels.direct_message": FieldValue.increment(1),
        "levels.points": FieldValue.increment(PremiumPoints.directMessage),
      });
    } else {
      // update lastMessage/timestamp on existing dialog
      await checkAndUpdateDialog(
        senderId: currentUserId,
        senderName: loginUserNameIs,
        receiverId: friendId,
        receiverName: widget.friendName,
        lastMessage: "[💬 Sticker]",
        timestamp: timeStamp,
      );
    }

    await incrementUnreadCounter(chatId, friendId);
  }

  // ---------- UPLOAD IMAGE ----------
  void uploadChatImageWB() async {
    if (imageFile == null) return;

    final localFile = imageFile; // copy before clearing
    final messageId = Uuid().v4();
    final timeStamp = GlobalUtils().currentTimeStamp();
    final sortedUsers = [loginUserId, friendidIs]..sort();

    // remove preview from UI
    setState(() {
      imageFile = null;
      isImageSelected = false;
    });

    // placeholder message
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
          'message': "",
          'type': 'image',
          'isUploading': true,
          'time_stamp': timeStamp,
          'users': sortedUsers,
          'readBy': [loginUserId],
        });

    final fileName = "$messageId.jpg";
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(chatId)
        .child(fileName);

    try {
      final uploadTask = await ref.putFile(localFile!);
      final imageUrl = await ref.getDownloadURL();

      // update message with actual url
      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'message': imageUrl, 'isUploading': FieldValue.delete()});

      // ensure dialog exists / update
      final bool dialogCreated = await ensureDialogExists(
        senderId: loginUserId,
        senderName: loginUserNameIs,
        receiverId: friendidIs,
        receiverName: widget.friendName,
        timestamp: timeStamp,
        initialLastMessage: "[📷 Image]",
      );

      if (dialogCreated) {
        GlobalUtils().customLog(
          "🎉 First-time dialog created for $chatId (image)",
        );

        /// UPDATE USER POST POINTS DATA IN CLOUD
        await UserService().updateUser(FIREBASE_AUTH_UID(), {
          "levels.direct_message": FieldValue.increment(1),
          "levels.points": FieldValue.increment(PremiumPoints.directMessage),
        });
      } else {
        await checkAndUpdateDialog(
          senderId: loginUserId,
          senderName: loginUserNameIs,
          receiverId: friendidIs,
          receiverName: widget.friendName,
          lastMessage: "[📷 Image]",
          timestamp: timeStamp,
        );
      }

      await incrementUnreadCounter(chatId, friendidIs);
    } catch (e) {
      GlobalUtils().customLog("❌ Image upload failed: $e");

      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    }
  }

  // ---------- SEND TEXT ----------
  void sendMessageViaFirebase(String encryptedMessage, String iv) async {
    final messageId = const Uuid().v4();
    final timeStamp = GlobalUtils().currentTimeStamp();
    final sortedUsers = [currentUserId, friendId]..sort();

    // ensure parent friendly_chat doc exists (UI-only, not dialog)
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
      'readBy': [FIREBASE_AUTH_UID()],
    };

    await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/FRIENDLY_CHAT')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(chatData);

    // create dialog only now (if needed), update lastMessage and counters
    final bool dialogCreated = await ensureDialogExists(
      senderId: currentUserId,
      senderName: loginUserNameIs,
      receiverId: friendId,
      receiverName: widget.friendName,
      timestamp: timeStamp,
      initialLastMessage: encryptedMessage,
    );

    if (dialogCreated) {
      GlobalUtils().customLog(
        "🎉 First-time dialog created for $chatId (text)",
      );

      /// UPDATE USER POST POINTS DATA IN CLOUD
      await UserService().updateUser(FIREBASE_AUTH_UID(), {
        "levels.direct_message": FieldValue.increment(1),
        "levels.points": FieldValue.increment(PremiumPoints.directMessage),
      });
    } else {
      await checkAndUpdateDialog(
        senderId: currentUserId,
        senderName: loginUserNameIs,
        receiverId: friendId,
        receiverName: widget.friendName,
        lastMessage: encryptedMessage,
        timestamp: timeStamp,
      );
    }

    // increment unread for receiver
    await incrementUnreadCounter(chatId, friendId);
  }

  // ---------- ENSURE DIALOG EXISTS (creates only when called) ----------
  /// Creates a minimal dialog doc if it doesn't exist.
  /// Returns true if created.
  Future<bool> ensureDialogExists({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required int timestamp,
    String? initialLastMessage,
  }) async {
    final sortedIds = [senderId, receiverId]..sort();
    final chatIdLocal = "${sortedIds[0]}_${sortedIds[1]}";

    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatIdLocal);

    // force server read
    final snapshot = await dialogRef.get(
      const GetOptions(source: Source.server),
    );

    if (!snapshot.exists) {
      await dialogRef.set({
        'chatId': chatIdLocal,
        'users': sortedIds,
        'senderImage': widget.senderImage,
        'receiverImage': widget.receiverImage,
        'typingStatus': {}, // keep structure but empty
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': senderId,
        'lastMessage': initialLastMessage ?? '',
        'timestamp': timestamp,
      }, SetOptions(merge: true));

      GlobalUtils().customLog("✅ ensureDialogExists: created $chatIdLocal");
      return true;
    } else {
      GlobalUtils().customLog(
        "ℹ️ ensureDialogExists: already exists $chatIdLocal",
      );
      return false;
    }
  }

  // ---------- CHECK & UPDATE DIALOG (returns true if created) ----------
  Future<bool> checkAndUpdateDialog({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String lastMessage,
    required int timestamp,
  }) async {
    try {
      final sortedIds = [senderId, receiverId]..sort();
      final chatIdLocal = "${sortedIds[0]}_${sortedIds[1]}";

      final dialogRef = FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
          .doc(chatIdLocal);

      // force server read
      final snapshot = await dialogRef.get(
        const GetOptions(source: Source.server),
      );

      if (!snapshot.exists) {
        // First-time: create the dialog doc
        await dialogRef.set({
          'chatId': chatIdLocal,
          'senderId': senderId,
          'senderName': senderName,
          'receiverId': receiverId,
          'receiverName': receiverName,
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'users': sortedIds,
          'senderImage': widget.senderImage,
          'receiverImage': widget.receiverImage,
          'typingStatus': {},
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': senderId,
        }, SetOptions(merge: true));

        GlobalUtils().customLog("✅ Dialog created for chatId: $chatIdLocal");
        return true; // first-time created
      } else {
        // Already exists: just update lastMessage & timestamp (merge keeps other fields)
        await dialogRef.set({
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'senderId': senderId,
          'senderName': senderName,
          'receiverId': receiverId,
          'receiverName': receiverName,
          'senderImage': widget.senderImage,
          'receiverImage': widget.receiverImage,
        }, SetOptions(merge: true));

        GlobalUtils().customLog(
          "ℹ️ Dialog already existed — updated lastMessage for $chatIdLocal",
        );
        return false; // already existed
      }
    } catch (e, st) {
      GlobalUtils().customLog("❌ Failed to update dialog: $e\n$st");
      return false; // on error treat as not-first (caller can decide)
    }
  }

  // ---------- TYPING STATUS (transient, does NOT create dialog) ----------
  void updateTypingStatus(String chatId, String userId, bool isTyping) async {
    final typingRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS')
        .doc('CHAT')
        .collection('TYPING')
        .doc(chatId);

    await typingRef.set({
      userId: isTyping,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ---------- UPDATE COUNTER (ensures dialog exists) ----------
  Future<void> incrementUnreadCounter(
    String chatIdLocal,
    String receiverId,
  ) async {
    final dialogRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .doc(chatIdLocal);

    // ensure dialog exists on server (create a minimal dialog if missing)
    final snapshot = await dialogRef.get(
      const GetOptions(source: Source.server),
    );
    if (!snapshot.exists) {
      // create minimal dialog (createdBy = current user)
      await dialogRef.set({
        'chatId': chatIdLocal,
        'users': chatIdLocal.split('_'),
        'senderImage': widget.senderImage,
        'receiverImage': widget.receiverImage,
        'typingStatus': {},
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FIREBASE_AUTH_UID() ?? '',
        'lastMessage': '',
        'timestamp': GlobalUtils().currentTimeStamp(),
      }, SetOptions(merge: true));
    }

    // re-read snapshot (server)
    final readSnapshot = await dialogRef.get(
      const GetOptions(source: Source.server),
    );

    List<dynamic> counterList =
        readSnapshot.data()?['unreadMessageCounter'] ?? [];

    bool found = false;

    final updatedList = counterList.map((entry) {
      if (entry['userId'] == receiverId) {
        found = true;
        return {'userId': receiverId, 'counter': (entry['counter'] ?? 0) + 1};
      }
      return entry;
    }).toList();

    if (!found) {
      updatedList.add({'userId': receiverId, 'counter': 1});
    }

    await dialogRef.set({
      'unreadMessageCounter': updatedList,
    }, SetOptions(merge: true));
  }

  // MARK MESSAGE AS READ
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

  // HELPER: markFirstChatAndIncrementDM (transaction) - READS first, then WRITES
  /*Future<bool> markFirstChatAndIncrementDM({
    required String senderId,
    required String receiverId,
  }) async {
    if (senderId == receiverId) return false; // ignore self-chat

    final currentUid = FIREBASE_AUTH_UID();
    if (currentUid == null || currentUid.trim().isEmpty) {
      GlobalUtils().customLog(
        'markFirstChatAndIncrementDM ERROR: current UID is null/empty',
      );
      return false;
    }

    final sorted = [senderId, receiverId]..sort();
    final chatIdLocal = '${sorted[0]}_${sorted[1]}';

    final statusCollection = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS')
        .doc('CHECK_USER_MESSAGE_STATUS')
        .collection('LIST');
    final statusDocRef = statusCollection.doc(chatIdLocal);

    // assuming USERS is a collection and each user doc id = uid
    final userProfileDocRef = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/USERS')
        .doc('USERS')
        // .doc(currentUid)
        .collection(currentUid)
        .doc('PROFILE');

    try {
      final bool created = await FirebaseFirestore.instance
          .runTransaction<bool>((tx) async {
            // ---- READS FIRST ----
            final statusSnap = await tx.get(statusDocRef);
            final senderSnap = await tx.get(userProfileDocRef);

            if (statusSnap.exists) {
              return false;
            }

            // ---- WRITES AFTER READS ----
            tx.set(statusDocRef, {
              'chatId': chatIdLocal,
              'users': sorted,
              'firstMessageBy': senderId,
              'createdAt': FieldValue.serverTimestamp(),
            });

            if (senderSnap.exists) {
              tx.update(userProfileDocRef, {
                'levels.direct_message': FieldValue.increment(1),
              });
            } else {
              tx.set(userProfileDocRef, {
                'levels': {'direct_message': 1},
              }, SetOptions(merge: true));
            }

            return true;
          });

      return created;
    } catch (e, st) {
      GlobalUtils().customLog('markFirstChatAndIncrementDM ERROR: $e\n$st');
      return false;
    }
  }*/
}

// HELPER - groupMessagesByDate unchanged
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
