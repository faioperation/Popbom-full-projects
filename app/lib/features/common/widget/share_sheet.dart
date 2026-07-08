import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareSheet extends StatelessWidget {
  final String shareText;
  final String shareLink;
  final String postId;
  final String? videoUrl;

  ShareSheet({
    super.key,
    required this.shareText,
    required this.shareLink,
    required this.postId,
    this.videoUrl,
  });

  final PostActionsController actionCtrl = Get.find<PostActionsController>();
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloading = false.obs;

  Future<void> safeLaunch(String uri, {String? fallback}) async {
    try {
      final u = Uri.parse(uri);

      if (await canLaunchUrl(u)) {
        await launchUrl(u, mode: LaunchMode.externalApplication);
        return;
      }

      if (fallback != null) {
        final fb = Uri.parse(fallback);
        if (await canLaunchUrl(fb)) {
          await launchUrl(fb, mode: LaunchMode.externalApplication);
          return;
        }
      }

      Share.share("$shareText\n$shareLink");
    } catch (_) {
      Share.share("$shareText\n$shareLink");
    }
  }


  Future<void> _runShare(String platform, Function openApp) async {
    await actionCtrl.sharePost(
      postId: postId,
      platform: platform,
    );
    openApp();
  }

  // Future<void> saveVideoToGallery(File file) async {
  //   if (!Platform.isAndroid) return;
  //
  //   final directory = Directory('/storage/emulated/0/Movies/PopBom');
  //   if (!await directory.exists()) {
  //     await directory.create(recursive: true);
  //   }
  //
  //   final newPath = '${directory.path}/${file.uri.pathSegments.last}';
  //   await file.copy(newPath);
  // }




  // Future<void> _downloadVideo(BuildContext context) async {
  //   // ───── BASIC VALIDATION ─────
  //   if (videoUrl == null || videoUrl!.trim().isEmpty) {
  //     _showSnackBar(context, 'Video URL not available');
  //     return;
  //   }
  //
  //   if (!videoUrl!.startsWith('http')) {
  //     _showSnackBar(context, 'Invalid video URL');
  //     return;
  //   }
  //
  //   // ───── PERMISSION ─────
  //   //final hasPermission = await _requestStoragePermission(context);
  //   //if (!hasPermission) return;
  //
  //   File? downloadedFile;
  //
  //   try {
  //     isDownloading.value = true;
  //     downloadProgress.value = 0.0;
  //
  //     // ───── SHOW PROGRESS DIALOG ─────
  //     _showDownloadDialog(context);
  //
  //     // ───── TEMP FILE PATH ─────
  //     final tempDir = await getTemporaryDirectory();
  //     final fileName = 'popbom_${DateTime.now().millisecondsSinceEpoch}.mp4';
  //     final filePath = '${tempDir.path}/$fileName';
  //
  //     downloadedFile = File(filePath);
  //
  //     // ───── DOWNLOAD ─────
  //     final dio = Dio();
  //     await dio.download(
  //       videoUrl!,
  //       filePath,
  //       options: Options(
  //         receiveTimeout: const Duration(minutes: 5),
  //         sendTimeout: const Duration(minutes: 5),
  //         headers: {
  //           'User-Agent':
  //           'Mozilla/5.0 (Android) AppleWebKit/537.36 Chrome Safari',
  //         },
  //       ),
  //       onReceiveProgress: (received, total) {
  //         if (total > 0) {
  //           downloadProgress.value = received / total;
  //         }
  //       },
  //     );
  //
  //     // ───── VERIFY FILE ─────
  //     if (!await downloadedFile.exists()) {
  //       throw Exception('Downloaded file missing');
  //     }
  //
  //     // ───── SAVE TO GALLERY (PLUGIN-FREE) ─────
  //     //await saveVideoToGallery(downloadedFile);
  //
  //     // ───── CLOSE DOWNLOAD DIALOG ─────
  //     if (Navigator.of(context, rootNavigator: true).canPop()) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }
  //
  //     // ───── TRACK DOWNLOAD ─────
  //     await actionCtrl.sharePost(
  //       postId: postId,
  //       platform: 'download',
  //     );
  //
  //     // ───── SUCCESS UI ─────
  //     _showSuccessDialog(context);
  //
  //     // ───── CLEAN TEMP FILE ─────
  //     try {
  //       await downloadedFile.delete();
  //     } catch (_) {}
  //
  //   } on DioException catch (e) {
  //     if (Navigator.of(context, rootNavigator: true).canPop()) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }
  //
  //     String message = 'Download failed';
  //     if (e.type == DioExceptionType.connectionTimeout ||
  //         e.type == DioExceptionType.receiveTimeout) {
  //       message = 'Connection timeout. Check internet.';
  //     } else if (e.response?.statusCode == 404) {
  //       message = 'Video not found on server';
  //     }
  //
  //     _showSnackBar(context, message);
  //   } catch (e) {
  //     if (Navigator.of(context, rootNavigator: true).canPop()) {
  //       Navigator.of(context, rootNavigator: true).pop();
  //     }
  //     _showSnackBar(context, 'Download failed');
  //   } finally {
  //     isDownloading.value = false;
  //     downloadProgress.value = 0.0;
  //   }
  // }



  Future<void> saveVideoWithPhotoManager(
      BuildContext context,
      String videoUrl,
      ) async {
    if (videoUrl.isEmpty || !videoUrl.startsWith("http")) {
      _showSnackBar(context, "Invalid video URL");
      return;
    }

    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      _showSnackBar(context, "Gallery permission required");
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath =
        "${tempDir.path}/popbom_${DateTime.now().millisecondsSinceEpoch}.mp4";

    try {
      _showDownloadDialog(context);

      final dio = Dio();
      await dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (r, t) {
          if (t > 0) {
            downloadProgress.value = r / t;
          }
        },
      );

      await PhotoManager.editor.saveVideo(
        File(filePath),
        title: "PopBom_${DateTime.now().millisecondsSinceEpoch}",
      );

      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      }
      _showSuccessDialog(context);
    } catch (e) {
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      }
      _showSnackBar(context, "Download failed");
    } finally {
      downloadProgress.value = 0.0;
      try {
        File(filePath).delete();
      } catch (_) {}
    }
  }



  // Future<bool> _requestStoragePermission(BuildContext context) async {
  //   if (Platform.isAndroid) {
  //     // Check Android version
  //     final androidInfo = await Permission.storage.status;
  //
  //     // For Android 13+ (API 33+)
  //     if (await Permission.photos.isGranted) {
  //       return true;
  //     }
  //
  //     final photosStatus = await Permission.photos.request();
  //     if (photosStatus.isGranted) {
  //       return true;
  //     }
  //
  //     // For older Android
  //     final storageStatus = await Permission.storage.request();
  //     if (storageStatus.isGranted) {
  //       return true;
  //     }
  //
  //     // Permission denied
  //     if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
  //       _showPermissionDialog(context);
  //     } else {
  //       _showSnackBar(context, 'Storage permission required');
  //     }
  //     return false;
  //   }
  //
  //   return true; // iOS doesn't need permission
  // }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_for_offline,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Downloading Video',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: downloadProgress.value,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(downloadProgress.value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 12),
              Text(
                'Please wait...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Video saved to your gallery',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Storage permission is required to download videos. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ================================================================
  // ⭐ Share Tile Widget (with SVG or Icon fallback)
  // ================================================================
  Widget _tile({
    required String label,
    String? asset,
    IconData? iconData,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return _ShareCircle(
      label: label,
      svgAsset: asset,
      iconData: iconData,
      onTap: onTap,
      iconColor: iconColor,
      outerDiameter: 52,
      iconBox: 28,
      tileWidth: 70,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ================================================================
    // ⭐ FIRST ROW – TOP SOCIAL APPS
    // ================================================================
    final List<Widget> firstRow = [
      _tile(
        label: "WhatsApp",
        asset: "assets/icon/whatsapp.svg",
        onTap: () => _runShare(
          "whatsapp",
              () => safeLaunch(
                "whatsapp://send?text=${Uri.encodeComponent("$shareText\n$shareLink")}",
                fallback:
                "https://wa.me/?text=${Uri.encodeComponent("$shareText\n$shareLink")}",
              ),
        ),
      ),

      _tile(
        label: "Instagram",
        asset: "assets/icon/Instagram_logo.svg",
        onTap: () => _runShare(
          "instagram",
              () => safeLaunch(
            "instagram://app",
            fallback: "https://instagram.com/",
          ),
        ),
      ),

      _tile(
        label: "Facebook",
        asset: "assets/icon/facebook.svg",
        onTap: () => _runShare(
          "facebook",
              () => safeLaunch(
            "fb://facewebmodal/f?href=$shareLink",
            fallback: "https://www.facebook.com/sharer/sharer.php?u=$shareLink",
          ),
        ),
      ),

      _tile(
        label: "Messenger",
        asset: "assets/icon/messenger_logo.svg",
        onTap: () => _runShare(
          "messenger",
              () => safeLaunch(
                "fb-messenger://share?link=${Uri.encodeComponent(shareLink)}",
                fallback:
                "https://m.me/?link=${Uri.encodeComponent(shareLink)}",
              ),
        ),
      ),

      _tile(
        label: "TikTok",
        asset: "assets/icon/tiktok.svg",
        onTap: () => _runShare(
          "tiktok",
              () => Share.share("$shareText\n$shareLink"),
        ),
      ),

      _tile(
        label: "Snapchat",
        asset: "assets/icon/snapchat.svg",
        onTap: () => _runShare(
          "snapchat",
              () => safeLaunch("snapchat://"),
        ),
      ),
    ];

    // ================================================================
    // ⭐ SECOND ROW – MORE APPS (with Material Icons fallback)
    // ================================================================
    final List<Widget> secondRow = [
      _tile(
        label: "X",
        asset: "assets/icon/twitter.svg",
        onTap: () => _runShare(
          "twitter",
              () => safeLaunch(
            "twitter://post?message=${Uri.encodeComponent("$shareText\n$shareLink")}",
            fallback:
            "https://twitter.com/intent/tweet?text=${Uri.encodeComponent("$shareText\n$shareLink")}",
          ),
        ),
      ),

      _tile(
        label: "Telegram",
        asset: "assets/icon/telegram.svg",
        onTap: () => _runShare(
          "telegram",
              () => safeLaunch(
                "tg://msg?text=${Uri.encodeComponent("$shareText\n$shareLink")}",
                fallback:
                "https://t.me/share/url?url=${Uri.encodeComponent(shareLink)}&text=${Uri.encodeComponent(shareText)}",
              ),
        ),
      ),

      _tile(
        label: "SMS",
        iconData: Icons.message,
        iconColor: Colors.green,
        onTap: () => _runShare(
          "sms",
              () => safeLaunch(
                Platform.isIOS
                    ? "sms:&body=${Uri.encodeComponent("$shareText\n$shareLink")}"
                    : "sms:?body=${Uri.encodeComponent("$shareText\n$shareLink")}",
              ),
        ),
      ),

      _tile(
        label: "Email",
        iconData: Icons.email,
        iconColor: Colors.blue,
        onTap: () => _runShare(
          "email",
              () => safeLaunch(
                "mailto:?subject=${Uri.encodeComponent(shareText)}&body=${Uri.encodeComponent(shareLink)}",
              ),
        ),
      ),

      _tile(
        label: "Copy Link",
        iconData: Icons.link,
        iconColor: Colors.orange,
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: shareLink));
          await actionCtrl.sharePost(postId: postId, platform: 'copy_link');
          _showSnackBar(context, 'Link copied to clipboard');
        },
      ),

      _tile(
        label: "More",
        iconData: Icons.share,
        iconColor: Colors.purple,
        onTap: () => _runShare(
          "more",
              () => Share.share("$shareText\n$shareLink"),
        ),
      ),
    ];

    // ================================================================
    // ⭐ DOWNLOAD BUTTON
    // ================================================================
    final downloadButton = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF21E9A3), Color(0xFF6DF844)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download_rounded, color: Colors.black, size: 24),
          SizedBox(width: 12),
          Text(
            'Download Video',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // ================================================================
    // ⭐ UI LAYOUT
    // ================================================================
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Share to",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: firstRow.length,
                itemBuilder: (_, i) => firstRow[i],
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: secondRow.length,
                itemBuilder: (_, i) => secondRow[i],
                separatorBuilder: (_, __) => const SizedBox(width: 10),
              ),
            ),

            const SizedBox(height: 20),

            Divider(color: cs.onSurface.withOpacity(0.1), thickness: 1),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () async {
                final navContext = context;
                Navigator.pop(navContext);

                await Future.delayed(const Duration(milliseconds: 150));

                if (videoUrl != null) {
                  saveVideoWithPhotoManager(navContext, videoUrl!);
                } else {
                  _showSnackBar(navContext, "Video not available");
                }
              },
              child: downloadButton,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ⭐ SHARE CIRCLE WIDGET (Updated with Icon support)
// ===================================================================
class _ShareCircle extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? svgAsset;
  final IconData? iconData;
  final double tileWidth;
  final double outerDiameter;
  final double iconBox;
  final Color? iconColor;

  const _ShareCircle({
    required this.label,
    required this.onTap,
    this.svgAsset,
    this.iconData,
    this.tileWidth = 70,
    this.outerDiameter = 50,
    this.iconBox = 26,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: tileWidth,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
            customBorder: const CircleBorder(),
            child: Ink(
              width: outerDiameter,
              height: outerDiameter,
              decoration: BoxDecoration(
                color: cs.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: iconData != null
                    ? Icon(
                  iconData,
                  size: iconBox,
                  color: iconColor ?? cs.onSurfaceVariant,
                )
                    : SvgPicture.asset(
                  svgAsset!,
                  width: iconBox,
                  height: iconBox,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}