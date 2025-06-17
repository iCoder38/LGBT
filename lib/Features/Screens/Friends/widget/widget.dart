import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

Widget widgetFriendTile(context, status, arrFriends, userData) {
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
        return friendsData["status"].toString() != status
            ? SizedBox()
            : friendsData["senderId"].toString() ==
                  userData['userId'].toString()
            ? CustomUserTile(
                leading: CustomCacheImageForUserProfile(
                  imageURL: friendsData["Receiver"]["profile_picture"]
                      .toString(),
                ),
                title: friendsData["Receiver"]["firstName"].toString(),
                subtitle:
                    "${GlobalUtils().calculateAge(friendsData["Receiver"]["dob"].toString())} | ${friendsData["Receiver"]["gender"].toString()}",
              )
            : CustomUserTile(
                leading: CustomCacheImageForUserProfile(
                  imageURL: friendsData["Sender"]["profile_picture"].toString(),
                ),
                title: friendsData["Sender"]["firstName"].toString(),
                subtitle:
                    "${GlobalUtils().calculateAge(friendsData["Receiver"]["dob"].toString())} | ${friendsData["Sender"]["gender"].toString()}",
              );
      },
    );
  }
}
