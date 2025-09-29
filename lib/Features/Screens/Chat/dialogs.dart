import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Chat/chat.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class FriendsDialogsScreen extends StatefulWidget {
  const FriendsDialogsScreen({super.key});

  @override
  State<FriendsDialogsScreen> createState() => _FriendsDialogsScreenState();
}

class _FriendsDialogsScreenState extends State<FriendsDialogsScreen> {
  String currentUserId = '';
  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var userData;

  @override
  void initState() {
    super.initState();

    _loadUser();
    // Future.delayed(Duration(seconds: 2), debugDialogsManually);
  }

  void _loadUser() async {
    userData = await UserLocalStorage.getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentUserId = FIREBASE_AUTH_UID();
      // userData["userId"].toString();
      setState(() => isLoading = false);
    });
  }

  /*void debugDialogsManually() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .where('users', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    // print("🧪 Docs found: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      // print("🔎 Dialog doc: ${doc.data()}");
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColor().kWhite,
      appBar: CustomAppBar(
        title: "Dialogs",
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _FriendChatListingUIKit(),
    );
  }

  Widget _FriendChatListingUIKit() {
    if (currentUserId.isEmpty) {
      return const Center(child: Text("User not loaded"));
    }

    final query = FirebaseFirestore.instance
        .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
        .where('users', arrayContains: FIREBASE_AUTH_UID())
        .orderBy('timestamp', descending: true)
        .limit(50);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 56,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                customText(
                  Localizer.get(AppText.noChatYet.key),

                  14,
                  context,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();

            final chatId = data['chatId'] ?? '';
            final lastMessage = data['lastMessage'] ?? '';
            final timestamp = int.tryParse(data['timestamp'].toString()) ?? 0;

            // Extract unread count for the current user safely
            final List<dynamic> counterList =
                data['unreadMessageCounter'] ?? [];
            final myCounterEntry = counterList.firstWhere(
              (entry) => entry['userId'] == currentUserId,
              orElse: () => {'counter': 0},
            );
            final int unreadCounter = myCounterEntry['counter'] ?? 0;

            final users = List<String>.from(data['users'] ?? []);
            // friendId is the other user (different from currentUserId)
            final friendId = users.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            // If friendId is empty, show a placeholder tile
            if (friendId.isEmpty) {
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: customText(
                  'Unknown',
                  14,
                  context,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: customText(lastMessage, 12, context),
                trailing: unreadCounter > 0
                    ? Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor().PRIMARY_COLOR,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: customText(
                          unreadCounter > 99 ? '99+' : unreadCounter.toString(),
                          10,
                          context,
                          color: AppColor().kWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : null,
              );
            }

            // --- inside itemBuilder(...) ---

            // correct path to the PROFILE document for the friend
            final friendDocStream = FirebaseFirestore.instance
                .collection('LGBT_TOGO_PLUS') // collection
                .doc('USERS') // USERS is a document here (per your structure)
                .collection(friendId) // collection named by the userId
                .doc('PROFILE') // PROFILE document containing profile fields
                .snapshots();

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: friendDocStream,
              builder: (context, friendSnap) {
                String friendName = '';
                String friendImage = '';

                if (friendSnap.hasData &&
                    friendSnap.data != null &&
                    friendSnap.data!.data() != null) {
                  final friendData = friendSnap.data!.data()!;
                  // Use the "name" field as primary display name
                  friendName = (friendData['name'] as String?)?.trim() ?? '';

                  // image fallbacks (adjust keys if different)
                  friendImage =
                      (friendData['photoUrl'] ??
                              friendData['profileImage'] ??
                              friendData['avatar'] ??
                              '')
                          as String;
                }

                // Fallback to dialog fields if profile missing
                if (friendName.isEmpty) {
                  friendName = currentUserId == data['senderId']
                      ? (data['receiverName'] ?? 'Friend')
                      : (data['senderName'] ?? 'Friend');
                }

                final receiverName = friendName;

                Widget leadingWidget;
                if (friendImage.isNotEmpty) {
                  leadingWidget = CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(friendImage),
                    backgroundColor: Colors.grey[200],
                  );
                } else {
                  final initials = receiverName.isNotEmpty
                      ? receiverName[0].toUpperCase()
                      : '?';
                  leadingWidget = CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[800],
                    child: Text(
                      initials,
                      style: TextStyle(color: AppColor().kWhite),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FriendlyChatScreen(
                          friendId: friendId,
                          friendName: receiverName,
                          senderImage: '',
                          receiverImage: friendImage,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
                    ),
                    child: CustomContainer(
                      margin: const EdgeInsets.all(0),
                      color: AppColor().kWhite,
                      shadow: true,
                      height: 72,
                      child: ListTile(
                        leading: leadingWidget,
                        title: customText(
                          receiverName,
                          14,
                          context,
                          fontWeight: FontWeight.w600,
                        ),
                        subtitle: customText(
                          _getSubtitle(data, friendId, lastMessage),
                          12,
                          context,
                          color: _isFriendTyping(data, friendId)
                              ? Colors.greenAccent
                              : null,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customText(
                              convertTimestampToHHMM(timestamp),
                              10,
                              context,
                            ),
                            if (unreadCounter > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor().PRIMARY_COLOR,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: customText(
                                  unreadCounter > 99
                                      ? '99+'
                                      : unreadCounter.toString(),
                                  10,
                                  context,
                                  color: AppColor().kWhite,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>
  _onlineOfflineProfileWidget(String friendId, String receiverName) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
          .doc(friendId)
          .snapshots(),
      builder: (context, statusSnap) {
        bool isOnline = false;

        if (statusSnap.hasData && statusSnap.data?.data() != null) {
          final status = statusSnap.data!.data()!;
          isOnline = status['isOnline'] ?? false;
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('LGBT_TOGO_PLUS/USERS/$friendId')
              .doc("PROFILE")
              .snapshots(),
          builder: (context, userSnap) {
            String? imageUrl;
            if (userSnap.hasData && userSnap.data!.data() != null) {
              imageUrl = userSnap.data!.data()!['image'];
            }

            final hasImage = imageUrl != null && imageUrl.isNotEmpty;

            return SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                children: [
                  hasImage
                      ? CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(imageUrl!),
                          backgroundColor: Colors.grey[300],
                        )
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[800],
                          child: Text(
                            receiverName.isNotEmpty
                                ? receiverName[0].toUpperCase()
                                : '?',
                            style: TextStyle(color: AppColor().kWhite),
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String _getSubtitle(
  Map<String, dynamic> data,
  String friendId,
  String lastMsg,
) {
  return _isFriendTyping(data, friendId) ? "typing..." : lastMsg;
}

bool _isFriendTyping(Map<String, dynamic> data, String friendId) {
  final typingMap = data['typingStatus'] ?? {};
  return typingMap[friendId] == true;
}

String convertTimestampToHHMM(int timestamp) {
  try {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  } catch (_) {
    return '';
  }
}

class ChatTracker {
  static String? lastOpenedChatId;
}
