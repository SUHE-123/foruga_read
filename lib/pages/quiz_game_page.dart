import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class QuizGamePage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const QuizGamePage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  List<GameQuestion> questions = [];

  int currentQuestion = 0;
  int score = 0;
  int correct = 0;
  int wrong = 0;

  bool isLoading = true;
  bool isSubmitting = false;

  String? errorMessage;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color lightBlue = Color(0xFF6DD5FA);
  static const Color skyBlue = Color(0xFF4FACFE);
  static const Color primaryBlue = Color(0xFF2980B9);
  static const Color deepBlue = Color(0xFF1F5F8B);

  static const Color green = Color(0xFF43B883);
  static const Color yellow = Color(0xFFFFB52E);
  static const Color orange = Color(0xFFFF8A65);
  static const Color purple = Color(0xFF8B72E8);

  static const Color background = Color(0xFFF7FBFE);

  // ============================================================
  // GAME TYPE
  // ============================================================

  static const int gameTypeId = 1;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // ============================================================
  // LOAD QUESTIONS
  // ============================================================

  Future<void> loadQuestions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: gameTypeId,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      setState(() {
        questions = result;
        currentQuestion = 0;
        score = 0;
        correct = 0;
        wrong = 0;
        isLoading = false;
      });

      debugPrint('========================================');
      debugPrint('QUIZ QUESTIONS LOADED');
      debugPrint('Story ID : ${widget.storyId}');
      debugPrint('Story    : ${widget.storyTitle}');
      debugPrint('Game ID  : $gameTypeId');
      debugPrint('Level ID : ${widget.levelId}');
      debugPrint('Total    : ${questions.length}');
      debugPrint('========================================');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('QUIZ ERROR: $e');
    }
  }

  // ============================================================
  // CHECK ANSWER
  // ============================================================

  Future<void> checkAnswer(int selectedOptionId) async {
    if (questions.isEmpty || isSubmitting) return;

    final question = questions[currentQuestion];

    QuestionOption? selectedOption;

    for (final option in question.options) {
      if (option.id == selectedOptionId) {
        selectedOption = option;
        break;
      }
    }

    if (selectedOption == null) {
      return;
    }

    if (selectedOption.isCorrect) {
      score += question.points;
      correct++;
    } else {
      wrong++;
    }

    if (!mounted) return;

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      await finishQuiz();
    }
  }

  // ============================================================
  // FINISH QUIZ
  // ============================================================

  Future<void> finishQuiz() async {
    if (questions.isEmpty || isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final totalQuestions = questions.length;

      final percentage = totalQuestions > 0
          ? (correct / totalQuestions) * 100
          : 0.0;

      debugPrint('========================================');
      debugPrint('QUIZ FINISHED');
      debugPrint('Story ID        : ${widget.storyId}');
      debugPrint('Game Type ID    : $gameTypeId');
      debugPrint('Level ID        : ${widget.levelId}');
      debugPrint('Total Questions : $totalQuestions');
      debugPrint('Correct         : $correct');
      debugPrint('Wrong           : $wrong');
      debugPrint('Score           : $score');
      debugPrint('Percentage      : $percentage');
      debugPrint('========================================');

      final user = await SessionService.getCurrentUser();

      if (user == null || user.id.isEmpty) {
        throw Exception(
          'User session not found. Please log in again.',
        );
      }

      debugPrint('USER ID         : ${user.id}');
      debugPrint('USER NAME       : ${user.name}');

      final gameResult = await GameService.submitResult(
        userId: user.id,
        storyId: widget.storyId,
        gameTypeId: gameTypeId,
        levelId: widget.levelId,
        score: score,
        correct: correct,
        wrong: wrong,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      debugPrint('========================================');
      debugPrint('RESULT SAVED SUCCESSFULLY');
      debugPrint('Result ID       : ${gameResult.resultId}');
      debugPrint('Score           : ${gameResult.score}');
      debugPrint('Correct         : ${gameResult.correct}');
      debugPrint('Wrong           : ${gameResult.wrong}');
      debugPrint('Percentage      : ${gameResult.percentage}');
      debugPrint('========================================');

      if (gameResult.nextLevel != null) {
        debugPrint(
          'Next Level      : ${gameResult.nextLevel!.name}',
        );

        debugPrint(
          'Next Level ID   : ${gameResult.nextLevel!.levelId}',
        );

        debugPrint(
          'Next Level Order: ${gameResult.nextLevel!.levelOrder}',
        );

        debugPrint(
          'Next Unlocked   : ${gameResult.nextLevel!.isUnlocked}',
        );
      } else {
        debugPrint('Next Level      : NONE');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: gameTypeId,
            levelId: widget.levelId,
            score: gameResult.score,
            correct: gameResult.correct,
            wrong: gameResult.wrong,
            totalQuestions: gameResult.totalQuestions,
            percentage: gameResult.percentage,
            nextLevel: gameResult.nextLevel,
          ),
        ),
      );
    } catch (e) {
      debugPrint('FAILED TO SAVE QUIZ RESULT: $e');

      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save quiz result: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // LEVEL NAME
  // ============================================================

  String _getLevelName() {
    switch (widget.levelId) {
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
        return 'Level ${widget.levelId}';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: background,
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
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightBlue,
            primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 3),

              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'QUIZ CHALLENGE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            widget.storyTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              _buildScoreBadge(),
            ],
          ),

          if (!isLoading && questions.isNotEmpty)
            const SizedBox(height: 7),

          if (!isLoading && questions.isNotEmpty)
            _buildQuestionProgress(),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE BADGE
  // ============================================================

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFE082),
            size: 19,
          ),
          const SizedBox(width: 5),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUESTION PROGRESS
  // ============================================================

  Widget _buildQuestionProgress() {
    final progress =
        (currentQuestion + 1) / questions.length;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Question ${currentQuestion + 1} of ${questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            Text(
              _getLevelName(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor:
                Colors.white.withValues(alpha: 0.22),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (questions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildQuiz();
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7FD),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              size: 45,
              color: primaryBlue,
            ),
          ),

          const SizedBox(height: 20),

          const CircularProgressIndicator(
            color: primaryBlue,
            strokeWidth: 3,
          ),

          const SizedBox(height: 15),

          const Text(
            'Preparing your quiz...',
            style: TextStyle(
              color: deepBlue,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Get ready to test your reading skills!',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUIZ
  // ============================================================

  Widget _buildQuiz() {
    final question = questions[currentQuestion];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              17,
              18,
              17,
              12,
            ),
            children: [
              _buildWelcomeRow(),

              const SizedBox(height: 15),

              if (question.readingSkill != null &&
                  question.readingSkill!.isNotEmpty)
                _buildReadingSkill(
                  question.readingSkill!,
                ),

              if (question.readingSkill != null &&
                  question.readingSkill!.isNotEmpty)
                const SizedBox(height: 13),

              _buildQuestionCard(question),

              const SizedBox(height: 18),

              const Text(
                'Choose the best answer',
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 11),

              ...question.options.asMap().entries.map(
                (entry) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 11,
                    ),
                    child: _buildOption(
                      option: entry.value,
                      index: entry.key,
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),

        _buildBottomStats(),
      ],
    );
  }

  // ============================================================
  // WELCOME ROW
  // ============================================================

  Widget _buildWelcomeRow() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                lightBlue,
                skyBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.lightbulb_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Think carefully! 🧠',
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Read the question and choose one answer.',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // READING SKILL
  // ============================================================

  Widget _buildReadingSkill(String skill) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4DF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: yellow.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 16,
              color: Color(0xFFE29A00),
            ),

            const SizedBox(width: 6),

            Text(
              skill,
              style: const TextStyle(
                color: Color(0xFFC27D00),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // QUESTION CARD
  // ============================================================

  Widget _buildQuestionCard(
    GameQuestion question,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        21,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF8FE),
            Color(0xFFF5FBFE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: lightBlue.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(width: 9),

              const Text(
                'QUESTION',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: yellow,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${question.points}',
                      style: const TextStyle(
                        color: deepBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            question.questionText,
            style: const TextStyle(
              color: Color(0xFF183B50),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPTION
  // ============================================================

  Widget _buildOption({
    required QuestionOption option,
    required int index,
  }) {
    final letters = ['A', 'B', 'C', 'D'];

    final letter = index < letters.length
        ? letters[index]
        : '${index + 1}';

    final optionColors = [
      primaryBlue,
      green,
      orange,
      purple,
    ];

    final optionColor =
        optionColors[index % optionColors.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isSubmitting
            ? null
            : () {
                checkAnswer(option.id);
              },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  optionColor.withValues(alpha: 0.18),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    optionColor.withValues(alpha: 0.045),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // LETTER
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      optionColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: optionColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              // ANSWER
              Expanded(
                child: Text(
                  option.optionText,
                  style: const TextStyle(
                    color: Color(0xFF263F4D),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ARROW
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color:
                      optionColor.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: optionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM STATS
  // ============================================================

  Widget _buildBottomStats() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        10,
        17,
        13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              label: 'Correct',
              value: '$correct',
              color: green,
            ),
          ),

          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: _buildStatItem(
              icon: Icons.close_rounded,
              label: 'Incorrect',
              value: '$wrong',
              color: orange,
            ),
          ),

          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
          ),

          Expanded(
            child: _buildStatItem(
              icon: Icons.star_rounded,
              label: 'Score',
              value: '$score',
              color: yellow,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 17,
            color: color,
          ),
        ),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: deepBlue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FE),
                borderRadius:
                    BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 52,
                color: primaryBlue,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Quiz Available',
              style: TextStyle(
                color: deepBlue,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are no quiz questions available\n'
              'for this story at the selected level.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: loadQuestions,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE9),
                borderRadius:
                    BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: Color(0xFFFF776B),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Failed to Load Quiz',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: loadQuestions,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}