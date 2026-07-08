import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/common/ui/widgets/music_sheet.dart';
import 'package:popbom/features/common/ui/widgets/tag_people_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/common/controllers/reels_upload_controller.dart';
import 'package:just_audio/just_audio.dart';

class InstagramPostExactScreen extends StatefulWidget {
  final String? videoFilePath;
  final VideoPlayerController? videoController;
  final String? challengeId;


  const InstagramPostExactScreen({
    Key? key,
    this.videoFilePath,
    this.videoController, this.challengeId,
  }) : super(key: key);

  @override
  _InstagramPostExactScreenState createState() =>
      _InstagramPostExactScreenState();
}

class _InstagramPostExactScreenState extends State<InstagramPostExactScreen> {
  // controllers & state
  final TextEditingController _captionController = TextEditingController();

  final reelsController = Get.find<ReelsUploadController>();

  String _selectedMusicUrl = ''; // external_url for backend
  String _selectedMusicLabel = ''; // readable label shown in UI
  String _audience = 'Everyone';
  String? _challengeId;


  // video (optional)
  late VideoPlayerController _videoController;
  bool _isVideoReady = false;
  bool _weCreatedVideoController = false; // to decide dispose

  final ImagePicker _picker = ImagePicker();
  Timer? _debounce;

  // user search (tagging)
  bool _isLoadingUsers = false;
  List<UserModel> _usersSearchResults = [];

  @override
  void initState() {
    super.initState();
    _challengeId = widget.challengeId;

    // load music from API
    reelsController.fetchAllMusic();

    // preload users cache so tagged IDs become names
    reelsController.loadUsersCacheOnce();

    // video controller handling
    if (widget.videoController != null) {
      _videoController = widget.videoController!;
      _isVideoReady = true;
      _videoController.setLooping(true);
      _weCreatedVideoController = false;
    } else if (widget.videoFilePath != null) {
      _videoController = VideoPlayerController.file(File(widget.videoFilePath!));
      _weCreatedVideoController = true;
      _initializeVideo();
    } else {
      _isVideoReady = false;
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      _videoController.setLooping(true);
      setState(() => _isVideoReady = true);
    } catch (e) {
      debugPrint('video init error: $e');
    }
  }

  // ========== USER SEARCH (Tag People) ==========
  Future<void> _searchUsers(String query) async {
    final cached = reelsController.usersCache.values.toList();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoadingUsers = true);

      try {
        final client = Get.find<NetworkClient>();
        final resp = await client.getRequest(Urls.allUsersWithFollowStatusUrl);

        if (!resp.isSuccess) {
          setState(() => _usersSearchResults = []);
          return;
        }

        final List data = resp.responseData?['data'] ?? [];

        final list = data.map<UserModel>((json) {
          final id = (json['_id'] ?? json['id'] ?? json['userId'] ?? "").toString();
          return UserModel(
            id: id,
            username: json['username']?.toString(),
            name: (json['name'] ?? json['details']?['name'])?.toString(),
            photo: (json['photo'] ?? json['details']?['photo'])?.toString(),
            isFollowing: json['isFollowing'] ?? false,
          );
        }).where((u) {
          if (query.trim().isEmpty) return true;
          final q = query.toLowerCase();
          return (u.name ?? '').toLowerCase().contains(q) ||
              (u.username ?? '').toLowerCase().contains(q);
        }).toList();

        setState(() => _usersSearchResults = list);
      } catch (e) {
        debugPrint('user search error: $e');
        setState(() => _usersSearchResults = []);
      } finally {
        setState(() => _isLoadingUsers = false);
      }
    });
  }

  // // ========== MUSIC SHEET (API VERSION) ==========
  // Future<void> _openMusicSheet() async {
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (ctx) {
  //       return FractionallySizedBox(
  //         heightFactor: 0.85,
  //         child: Obx(() {
  //           if (reelsController.isMusicLoading.value) {
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //
  //           final list = reelsController.searchMusic.isEmpty
  //               ? reelsController.allMusic
  //               : reelsController.searchMusic;
  //
  //           return MusicSheetAPI(
  //             results: list,
  //             onSearch: (q) => reelsController.searchMusicByName(q),
  //             onSelect: (track) {
  //               final url = track['external_url']?.toString() ?? '';
  //               final name = (track['name']?.toString() ?? '');
  //               final artists = (track['artists'] is List)
  //                   ? (track['artists'] as List).join(', ')
  //                   : (track['artists']?.toString() ?? '');
  //               final label = artists.isNotEmpty ? '$artists • $name' : name;
  //
  //               setState(() {
  //                 _selectedMusicUrl = url;
  //                 _selectedMusicLabel = label;
  //               });
  //               Navigator.pop(ctx);
  //             },
  //             selectedUrl: _selectedMusicUrl,
  //           );
  //         }),
  //       );
  //     },
  //   );
  // }

  // ========== TAG PEOPLE SHEET ==========
  Future<void> _openTagSheet() async {
    final reels = Get.find<ReelsUploadController>();

    await reels.loadUsersCacheOnce();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TagPeopleSheet(
          alreadyTaggedIds: reels.taggedUserIds.toList(),
          onTagChange: (list) {
            reels.updateTaggedUsers(list);
          },
        );
      },
    );

    setState(() {});
  }



  // pick avatar (kept)
  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    // placeholder - you might want to handle avatar preview/upload
  }

  void _onShare() async {
    debugPrint("🔥 UPLOAD challengeId = $_challengeId");

    if (!_isVideoReady) {
      Get.snackbar('Error', 'Video not ready');
      return;
    }

    final filePath = widget.videoFilePath;
    if (filePath == null) {
      Get.snackbar('Error', 'Video file missing');
      return;
    }

    final success = await reelsController.uploadReel(
      videoFile: File(filePath),
      caption: _captionController.text.trim().isEmpty
          ? ""
          : _captionController.text.trim(),
      music: _selectedMusicUrl,
      audience: _audience,
      challengeId: _challengeId,
    );

    if (success) {
      _captionController.clear();
      reelsController.taggedUserIds.clear();
      reelsController.taggedUsersDetails.clear();
      _selectedMusicUrl = "";
      _selectedMusicLabel = "";
      Navigator.pop(context);
    }

  }

  @override
  void dispose() {
    _captionController.dispose();
    _debounce?.cancel();

    // only dispose video controller if we created it here
    if (_weCreatedVideoController && _isVideoReady) {
      try {
        _videoController.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    final cardColor = isDark ? const Color(0xFF121416) : const Color(0xFFF3F3F3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
        ),
        title: Text('New post', style: TextStyle(fontSize: 16, color: textColor)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // media preview
                    Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: _isVideoReady
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: Stack(
                              children: [
                                VideoPlayer(_videoController),
                                Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _videoController.value.isPlaying
                                            ? _videoController.pause()
                                            : _videoController.play();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _videoController.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // caption
                    TextFormField(
                      controller: _captionController,
                      style: TextStyle(color: textColor),
                      minLines: 2,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        border:
                        OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: cardColor,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                   // const SizedBox(height: 10),

                    // music row - tappable to open picker
                    // InkWell(
                    //   onTap: _openMusicSheet,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //     child: Row(
                    //       children: [
                    //         Icon(Icons.music_note, color: secondaryTextColor),
                    //         const SizedBox(width: 12),
                    //         Expanded(
                    //           child: Text(
                    //             'Music',
                    //             style: TextStyle(color: textColor, fontSize: 16),
                    //           ),
                    //         ),
                    //         Flexible(
                    //           child: Text(
                    //             _selectedMusicLabel.isEmpty
                    //                 ? 'Select music'
                    //                 : _selectedMusicLabel,
                    //             style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         Icon(Icons.arrow_forward_ios, size: 14, color: secondaryTextColor),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Suggested Music Section (API-based)
                    // const SizedBox(height: 10),
                    // Text(
                    //   "Suggested music",
                    //   style: TextStyle(
                    //     color: secondaryTextColor,
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    //
                    // Obx(() {
                    //   final list = reelsController.allMusic;
                    //
                    //   if (reelsController.isMusicLoading.value) {
                    //     return const Center(child: CircularProgressIndicator());
                    //   }
                    //
                    //   if (list.isEmpty) {
                    //     return const Text("No music available");
                    //   }
                    //
                    //   return SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: Row(
                    //       children: [
                    //         const SizedBox(width: 4),
                    //         ...list.map((m) {
                    //           final name = m["name"]?.toString() ?? "";
                    //           final artists = (m["artists"] is List)
                    //               ? (m["artists"] as List).join(", ")
                    //               : (m["artists"]?.toString() ?? "");
                    //           final label = artists.isNotEmpty ? '$artists • $name' : name;
                    //           final url = m["external_url"]?.toString() ?? "";
                    //           final isSelected = _selectedMusicUrl == url;
                    //
                    //           return Padding(
                    //             padding: const EdgeInsets.only(right: 8),
                    //             child: GestureDetector(
                    //               onTap: () {
                    //                 setState(() {
                    //                   _selectedMusicUrl = url;
                    //                   _selectedMusicLabel = label;
                    //                 });
                    //               },
                    //               child: Container(
                    //                 padding: const EdgeInsets.symmetric(
                    //                     horizontal: 12, vertical: 8),
                    //                 decoration: BoxDecoration(
                    //                   color: isSelected
                    //                       ? Colors.green.withOpacity(0.15)
                    //                       : cardColor,
                    //                   borderRadius: BorderRadius.circular(22),
                    //                   border: Border.all(
                    //                     color: isSelected ? Colors.green : Colors.grey,
                    //                   ),
                    //                 ),
                    //                 child: Row(
                    //                   children: [
                    //                     const Icon(Icons.music_note, size: 18),
                    //                     const SizedBox(width: 6),
                    //                     Text(
                    //                       label,
                    //                       style: TextStyle(
                    //                         color: textColor,
                    //                         fontSize: 12.5,
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         }).toList(),
                    //         const SizedBox(width: 4),
                    //       ],
                    //     ),
                    //   );
                    // }),

                    const SizedBox(height: 12),

                    // tag people row
                    InkWell(
                      onTap: () async {
                        await _openTagSheet();
                        setState(() {}); // refresh to show chips
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, color: secondaryTextColor),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Tag people', style: TextStyle(color: textColor, fontSize: 16))),
                            Obx(() {
                              final cnt = reelsController.taggedUsersDetails.length;
                              return Text(
                                cnt == 0 ? 'Add' : '$cnt tagged',
                                style: TextStyle(color: secondaryTextColor),
                              );
                            }),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 14, color: secondaryTextColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // show selected tagged users with names
                    Obx(() {
                      final controller = reelsController;
                      if (controller.taggedUserIds.isEmpty) {
                        return const SizedBox();
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: controller.taggedUsersDetails.map((u) {
                          final displayName = (u.name != null && u.name!.isNotEmpty)
                              ? u.name!
                              : (u.username != null ? u.username! : u.id ?? 'Unknown');

                          return Chip(
                            avatar: (u.photo != null && u.photo!.isNotEmpty)
                                ? CircleAvatar(backgroundImage: NetworkImage(u.photo!))
                                : null,
                            label: Text(displayName),
                            onDeleted: () {
                              controller.taggedUserIds.remove(u.id);
                              controller.updateTaggedUsers(controller.taggedUserIds.toList());
                            },
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Audience
                    InkWell(
                      onTap: _showAudienceSheet,
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye, color: secondaryTextColor),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Audience', style: TextStyle(color: textColor, fontSize: 16))),
                          Text(_audience, style: TextStyle(color: secondaryTextColor)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 14, color: secondaryTextColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),

          // bottom action bar (Share)
          Obx(() {
            final loading = reelsController.isUploading.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: Colors.transparent,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : _onShare,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: loading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAudienceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1E22) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select Audience',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                const SizedBox(height: 12),
                _audienceOption('Everyone', Icons.public, textColor, iconColor),
                _audienceOption('Followers', Icons.people_alt_outlined, textColor, iconColor),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _audienceOption(String title, IconData icon, Color textColor, Color iconColor) {
    final bool selected = _audience == title;
    return InkWell(
      onTap: () {
        setState(() => _audience = title);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 16))),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 20)
            else
              const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}