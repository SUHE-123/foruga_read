import 'package:flutter/material.dart';

import '../models/game_progress.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';

import 'quiz_game_page.dart';
import 'drag_match_page.dart';
import 'gues_word_page.dart';
import 'true_false_page.dart';
import 'sentence_matching_page.dart';
import 'five_w_one_h_page.dart';

class LevelSelectionPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int gameTypeId;
  final String gameTitle;

  const LevelSelectionPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.gameTypeId,
    required this.gameTitle,
  });

  @override
  State<LevelSelectionPage> createState() => _LevelSelectionPageState();
}

class _LevelSelectionPageState extends State<LevelSelectionPage> {
  UserProgress? userProgress;

  bool isLoading = true;
  String? errorMessage;

  // ============================================================
  // APP COLORS
  // ============================================================

  static const Color lightBlue = Color(0xFF6DD5FA);
  static const Color skyBlue = Color(0xFF4FACFE);
  static const Color primaryBlue = Color(0xFF2980B9);
  static const Color deepBlue = Color(0xFF1F5F8B);
  static const Color backgroundColor = Color(0xFFF7FBFE);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  // ============================================================
  // LOAD PROGRESS
  // ============================================================

  Future<void> loadProgress() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await SessionService.getCurrentUser();

      if (user == null || user.id.isEmpty) {
        throw Exception(
          'User session not found. Please log in again.',
        );
      }

      debugPrint('========================================');
      debugPrint('LOADING USER PROGRESS');
      debugPrint('User ID    : ${user.id}');
      debugPrint('User Name  : ${user.name}');
      debugPrint('Story ID   : ${widget.storyId}');
      debugPrint('Story      : ${widget.storyTitle}');
      debugPrint('Game ID    : ${widget.gameTypeId}');
      debugPrint('Game       : ${widget.gameTitle}');
      debugPrint('========================================');

      final result = await GameService.getUserProgress(
        userId: user.id,
        storyId: widget.storyId,
      );

      if (!mounted) return;

      setState(() {
        userProgress = result;
        isLoading = false;
      });

      debugPrint('========================================');
      debugPrint('USER PROGRESS LOADED');
      debugPrint('Total Levels : ${result.levels.length}');

      for (final level in result.levels) {
        debugPrint(
          'Level ${level.levelOrder} - ${level.name} | '
          'Progress: ${level.progressPercentage}% | '
          'Completed: ${level.completed} | '
          'Unlocked: ${level.isUnlocked}',
        );
      }

      debugPrint('========================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('========================================');
      debugPrint('FAILED TO LOAD USER PROGRESS');
      debugPrint('$e');
      debugPrint('========================================');
    }
  }

  // ============================================================
  // LEVEL ICON
  // ============================================================

  IconData _getLevelIcon(int levelOrder) {
    switch (levelOrder) {
      case 1:
        return Icons.looks_one_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      case 4:
        return Icons.looks_4_rounded;
      case 5:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // ============================================================
  // LEVEL COLOR
  // ============================================================

  Color _getLevelColor(int levelOrder) {
    switch (levelOrder) {
      case 1:
        return const Color(0xFF43B883); // Green
      case 2:
        return const Color(0xFF2980B9); // Blue
      case 3:
        return const Color(0xFFFFB52E); // Yellow
      case 4:
        return const Color(0xFF8B72E8); // Purple
      case 5:
        return const Color(0xFFFF9F43); // Orange
      default:
        return primaryBlue;
    }
  }

  // ============================================================
  // GAME ICON
  // ============================================================

  IconData _getGameIcon() {
    switch (widget.gameTypeId) {
      case 1:
        return Icons.quiz_rounded;
      case 2:
        return Icons.compare_arrows_rounded;
      case 3:
        return Icons.lightbulb_rounded;
      case 4:
        return Icons.rule_rounded;
      case 5:
        return Icons.format_align_left_rounded;
      case 6:
        return Icons.question_mark_rounded;
      default:
        return Icons.sports_esports_rounded;
    }
  }

  // ============================================================
  // GAME COLOR
  // ============================================================

  Color _getGameColor() {
    switch (widget.gameTypeId) {
      case 1:
        return primaryBlue;
      case 2:
        return const Color(0xFF43B883);
      case 3:
        return const Color(0xFFFFB52E);
      case 4:
        return const Color(0xFFFF8A65);
      case 5:
        return const Color(0xFF8B72E8);
      case 6:
        return const Color(0xFF4FACFE);
      default:
        return primaryBlue;
    }
  }

  // ============================================================
  // CHECK ACCESS
  // ============================================================

  bool _canPlay(LevelProgress level) {
    // Level 1 selalu terbuka.
    if (level.levelOrder == 1) {
      return true;
    }

    // Level yang sudah selesai tetap dapat dimainkan ulang.
    if (level.completed) {
      return true;
    }

    // Level yang sudah dibuka oleh sistem.
    if (level.isUnlocked) {
      return true;
    }

    return false;
  }

  // ============================================================
  // SELECT LEVEL
  // ============================================================

  void _selectLevel(LevelProgress level) {
    final canPlay = _canPlay(level);

    if (!canPlay) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This level is locked. Complete the previous level with at least 40%.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

      return;
    }

    debugPrint('========================================');
    debugPrint('LEVEL SELECTED');
    debugPrint('Game       : ${widget.gameTitle}');
    debugPrint('Game ID    : ${widget.gameTypeId}');
    debugPrint('Story      : ${widget.storyTitle}');
    debugPrint('Story ID   : ${widget.storyId}');
    debugPrint('Level      : ${level.name}');
    debugPrint('Level ID   : ${level.levelId}');
    debugPrint('Level Order: ${level.levelOrder}');
    debugPrint('Completed  : ${level.completed}');
    debugPrint('Unlocked   : ${level.isUnlocked}');
    debugPrint('Progress   : ${level.progressPercentage}%');
    debugPrint('========================================');

    // ==========================================================
    // 1. QUIZ
    // ==========================================================

    if (widget.gameTypeId == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizGamePage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 2. WORD MATCHING
    // ==========================================================

    if (widget.gameTypeId == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DragMatchPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 3. GUESS THE WORD
    // ==========================================================

    if (widget.gameTypeId == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GuessWordPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 4. TRUE OR FALSE
    // ==========================================================

    if (widget.gameTypeId == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrueFalsePage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 5. SENTENCE MATCHING
    // ==========================================================

    if (widget.gameTypeId == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SentenceMatchingPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 6. 5W1H CHALLENGE
    // ==========================================================

    if (widget.gameTypeId == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FiveWOneHPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            levelId: level.levelId,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // UNKNOWN GAME
    // ==========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.gameTitle} does not have a game page yet.',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: deepBlue,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Select Level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: deepBlue,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: RefreshIndicator(
          color: primaryBlue,
          backgroundColor: Colors.white,
          onRefresh: loadProgress,
          child: _buildBody(),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          const Center(
            child: CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Loading levels...',
              style: TextStyle(
                color: deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),

          _buildErrorIllustration(),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Oops! Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: deepBlue,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: ElevatedButton.icon(
              onPressed: loadProgress,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (userProgress == null ||
        userProgress!.levels.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),

          Icon(
            Icons.auto_stories_rounded,
            size: 76,
            color: skyBlue.withValues(alpha: 0.65),
          ),

          const SizedBox(height: 18),

          const Center(
            child: Text(
              'No Levels Available',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: deepBlue,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                'There are no levels available for this game yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final levels = userProgress!.levels;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        30,
      ),
      children: [
        _buildHeader(),

        const SizedBox(height: 22),

        _buildInstruction(),

        const SizedBox(height: 18),

        ...levels.map(_buildLevelCard),
      ],
    );
  }

  // ============================================================
  // ERROR ILLUSTRATION
  // ============================================================

  Widget _buildErrorIllustration() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8E5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          Icons.cloud_off_rounded,
          size: 48,
          color: Color(0xFFFF7A6E),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final gameColor = _getGameColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            lightBlue,
            primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAME ICON
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _getGameIcon(),
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(width: 15),

              // TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GAME CHALLENGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.gameTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // STORY CHIP
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.storyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DESCRIPTION
          const Text(
            'Choose your level and start your English adventure!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // SMALL GAME COLOR INDICATOR
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: gameColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Complete levels to unlock new challenges!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INSTRUCTION
  // ============================================================

  Widget _buildInstruction() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F5FD),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.touch_app_rounded,
            color: primaryBlue,
            size: 22,
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Level',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: deepBlue,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Start from Beginner and keep improving!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LEVEL CARD
  // ============================================================

  Widget _buildLevelCard(LevelProgress level) {
    final color = _getLevelColor(level.levelOrder);
    final canPlay = _canPlay(level);
    final isCompleted = level.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: canPlay
              ? color.withValues(alpha: 0.13)
              : Colors.grey.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: canPlay ? 0.055 : 0.025,
            ),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _selectLevel(level),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // LEVEL NUMBER / ICON
                  // ==================================================

                  _buildLevelIcon(
                    level,
                    color,
                    canPlay,
                    isCompleted,
                  ),

                  const SizedBox(width: 14),

                  // ==================================================
                  // LEVEL INFORMATION
                  // ==================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LEVEL ${level.levelOrder}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: 1,
                                      color: canPlay
                                          ? color
                                          : Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    level.name,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w800,
                                      color: canPlay
                                          ? deepBlue
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            _buildStatusBadge(
                              level,
                              canPlay,
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          level.description.isNotEmpty
                              ? level.description
                              : 'Improve your English reading skills.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: canPlay
                                ? Colors.black54
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // ======================================================
              // PROGRESS
              // ======================================================

              if (level.progressPercentage > 0)
                _buildProgress(
                  level,
                  color,
                  isCompleted,
                ),

              if (level.progressPercentage > 0)
                const SizedBox(height: 11),

              // ======================================================
              // BOTTOM INFORMATION
              // ======================================================

              Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.emoji_events_rounded
                        : canPlay
                            ? Icons.play_circle_fill_rounded
                            : Icons.lock_rounded,
                    size: 17,
                    color: isCompleted
                        ? const Color(0xFFFFB52E)
                        : canPlay
                            ? color
                            : Colors.grey.shade400,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'Best score: ${level.lastScore}'
                          : canPlay
                              ? 'Ready to play!'
                              : 'Complete the previous level first',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? const Color(0xFFDA8B00)
                            : canPlay
                                ? color
                                : Colors.grey.shade400,
                      ),
                    ),
                  ),

                  // ARROW
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: canPlay
                          ? color.withValues(alpha: 0.10)
                          : Colors.grey.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      canPlay
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_outline_rounded,
                      size: 18,
                      color: canPlay
                          ? color
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LEVEL ICON
  // ============================================================

  Widget _buildLevelIcon(
    LevelProgress level,
    Color color,
    bool canPlay,
    bool isCompleted,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: canPlay
                ? LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.18),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: canPlay
                ? null
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            canPlay
                ? _getLevelIcon(level.levelOrder)
                : Icons.lock_rounded,
            color: canPlay
                ? color
                : Colors.grey.shade400,
            size: 30,
          ),
        ),

        // COMPLETED CHECK
        if (isCompleted)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF43B883),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress(
    LevelProgress level,
    Color color,
    bool isCompleted,
  ) {
    final progress = (level.progressPercentage / 100)
        .clamp(0.0, 1.0);

    final progressColor = isCompleted
        ? const Color(0xFF43B883)
        : color;

    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
              ),
            ),

            const Spacer(),

            Text(
              '${level.progressPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: progressColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor:
                AlwaysStoppedAnimation<Color>(
              progressColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(
    LevelProgress level,
    bool canPlay,
  ) {
    String text;
    Color color;
    IconData icon;

    if (level.completed) {
      text = 'COMPLETED';
      color = const Color(0xFF43B883);
      icon = Icons.check_circle_rounded;
    } else if (canPlay) {
      text = 'UNLOCKED';
      color = primaryBlue;
      icon = Icons.lock_open_rounded;
    } else {
      text = 'LOCKED';
      color = Colors.grey.shade500;
      icon = Icons.lock_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}