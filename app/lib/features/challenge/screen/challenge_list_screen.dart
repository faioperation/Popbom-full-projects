import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/challenge/controller/challenge_list_controller.dart';
import 'package:popbom/features/challenge/screen/challenge_rank_screen.dart';
import 'package:popbom/features/challenge/screen/challenge_screen.dart';
import 'package:popbom/features/rank/screen/rank_screen.dart';

class ChallengeListScreen extends StatefulWidget {
  @override
  _ChallengeListScreenState createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  int _selectedCategory = 0;

  final List<String> categories = [
    'All',
    'My Challenges',
    'Participant Challenges',
  ];

  static const Color green1 = Color(0xff21E6A0);
  static const Color green2 = Color(0xFF6DF844);

  final ChallengeListController c = Get.find<ChallengeListController>();

  @override
  void initState() {
    super.initState();

    /// Load default category → ALL
    Future.microtask(() {
      c.fetchAll();
    });
  }

  /// category changed → load correct API
  void _loadCategoryData() {
    if (_selectedCategory == 0) c.fetchAll();
    if (_selectedCategory == 1) c.fetchMyChallenges();
    if (_selectedCategory == 2) c.fetchParticipated();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);

    return GetBuilder<ChallengeListController>(
      builder: (ctrl) {
        /// Which data to show?
        List challenges = [];
        if (_selectedCategory == 0) challenges = ctrl.allChallenges;
        if (_selectedCategory == 1) challenges = ctrl.myChallenges;
        if (_selectedCategory == 2) challenges = ctrl.participatedChallenges;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,size: 18,),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Challenges List',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),

          body: Column(
            children: [
              // CATEGORY TAB
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final selected = _selectedCategory == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                        _loadCategoryData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(
                          left: 12,
                          top: 8,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: selected
                              ? const LinearGradient(colors: [green1, green2])
                              : null,
                          color: selected
                              ? null
                              : theme.dividerColor.withOpacity(0.2),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: selected ? Colors.black : textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// LOADING STATE
              if (ctrl.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (challenges.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "You haven't participated in any challenges yet.",
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final item = challenges[index];

                      return ChallengeCard(
                        name: item["challengeName"] ?? "No Title",
                        participants:
                            "Participant: ${item['participantsCount'] ?? 0}",
                        endDate: item["challengeEndDate"] ?? "",
                        image: item["challengePoster"] ?? "",
                        selectedCategory: _selectedCategory,
                        isDark: isDark,
                        challengeId: item["_id"],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String challengeId;
  final String name;
  final String participants;
  final String endDate;
  final String image;
  final bool isDark;
  final int selectedCategory;

  static const Color green1 = Color(0xff21E6A0);
  static const Color green2 = Color(0xFF6DF844);

  const ChallengeCard({
    super.key,
    required this.challengeId,
    required this.name,
    required this.participants,
    required this.endDate,
    required this.image,
    required this.selectedCategory,
    this.isDark = false,
  });

  void _navigate(BuildContext context) {
    if (selectedCategory == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeScreen(challengeId: challengeId,),
        ),
      );
    } else if (selectedCategory == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChallengeRankScreen(challengeId: challengeId),
          settings: const RouteSettings(
            arguments: {"type": "my"},
          ),
        ),
      );
    }else if (selectedCategory == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChallengeRankScreen(
          challengeId: challengeId,
        )),
      );
    }
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return "N/A";
    try {
      final d = DateTime.parse(iso);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    final subTextColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;

    String buttonLabel = 'Join';
    if (selectedCategory == 1) buttonLabel = 'View';
    if (selectedCategory == 2) buttonLabel = 'See Result';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.grey.shade900 : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // IMAGE SECTION
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // PARTICIPANTS SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: subTextColor),
                const SizedBox(width: 4),
                Text(
                  participants,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // END DATE SECTION (NEW)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Ends: ${_formatDate(endDate)}",
              style: TextStyle(
                fontSize: 12,
                color: subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ACTION BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _navigate(context),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [green1, green2]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
