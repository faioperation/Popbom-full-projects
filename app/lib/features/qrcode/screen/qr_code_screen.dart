import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:popbom/features/common/widget/share_sheet.dart';
import 'package:popbom/features/qrcode/controller/share_profile_controller.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/qrcode/screen/qr_scan_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:popbom/theme/theme_provider.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final shareCtrl = Get.find<ShareProfileController>();
  final authCtrl = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    if (shareCtrl.profileUrl.value.isEmpty) {
      shareCtrl.fetchShareProfile();
    }
  }


  void _openShareSheet(BuildContext context) {
    final user = authCtrl.userModel;
    final link = shareCtrl.profileUrl.value;

    if (link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Share link not ready")));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ShareSheet(
          postId: user?.id ?? "", // 🔥 profile share tracking
          shareText: "Check out my profile on PopBom 👇",
          shareLink: link,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cs = Theme.of(context).colorScheme;

    final user = authCtrl.userModel;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "QR Code",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: cs.onBackground,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: cs.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, size: 18, color: cs.onBackground),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QrScannerPage(isDark: isDark),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// -------- CARD --------
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 36),
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),

                      /// NAME
                      Text(
                        user?.name ?? "User",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// USERNAME
                      Text(
                        "@${user?.username ?? ''}",
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 16),

                      /// QR CODE
                      Obx(() {
                        if (shareCtrl.loading.value) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (shareCtrl.profileUrl.value.isEmpty) {
                          return const Text("Failed to load QR");
                        }

                        return Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: QrImageView(
                            data: shareCtrl.profileUrl.value,
                            size: 180,
                            version: QrVersions.auto,
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                /// PROFILE IMAGE
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    user?.photo?.isNotEmpty == true
                        ? user!.photo!
                        : "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// -------- ACTION BUTTONS --------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: SvgPicture.asset(
                        'assets/icon/copy_link.svg',
                        width: 22,
                        height: 22,
                      ),
                      label: "Copy link",
                      onTap: () async {
                        await Clipboard.setData(
                          ClipboardData(text: shareCtrl.profileUrl.value),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Link copied")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: SvgPicture.asset(
                        'assets/icon/share_link.svg',
                        width: 22,
                        height: 22,
                      ),
                      label: "Share link",
                      onTap: () => _openShareSheet(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            const Text(
              '',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
