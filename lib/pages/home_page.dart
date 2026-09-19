import 'package:flutter/material.dart';

import 'story_library_page.dart';
import 'development_page.dart';
import 'leaderboard_page.dart';
import 'about_page.dart';
import 'profile_page.dart';

import '../services/session_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SessionUser? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ===============================================================
  // LOAD SESSION USER
  // ===============================================================

  Future<void> loadUser() async {
    final currentUser = await SessionService.getCurrentUser();

    if (!mounted) return;

    setState(() {
      user = currentUser;
      isLoading = false;
    });
  }

  // ===============================================================
  // PROFILE
  // ===============================================================

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfilePage(),
      ),
    ).then((_) {
      loadUser();
    });
  }

  // ===============================================================
  // STORY LIBRARY
  // ===============================================================

  void openStoryLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StoryLibraryPage(),
      ),
    );
  }

  // ===============================================================
  // LEADERBOARD
  // ===============================================================

  void openLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LeaderboardPage(),
      ),
    );
  }

  // ===============================================================
  // ABOUT APP
  // ===============================================================

  void openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutPage(),
      ),
    );
  }

  // ===============================================================
  // ABOUT DEVELOPMENT
  // ===============================================================

  void openDevelopment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DevelopmentPage(),
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6DD5FA),
              Color(0xFF2980B9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // HEADER
                // =====================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoading
                                ? "Hello 👋"
                                : user == null
                                    ? "Hello 👋"
                                    : "Hello ${user!.name} 👋",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Let's read stories and play!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // =================================================
                    // PROFILE AVATAR
                    // =================================================

                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: openProfile,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Text(
                          user == null || user!.name.isEmpty
                              ? "?"
                              : user!.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =====================================================
                // WELCOME / SCORE CARD
                // =====================================================

                if (!isLoading && user != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        // SCORE
                        Expanded(
                          child: _statItem(
                            icon: Icons.star_rounded,
                            value: user!.score.toString(),
                            label: "Score",
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 45,
                          color: Colors.white30,
                        ),

                        // CORRECT
                        Expanded(
                          child: _statItem(
                            icon: Icons.check_circle_rounded,
                            value: user!.correct.toString(),
                            label: "Correct",
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 45,
                          color: Colors.white30,
                        ),

                        // WRONG
                        Expanded(
                          child: _statItem(
                            icon: Icons.cancel_rounded,
                            value: user!.wrong.toString(),
                            label: "incorrect",
                          ),
                        ),
                      ],
                    ),
                  ),

                // =====================================================
                // GRID MENU
                // =====================================================

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,

                    children: [
                      // =================================================
                      // STORY LIBRARY
                      // =================================================

                      _menuCard(
                        icon: Icons.menu_book_rounded,
                        title: "Story Library",
                        color: Colors.orange,
                        onTap: openStoryLibrary,
                      ),

                      // =================================================
                      // ABOUT DEVELOPMENT
                      // =================================================

                      _menuCard(
                        icon: Icons.groups_rounded,
                        title: "About Development",
                        color: const Color(0xFF2980B9),
                        onTap: openDevelopment,
                      ),

                      // =================================================
                      // LEADERBOARD
                      // =================================================

                      _menuCard(
                        icon: Icons.emoji_events_rounded,
                        title: "Leaderboard",
                        color: Colors.green,
                        onTap: openLeaderboard,
                      ),

                      // =================================================
                      // ABOUT APP
                      // =================================================

                      _menuCard(
                        icon: Icons.info_rounded,
                        title: "About App",
                        color: Colors.blueGrey,
                        onTap: openAbout,
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

  // ===============================================================
  // STAT ITEM
  // ===============================================================

  Widget _statItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 25,
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // MENU CARD
  // ===============================================================

  Widget _menuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}