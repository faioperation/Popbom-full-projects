import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/common/controllers/reels_upload_controller.dart';
import 'package:popbom/features/common/models/user_model.dart';

class TagPeopleSheet extends StatefulWidget {
  final List<String> alreadyTaggedIds;
  final Function(List<String>) onTagChange;

  const TagPeopleSheet({
    super.key,
    required this.alreadyTaggedIds,
    required this.onTagChange,
  });

  @override
  State<TagPeopleSheet> createState() => _TagPeopleSheetState();
}

class _TagPeopleSheetState extends State<TagPeopleSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];

  List<String> _selectedIds = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = [...widget.alreadyTaggedIds];
    _fetchUsers();
  }


  Future<void> _fetchUsers() async {
    try {
      final cache = Get.find<ReelsUploadController>().usersCache.values.toList();

      // 🔥 Create fresh UserModel objects (no shared reference!)
      _allUsers = cache.map((u) {
        return UserModel(
          id: (u["_id"] ?? u["id"] ?? u["userId"] ?? "").toString(),
          name: (u["name"] ?? u["details"]?["name"])?.toString(),
          username: u["username"]?.toString(),
          photo: (u["photo"] ?? u["details"]?["photo"])?.toString(),
        );
      }).toList();

      _filteredUsers = [..._allUsers];

    } catch (e) {
      debugPrint("Tag user error: $e");
    }

    setState(() => _loading = false);
  }


  void _search(String text) {
    final q = text.toLowerCase();

    setState(() {
      _filteredUsers = _allUsers.where((u) {
        return (u.name ?? "").toLowerCase().contains(q) ||
            (u.username ?? "").toLowerCase().contains(q);
      }).toList();
    });
  }


  void _toggle(UserModel u) {
    final reels = Get.find<ReelsUploadController>();
    final exists = _selectedIds.contains(u.id);

    setState(() {
      if (exists) {
        _selectedIds.remove(u.id);
      } else {
        if (u.id != null) _selectedIds.add(u.id!);
      }
    });

    reels.updateTaggedUsers(_selectedIds);
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _searchCtrl,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (_loading) const LinearProgressIndicator(),

                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (_, i) {
                      final u = _filteredUsers[i];
                      final isSel = _selectedIds.contains(u.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                          (u.photo ?? "").isNotEmpty
                              ? NetworkImage(u.photo!)
                              : null,
                          child: (u.photo ?? "").isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(u.name ?? u.username ?? ""),
                        subtitle: Text("@${u.username ?? ''}"),
                        trailing: IconButton(
                          icon: Icon(
                            isSel
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: isSel ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggle(u),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔥 Final update only once
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
