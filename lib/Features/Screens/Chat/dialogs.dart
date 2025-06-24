import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Chat/chat.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class FriendsDialogsScreen extends StatefulWidget {
  const FriendsDialogsScreen({super.key});

  @override
  State<FriendsDialogsScreen> createState() => _FriendsDialogsScreenState();
}

class _FriendsDialogsScreenState extends State<FriendsDialogsScreen> {
  final String currentUserId = FIREBASE_AUTH_UID();

  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      body: _FriendChatListingUIKit(),
    );
  }

  Widget _FriendChatListingUIKit() {
    return Container(
      margin: const EdgeInsets.only(top: 0, bottom: 72),
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('LGBT_TOGO_PLUS/CHAT/DIALOGS')
            .doc(currentUserId)
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: customText(
                "No chats yet.",
                14,
                context,
                color: AppColor().kWhite,
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final String receiverId = data['receiverId'] ?? '';
              final String receiverName = data['receiverName'] ?? '';
              final String lastMessage = data['lastMessage'] ?? '';

              int unreadCount = data['unreadCount'] ?? 0;
              final String chatId = data['chatId'] ?? '';

              if (ChatTracker.lastOpenedChatId == chatId) {
                unreadCount = 0;
              }

              final int timestamp =
                  int.tryParse(data['timestamp'].toString()) ?? 0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendlyChatScreen(
                        friendId: receiverId,
                        friendName: receiverName,
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
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[800],
                          child: Text(
                            receiverName.isNotEmpty
                                ? receiverName[0].toUpperCase()
                                : '?',
                            style: TextStyle(color: AppColor().kWhite),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(
                                receiverName,
                                14,
                                context,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 4),
                              customText(lastMessage, 12, context),
                              /*Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor().kBlack,
                                  fontSize: 12,
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              convertTimestampToHHMM(timestamp),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String convertTimestampToHHMM(int timestamp) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }
}

class ChatTracker {
  static String? lastOpenedChatId;
}
