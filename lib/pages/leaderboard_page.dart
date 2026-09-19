import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // ============================================================
  // STATE
  // ============================================================

  List<LeaderboardItem> leaderboard = [];

  SessionUser? currentUser;

  bool isLoading = true;
  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  // ============================================================
  // LOAD LEADERBOARD
  // ============================================================

  Future<void> _loadLeaderboard() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await SessionService.getCurrentUser();
      final data = await GameService.getLeaderboard();

      if (!mounted) return;

      setState(() {
        currentUser = user;
        leaderboard = data;
        isLoading = false;
      });

      debugPrint('========================================');
      debugPrint('LEADERBOARD LOADED');
      debugPrint('Total Users : ${data.length}');

      for (final item in data) {
        debugPrint(
          '#${item.rank} ${item.name} | '
          'Score: ${item.score} | '
          'Correct: ${item.correct} | '
          'Wrong: ${item.wrong}',
        );
      }

      debugPrint('========================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('LEADERBOARD ERROR: $e');
    }
  }

  // ============================================================
  // CHECK CURRENT USER
  // ============================================================

  bool _isCurrentUser(LeaderboardItem user) {
    if (currentUser == null) {
      return false;
    }

    return user.userId == currentUser!.id;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF89F7FE),
              Color(0xFF66A6FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        "🏆 Leaderboard",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Refresh
                    IconButton(
                      tooltip: "Refresh",
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      onPressed: isLoading
                          ? null
                          : _loadLeaderboard,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT STATE
  // ============================================================

  Widget _buildContent() {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
            SizedBox(height: 16),
            Text(
              "Loading leaderboard...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            const Text(
              "Failed to load leaderboard",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadLeaderboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

    if (leaderboard.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),

            Icon(
              Icons.emoji_events_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 16),

            Center(
              child: Text(
                "No leaderboard data yet.",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            SizedBox(height: 8),

            Center(
              child: Text(
                "Complete a game to appear on the leaderboard.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ==========================================================
    // LEADERBOARD
    // ==========================================================

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Text(
            "Top Learners 🌟",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Reading Comprehension Achievement",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // TOP 3
          // ======================================================

          if (leaderboard.isNotEmpty)
            _buildTopThree(),

          const SizedBox(height: 20),

          // ======================================================
          // OTHER USERS
          // ======================================================

          if (leaderboard.length > 3)
            ...leaderboard
                .skip(3)
                .map(
                  (user) => _buildLeaderboardItem(user),
                ),

          // ======================================================
          // CURRENT USER INFORMATION
          // ======================================================

          _buildCurrentUserInfo(),
        ],
      ),
    );
  }

  // ============================================================
  // TOP THREE
  // ============================================================

  Widget _buildTopThree() {
    final topThree = leaderboard.take(3).toList();

    return Column(
      children: [
        // Juara 1
        if (topThree.isNotEmpty)
          _buildTopUserCard(
            topThree[0],
            medal: "🥇",
            title: "1st Place",
          ),

        const SizedBox(height: 12),

        // Juara 2 & 3
        if (topThree.length > 1)
          Row(
            children: [
              Expanded(
                child: _buildSmallTopUserCard(
                  topThree[1],
                  medal: "🥈",
                ),
              ),

              if (topThree.length > 2)
                const SizedBox(width: 12),

              if (topThree.length > 2)
                Expanded(
                  child: _buildSmallTopUserCard(
                    topThree[2],
                    medal: "🥉",
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // ============================================================
  // FIRST PLACE
  // ============================================================

  Widget _buildTopUserCard(
    LeaderboardItem user, {
    required String medal,
    required String title,
  }) {
    final isYou = _isCurrentUser(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE259),
            Color(0xFFFFA751),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isYou
              ? Colors.blueAccent
              : Colors.orange,
          width: isYou ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            medal,
            style: const TextStyle(
              fontSize: 45,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isYou ? "${user.name} (You)" : user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${user.score} pts",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "✔ ${user.correct}   ✘ ${user.wrong}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECOND / THIRD PLACE
  // ============================================================

  Widget _buildSmallTopUserCard(
    LeaderboardItem user, {
    required String medal,
  }) {
    final isYou = _isCurrentUser(user);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isYou
            ? const Color(0xFFFFF3CD)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isYou
              ? Colors.orange
              : Colors.grey.shade300,
          width: isYou ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            medal,
            style: const TextStyle(
              fontSize: 32,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            isYou ? "${user.name} (You)" : user.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "${user.score} pts",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "✔ ${user.correct}  ✘ ${user.wrong}",
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL LEADERBOARD ITEM
  // ============================================================

  Widget _buildLeaderboardItem(
    LeaderboardItem user,
  ) {
    final isYou = _isCurrentUser(user);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isYou
            ? const LinearGradient(
                colors: [
                  Color(0xFFFFE259),
                  Color(0xFFFFA751),
                ],
              )
            : null,
        color: isYou ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isYou
              ? Colors.orange
              : Colors.grey.shade300,
          width: isYou ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // ======================================================
          // RANK
          // ======================================================

          CircleAvatar(
            radius: 22,
            backgroundColor: isYou
                ? Colors.orange
                : Colors.blueAccent,
            child: Text(
              "${user.rank}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ======================================================
          // NAME
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isYou
                      ? "${user.name} (You)"
                      : user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isYou
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Correct: ${user.correct} • Wrong: ${user.wrong}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // SCORE
          // ======================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                "${user.score} pts",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isYou
                      ? Colors.black
                      : Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 4),

              if (isYou)
                const Text(
                  "Your Score",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT USER INFO
  // ============================================================

  Widget _buildCurrentUserInfo() {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    LeaderboardItem? currentLeaderboardUser;

    for (final item in leaderboard) {
      if (item.userId == currentUser!.id) {
        currentLeaderboardUser = item;
        break;
      }
    }

    if (currentLeaderboardUser == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_rounded,
            color: Colors.blueAccent,
            size: 30,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Ranking",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "#${currentLeaderboardUser.rank} • "
                  "${currentLeaderboardUser.score} pts",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.orange,
            size: 30,
          ),
        ],
      ),
    );
  }
}