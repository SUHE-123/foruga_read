import 'package:flutter/material.dart';

import '../models/game_models.dart';
import 'home_page.dart';
import 'story_library_page.dart';
import 'quiz_game_page.dart';
import 'drag_match_page.dart';
import 'gues_word_page.dart';
import 'true_false_page.dart';
import 'sentence_matching_page.dart';
import 'five_w_one_h_page.dart';

class ResultPage extends StatelessWidget {
  final int storyId;
  final String storyTitle;
  final int gameTypeId;
  final int levelId;

  final int score;
  final int correct;
  final int wrong;
  final int totalQuestions;
  final double percentage;

  final NextLevel? nextLevel;

  const ResultPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.gameTypeId,
    required this.levelId,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.totalQuestions,
    required this.percentage,
    this.nextLevel,
  });

  // ============================================================
  // LEVEL NAME
  // ============================================================

  String get levelName {
    switch (levelId) {
      case 1:
        return 'Beginner';

      case 2:
        return 'Elementary';

      case 3:
        return 'Intermediate';

      case 4:
        return 'Advanced';

      case 5:
        return 'Master';

      default:
        return 'Level $levelId';
    }
  }

  // ============================================================
  // GAME NAME
  // ============================================================

  String get gameName {
    switch (gameTypeId) {
      case 1:
        return 'Quiz';

      case 2:
        return 'Word Matching';

      case 3:
        return 'Guess the Word';

      case 4:
        return 'True or False';

      case 5:
        return 'Sentence Matching';

      case 6:
        return '5W1H Challenge';

      default:
        return 'Game';
    }
  }

  // ============================================================
  // PASS STATUS
  // ============================================================

  bool get isPassed {
    return percentage >= 70;
  }

  // ============================================================
  // HAS NEXT LEVEL
  // ============================================================

  bool get hasNextLevel {
    return isPassed &&
        nextLevel != null &&
        nextLevel!.isUnlocked;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  String getMessage() {
    if (percentage >= 90) {
      return 'Excellent! 🌟';
    }

    if (percentage >= 80) {
      return 'Great Job! 🎉';
    }

    if (percentage >= 70) {
      return 'Good Job! 👍';
    }

    if (percentage >= 50) {
      return 'Keep Practicing! 💪';
    }

    return "Don't Give Up! 🚀";
  }

  // ============================================================
  // RESULT ICON
  // ============================================================

  IconData get resultIcon {
    if (isPassed) {
      return Icons.emoji_events_rounded;
    }

    return Icons.refresh_rounded;
  }

  // ============================================================
  // RESULT COLOR
  // ============================================================

  Color get resultColor {
    if (isPassed) {
      return Colors.green;
    }

    return Colors.orange;
  }

  // ============================================================
  // OPEN GAME
  // ============================================================

  Widget _buildGamePage({
    required int targetLevelId,
  }) {
    switch (gameTypeId) {
      // ========================================================
      // QUIZ
      // ========================================================

      case 1:
        return QuizGamePage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      // ========================================================
      // WORD MATCHING
      // ========================================================

      case 2:
        return DragMatchPage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      // ========================================================
      // GUESS THE WORD
      // ========================================================

      case 3:
        return GuessWordPage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      // ========================================================
      // TRUE OR FALSE
      // ========================================================

      case 4:
        return TrueFalsePage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      // ========================================================
      // SENTENCE MATCHING
      // ========================================================

      case 5:
        return SentenceMatchingPage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      // ========================================================
      // 5W1H
      // ========================================================

      case 6:
        return FiveWOneHPage(
          storyId: storyId,
          storyTitle: storyTitle,
          levelId: targetLevelId,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text(
              'Game is not available.',
            ),
          ),
        );
    }
  }

  // ============================================================
  // CONTINUE TO NEXT LEVEL
  // ============================================================

  void _continueToNextLevel(BuildContext context) {
    if (!hasNextLevel) {
      return;
    }

    final nextLevelId = nextLevel!.levelId;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _buildGamePage(
          targetLevelId: nextLevelId,
        ),
      ),
    );
  }

  // ============================================================
  // RETRY CURRENT LEVEL
  // ============================================================

  void _retryLevel(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _buildGamePage(
          targetLevelId: levelId,
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ==================================================
                  // RESULT ICON
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      resultIcon,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Your Result',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    storyTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$gameName • $levelName',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // RESULT CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ==================================================
                        // SCORE
                        // ==================================================

                        const Text(
                          'SCORE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ==================================================
                        // PERCENTAGE
                        // ==================================================

                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(),

                        const SizedBox(height: 18),

                        // ==================================================
                        // STATISTICS
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: _buildStat(
                                icon: Icons.check_circle_rounded,
                                value: '$correct',
                                label: 'Correct',
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: _buildStat(
                                icon: Icons.cancel_rounded,
                                value: '$wrong',
                                label: 'Wrong',
                                color: Colors.red,
                              ),
                            ),
                            Expanded(
                              child: _buildStat(
                                icon: Icons.quiz_rounded,
                                value: '$totalQuestions',
                                label: 'Questions',
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // PASS / FAIL
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: resultColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: resultColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isPassed
                                    ? Icons.check_circle_rounded
                                    : Icons.info_rounded,
                                color: resultColor,
                                size: 34,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                isPassed
                                    ? 'LEVEL PASSED! 🎉'
                                    : 'KEEP PRACTICING! 💪',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: resultColor,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                isPassed
                                    ? 'Congratulations! You passed this level.'
                                    : 'You need at least 70% to pass this level.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          getMessage(),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),

                        // ==================================================
                        // NEXT LEVEL INFORMATION
                        // ==================================================

                        if (hasNextLevel) ...[
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE3F2FD),
                                  Color(0xFFF1F8FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.lock_open_rounded,
                                  color: Colors.blueAccent,
                                  size: 34,
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'NEXT LEVEL UNLOCKED!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  nextLevel!.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  nextLevel!.description.isEmpty
                                      ? 'Continue your English learning journey.'
                                      : nextLevel!.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ==================================================
                        // MASTER COMPLETED
                        // ==================================================

                        if (isPassed &&
                            nextLevel == null &&
                            levelId == 5) ...[
                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFFF8E1),
                                  Color(0xFFFFF3CD),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.35),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.orange,
                                  size: 42,
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'ALL LEVELS COMPLETED! 🏆',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Congratulations! You have completed all levels of this story.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CONTINUE
                  // ==================================================

                  if (hasNextLevel) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          _continueToNextLevel(context);
                        },
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 25,
                        ),
                        label: Text(
                          'Continue to ${nextLevel!.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],

                  // ==================================================
                  // RETRY
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        _retryLevel(context);
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text(
                        '🔄 Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // READ ANOTHER STORY
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const StoryLibraryPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        '📚 Read Another Story',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // HOME
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        '🏠 Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 27,
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}