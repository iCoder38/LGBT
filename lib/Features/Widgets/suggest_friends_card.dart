import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class FriendCardWidget extends StatelessWidget {
  final FriendCard friend;

  const FriendCardWidget({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              friend.imageUrl,

              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Spacer(),

          customText(friend.name, 16, context, fontWeight: FontWeight.w600),
          customText("${friend.age} Year | ${friend.gender}", 14, context),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      AppColor().PURPLE,
                    ),
                  ),
                  onPressed: null,
                  icon: Icon(Icons.person_add, color: AppColor().kWhite),
                  label: customText(
                    "Add friends",
                    14,
                    context,
                    color: AppColor().kWhite,
                  ),
                ),
                Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
