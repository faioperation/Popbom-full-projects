import 'package:flutter/material.dart';

class LiveRewardsScreen extends StatefulWidget {
  const LiveRewardsScreen({super.key});

  @override
  State<LiveRewardsScreen> createState() => _LiveRewardsScreenState();
}

class _LiveRewardsScreenState extends State<LiveRewardsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final double goLiveProgress = 0.12;
  final double engagementProgress = 0.18;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _card({required Widget child, EdgeInsets? padding, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : const Color(0x12000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE6E6E6)),
      ),
      child: child,
    );
  }

  Widget _tickBar(bool isDark) {
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: isDark ? Colors.white12 : const Color(0xFFE6E6E6),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('5%', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
            Text('10%', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
            Text('15%', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
            Text('20%', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _progress({
    required IconData icon,
    required String title,
    required double value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : const Color(0xFFE8F9ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 18, color: Color(0xff21E6A0)),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Your content engagement is measured by your active fans',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54, height: 1.2),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
            backgroundColor: isDark ? Colors.white12 : const Color(0xFFEDEDED),
            color: const Color(0xff21E6A0),
          ),
        ),
        _tickBar(isDark),
      ],
    );
  }

  // ✅ এখানে gradient যোগ করা হলো (Exchange বাটনের মতো)
  // ✅ Gradient + Corrected Height
  PreferredSizeWidget _gradientSegmentTabs(bool isDark) {
    const grad = LinearGradient(
      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return PreferredSize(
      preferredSize: const Size.fromHeight(84), // 🔹 height ছোট করা হলো (আগে 120 ছিল)
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          height: 80, // 🔹 আগের বড় height কমিয়ে natural করা হলো
          decoration: BoxDecoration(
            gradient: grad, // 🎨 gradient রাখা হয়েছে
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.05 : 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Available rewards',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'USD 0.00',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Upcoming rewards',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'USD 0.00',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _availableTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Rewards',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 6),
              Text('USD 0.00',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Exchange',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Withdraw',
                  style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 2),
              Text('Daily withdrawal limit \$1000/\$1000',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _card(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transactions',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              Text('No transactions to display',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _upcomingTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly mission Rewards',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 6),
              Text('Total Diamonds: 0',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xff4E4F57))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _progress(icon: Icons.videocam, title: 'Go Live days', value: goLiveProgress, isDark: isDark),
              const SizedBox(height: 10),
              _progress(icon: Icons.groups, title: 'Content engagement', value: engagementProgress, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final appBarBg = isDark ? Colors.black : Colors.white;
    final appBarFg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarBg,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios, color: appBarFg),
        ),
        title: Text('Live Rewards',
            style: TextStyle(color: appBarFg, fontWeight: FontWeight.w700)),
        bottom: _gradientSegmentTabs(isDark),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _availableTab(isDark),
          _upcomingTab(isDark),
        ],
      ),
    );
  }
}
