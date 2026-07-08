import 'package:flutter/material.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  int _currentIndex = 0;

  final List<String> _images = const [
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
  ];

  void _snack(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cs.inverseSurface,
        content: Text(msg, style: TextStyle(color: cs.onInverseSurface)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: cs.onBackground, size: 26),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "My 2020",
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onBackground,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Upload up to 8 photos",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Image Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 480,
                          width:  Curves.easeOut.transform(value) * 260,
                          child: child,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Text(
                                "${index + 1}/${_images.length}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- Gradient Select Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: GestureDetector(
                onTap: () => _snack('Select photos (demo)'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Select photos",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Bottom Tabs (tap returns a result to Camera)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bottomTab(context, "60s", false, onTap: () {
                  Navigator.pop(context, '60s');
                }),
                const SizedBox(width: 20),
                _bottomTab(context, "15s", false, onTap: () {
                  Navigator.pop(context, '15s');
                }),
                const SizedBox(width: 20),
                _bottomTab(context, "Templates", true),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _bottomTab(BuildContext context, String text, bool active,
      {VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    final child = Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: active ? cs.onBackground : cs.onBackground.withOpacity(0.6),
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onBackground,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );

    return onTap == null
        ? child
        : GestureDetector(onTap: onTap, child: child);
  }
}
