import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final followCtrl = Get.find<FollowUnfollowController>();

  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// LOAD USERS FROM BACKEND (correct mapping)
  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    final response = await Get.find<NetworkClient>().getRequest(Urls.allUsersWithFollowStatusUrl);

    if (response.isSuccess) {
      final List data = response.responseData?["data"] ?? [];

      _users = data.map((json) {
        final uid = json["_id"]?.toString()
            ?? json["userId"]?.toString()
            ?? json["id"]?.toString();

        return UserModel(
          id: uid,
          username: json["username"],
          name: json["name"],
          photo: json["photo"],
          isFollowing: followCtrl.isFollowing(uid!),
        );
      }).toList();

    }

    setState(() => _loading = false);
  }



  /// FOLLOW / UNFOLLOW (UI update)
  Future<void> _toggleFollow(String userId) async {
    final status = await followCtrl.toggleFollow(userId);
    if (status == null) return;

    final index = _users.indexWhere((u) => u.id == userId);
    if (index == -1) return;

    setState(() {
      _users[index].isFollowing = (status == "follow");
    });
  }



  /// SEARCH FILTER
  List<UserModel> get filteredUsers {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _users;

    return _users.where((u) {
      return (u.name ?? "").toLowerCase().contains(q) ||
          (u.username ?? "").toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cs.onBackground,size: 18,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Friends",
          style: TextStyle(
            color: cs.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search name or username",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? Center(child: CenteredCircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: filteredUsers.length,
                itemBuilder: (_, index) {
                  final user = filteredUsers[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        /// AVATAR
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: (user.photo != null &&
                              user.photo!.isNotEmpty)
                              ? CachedNetworkImageProvider(user.photo!,
                                  maxHeight: 120, maxWidth: 120)
                              : null,
                          child: (user.photo == null ||
                              user.photo!.isEmpty)
                              ? Icon(Icons.person)
                              : null,
                        ),

                        const SizedBox(width: 12),

                        /// NAME + USERNAME
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.to(() => UserProfileScreen(
                                userId: user.id!,
                                username: user.username ?? "",
                                avatarUrl: user.photo ?? "",
                              ));
                            },
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name ?? "",
                                  style: TextStyle(
                                    color: cs.onBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "@${user.username}",
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// FOLLOW / UNFOLLOW BUTTON
                        user.isFollowing
                            ? OutlinedButton(
                          onPressed: () =>
                              _toggleFollow(user.id!),
                          child: const Text("Unfollow"),
                        )
                            : ElevatedButton(
                          onPressed: () =>
                              _toggleFollow(user.id!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Follow"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
