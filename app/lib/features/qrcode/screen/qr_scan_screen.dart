import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';

class QrScannerPage extends StatefulWidget {
  final bool isDark;
  const QrScannerPage({super.key, required this.isDark});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  bool _handled = false;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late final AnimationController _scanLineCtrl;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanLineCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    final double boxSize = (size.width * 0.72).clamp(240.0, 320.0);
    final Offset boxTopLeft = Offset(
      (size.width - boxSize) / 2,
      (size.height * 0.18),
    );
    final Rect scanWindow =
    Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxSize, boxSize);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onBackground),
        title: Text(
          "Scan",
          style: TextStyle(
            color: cs.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            scanWindow: scanWindow,
            onDetect: (capture) async {
              if (_handled) return;

              final barcode = capture.barcodes.firstOrNull;
              final rawValue = barcode?.rawValue?.trim() ?? "";

              if (rawValue.isEmpty) return;

              _handled = true;

              // 🔹 extract username
              String username = rawValue;

              if (username.contains('/')) {
                final uri = Uri.tryParse(username);
                if (uri != null && uri.pathSegments.isNotEmpty) {
                  username = uri.pathSegments.last;
                }
              }

              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid QR code")),
                );
                _handled = false;
                return;
              }

              try {
                final client = Get.find<NetworkClient>();

                final res = await client.getRequest(
                  "${Urls.baseUrl}/api/share-profile/$username",
                );

                if (!res.isSuccess) {
                  throw Exception("Profile not found");
                }

                final user = res.responseData?['data']?['user'];
                final userId = user?['_id'];
                final avatar =
                    user?['userDetails']?['photo']?.toString() ?? "";

                if (userId == null) {
                  throw Exception("Invalid user");
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(
                      userId: userId,
                      username: username,
                      avatarUrl: avatar,
                    ),
                  ),
                );
              } catch (e) {
                _handled = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to open profile")),
                );
              }
            },
          ),

          /// overlay
          CustomPaint(
            painter: _HoleOverlayPainter(
              hole: scanWindow,
              overlayColor: Colors.black.withOpacity(0.55),
            ),
            size: size,
          ),

          _CornerDecoration(box: scanWindow),

          /// scan line
          AnimatedBuilder(
            animation: _scanLineCtrl,
            builder: (_, __) {
              final dy = scanWindow.top +
                  (scanWindow.height - 2) * _scanLineCtrl.value;
              return Positioned(
                left: scanWindow.left + 8,
                right: scanWindow.right - 8,
                top: dy,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.red.shade400],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),

          /// bottom buttons
          Positioned(
            bottom: 28 + MediaQuery.of(context).padding.bottom,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BigCircleButton(
                  icon: Icons.flash_on,
                  label: 'Flash',
                  onTap: () => _controller.toggleTorch(),
                ),
                _BigCircleButton(
                  icon: Icons.cameraswitch,
                  label: 'Switch',
                  onTap: () => _controller.switchCamera(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- helpers ---------------- */

class _HoleOverlayPainter extends CustomPainter {
  final Rect hole;
  final Color overlayColor;

  _HoleOverlayPainter({required this.hole, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(16)));
    final path = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HoleOverlayPainter oldDelegate) {
    return oldDelegate.hole != hole ||
        oldDelegate.overlayColor != overlayColor;
  }
}

class _CornerDecoration extends StatelessWidget {
  final Rect box;
  const _CornerDecoration({required this.box});

  @override
  Widget build(BuildContext context) {
    const double len = 26;
    const double thick = 4;
    const color = Colors.white;

    return Positioned.fromRect(
      rect: box,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Column(children: [
              Container(width: len, height: thick, color: color),
              Container(width: thick, height: len, color: color),
            ]),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Column(children: [
              Container(width: len, height: thick, color: color),
              Container(width: thick, height: len, color: color),
            ]),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Column(children: [
              Container(width: thick, height: len, color: color),
              Container(width: len, height: thick, color: color),
            ]),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Column(children: [
              Container(width: thick, height: len, color: color),
              Container(width: len, height: thick, color: color),
            ]),
          ),
        ],
      ),
    );
  }
}

class _BigCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BigCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
            ),
            child: Icon(icon, color: cs.onSurface, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.95),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
