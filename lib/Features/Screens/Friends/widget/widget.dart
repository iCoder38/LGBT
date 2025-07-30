import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

Widget widgetFriendTile(
  BuildContext context,
  String status,
  List<dynamic> arrFriends,
  Map<String, dynamic> userData, {
  required Function(dynamic selectedFriend, {bool isFromIcon}) onTapReturn,
}) {
  if (arrFriends.isEmpty) {
    return Center(
      child: customText(
        "No friends",
        16,
        context,
        fontWeight: FontWeight.w600,
        color: AppColor().GRAY,
      ),
    );
  } else {
    return ListView.builder(
      itemCount: arrFriends.length,
      itemBuilder: (context, index) {
        var friendsData = arrFriends[index];
        if (friendsData["status"].toString() != status) return SizedBox();

        bool isSender =
            friendsData["senderId"].toString() == userData['userId'].toString();
        var profileData = isSender
            ? friendsData["Receiver"]
            : friendsData["Sender"];

        return CustomUserTile(
          leading: CustomCacheImageForUserProfile(
            imageURL: profileData["profile_picture"].toString(),
          ),
          title: profileData["firstName"].toString(),
          subtitle:
              "${GlobalUtils().calculateAge(profileData["dob"].toString())} | ${profileData["gender"].toString()}",
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              onTapReturn(friendsData, isFromIcon: true); // 👈 from icon
            },
          ),
          onTap: () {
            onTapReturn(friendsData, isFromIcon: false); // 👈 from tile
          },
        );
      },
    );
  }
}
