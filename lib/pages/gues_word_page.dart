import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class GuessWordPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const GuessWordPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<GuessWordPage> createState() => _GuessWordPageState();
}

class _GuessWordPageState extends State<GuessWordPage> {
  // ============================================================
  // QUESTIONS
  // ============================================================

  List<GameQuestion> questions = [];
  int currentIndex = 0;

  // ============================================================
  // LETTERS
  // ============================================================

  List<String> shuffledLetters = [];
  List<String> userAnswer = [];

  // ============================================================
  // SCORE
  // ============================================================

  int score = 0;
  int correct = 0;
  int wrong = 0;

  // ============================================================
  // STATE
  // ============================================================

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

  static const Color pageBackground = Color(0xFFF7FBFE);
  static const Color softBlue = Color(0xFFEAF7FF);

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
      isSubmitting = false;
      errorMessage = null;

      questions = [];
      currentIndex = 0;

      shuffledLetters = [];
      userAnswer = [];

      score = 0;
      correct = 0;
      wrong = 0;
    });

    try {
      debugPrint('========================================');
      debugPrint('LOADING GUESS THE WORD');
      debugPrint('Story ID : ${widget.storyId}');
      debugPrint('Story    : ${widget.storyTitle}');
      debugPrint('Game ID  : 3');
      debugPrint('Level ID : ${widget.levelId}');
      debugPrint('========================================');

      final loadedQuestions = await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: 3,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      if (loadedQuestions.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage =
              'No Guess the Word questions are available for this level.';
        });

        return;
      }

      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });

      debugPrint('========================================');
      debugPrint('GUESS THE WORD LOADED');
      debugPrint('Total Questions : ${loadedQuestions.length}');

      for (final question in loadedQuestions) {
        debugPrint('Question ID : ${question.id}');
        debugPrint('Question    : ${question.questionText}');
      }

      debugPrint('========================================');

      prepareQuestion();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('GUESS THE WORD ERROR: $e');
    }
  }

  // ============================================================
  // PREPARE QUESTION
  // ============================================================

  void prepareQuestion() {
    if (questions.isEmpty) return;

    final question = questions[currentIndex];
    final answer = _getAnswer(question);

    if (answer.isEmpty) {
      setState(() {
        errorMessage = 'This question does not have an answer configured.';
      });

      return;
    }

    final letters = answer.split('');
    letters.shuffle(Random());

    setState(() {
      shuffledLetters = letters;
      userAnswer = [];
    });

    debugPrint('========================================');
    debugPrint('GUESS QUESTION');
    debugPrint('Question #${currentIndex + 1}');
    debugPrint('Clue   : ${question.questionText}');
    debugPrint('Answer : $answer');
    debugPrint('Letters: ${letters.join(', ')}');
    debugPrint('========================================');
  }

  // ============================================================
  // GET ANSWER
  // ============================================================

  String _getAnswer(GameQuestion question) {
    if (question.options.isNotEmpty) {
      for (final option in question.options) {
        if (option.isCorrect) {
          return option.optionText.trim();
        }
      }
    }

    return '';
  }

  // ============================================================
  // LETTER TAP
  // ============================================================

  void onLetterTap(String letter) {
    if (isSubmitting) return;

    if (userAnswer.length >= shuffledLetters.length) {
      return;
    }

    setState(() {
      userAnswer.add(letter);
    });
  }

  // ============================================================
  // REMOVE LAST LETTER
  // ============================================================

  void removeLastLetter() {
    if (userAnswer.isEmpty || isSubmitting) {
      return;
    }

    setState(() {
      userAnswer.removeLast();
    });
  }

  // ============================================================
  // CHECK ANSWER
  // ============================================================

  void checkAnswer() {
    if (isSubmitting) return;

    if (questions.isEmpty) return;

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please select the letters first.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    final question = questions[currentIndex];

    final correctAnswer = _getAnswer(question).trim();
    final userResult = userAnswer.join().trim();

    final normalizedCorrect = _normalizeAnswer(correctAnswer);
    final normalizedUser = _normalizeAnswer(userResult);

    debugPrint('========================================');
    debugPrint('CHECK GUESS WORD');
    debugPrint('User Answer    : $userResult');
    debugPrint('Correct Answer : $correctAnswer');
    debugPrint(
      'Result         : ${normalizedUser == normalizedCorrect}',
    );
    debugPrint('========================================');

    if (normalizedUser == normalizedCorrect) {
      score += 10;
      correct++;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Correct! Great job! 🎉',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      Future.delayed(
        const Duration(milliseconds: 850),
        () {
          if (!mounted) return;

          if (currentIndex < questions.length - 1) {
            setState(() {
              currentIndex++;
            });

            prepareQuestion();
          } else {
            finishGame();
          }
        },
      );
    } else {
      wrong++;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Not quite right. Try again!',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade200,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // NORMALIZE ANSWER
  // ============================================================

  String _normalizeAnswer(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // RESET ANSWER
  // ============================================================

  void resetAnswer() {
    if (isSubmitting) return;

    setState(() {
      userAnswer.clear();
    });
  }

  // ============================================================
  // FINISH GAME
  // ============================================================

  Future<void> finishGame() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final totalQuestions = questions.length;

      final percentage = totalQuestions == 0
          ? 0.0
          : (correct / totalQuestions) * 100;

      debugPrint('========================================');
      debugPrint('GUESS THE WORD FINISHED');
      debugPrint('Story ID        : ${widget.storyId}');
      debugPrint('Game Type ID    : 3');
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
          'User session not found. Please login again.',
        );
      }

      final gameResult = await GameService.submitResult(
        userId: user.id,
        storyId: widget.storyId,
        gameTypeId: 3,
        levelId: widget.levelId,
        score: score,
        correct: correct,
        wrong: wrong,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      if (!mounted) return;

      debugPrint('========================================');
      debugPrint('GUESS THE WORD RESULT SAVED');
      debugPrint('Result ID : ${gameResult.resultId}');
      debugPrint('Score     : ${gameResult.score}');
      debugPrint('Correct   : ${gameResult.correct}');
      debugPrint('Wrong     : ${gameResult.wrong}');
      debugPrint('Percentage: ${gameResult.percentage}');

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

      debugPrint('========================================');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: 3,
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
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit result: $e',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      debugPrint('GUESS THE WORD SUBMIT ERROR: $e');
    }
  }

  // ============================================================
  // LEVEL NAME
  // ============================================================

  String get levelName {
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
      backgroundColor: pageBackground,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: pageBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        18,
        18,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isSubmitting
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GUESS THE WORD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.storyTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildHeaderScore(),
        ],
      ),
    );
  }

  Widget _buildHeaderScore() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoading();
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (questions.isEmpty) {
      return _buildEmpty();
    }

    final current = questions[currentIndex];
    final answer = _getAnswer(current);

    if (answer.isEmpty) {
      return _buildConfigurationError();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameInfo(),
          const SizedBox(height: 14),
          _buildProgress(),
          const SizedBox(height: 18),
          _buildClueCard(current),
          const SizedBox(height: 20),
          _buildAnswerSection(answer),
          const SizedBox(height: 22),
          _buildLetterSection(),
          const SizedBox(height: 22),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ============================================================
  // GAME INFO
  // ============================================================

  Widget _buildGameInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE7F7FF),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBCE8FA),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  lightBlue,
                  primaryBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.abc_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WORD CHALLENGE',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$levelName • Question ${currentIndex + 1} of ${questions.length}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber.shade700,
                  size: 19,
                ),
                const SizedBox(height: 2),
                Text(
                  '+10',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    final progress = (currentIndex + 1) / questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your progress',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${((progress) * 100).round()}%',
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor: const Color(0xFFDDECF5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CLUE CARD
  // ============================================================

  Widget _buildClueCard(GameQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF8FF),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC9EAF8),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: Colors.amber.shade700,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: skyBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'CLUE',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            question.questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF17324D),
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the letters below to reveal the answer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANSWER SECTION
  // ============================================================

  Widget _buildAnswerSection(String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: primaryBlue,
                size: 19,
              ),
              SizedBox(width: 7),
              Text(
                'YOUR ANSWER',
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4E8F3),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 8,
            children: List.generate(
              answer.length,
              (index) {
                final hasLetter = index < userAnswer.length;

                return GestureDetector(
                  onTap: hasLetter ? removeLastLetter : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: hasLetter
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFE4F6FF),
                                Color(0xFFD2F0FF),
                              ],
                            )
                          : null,
                      color: hasLetter ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: hasLetter
                            ? skyBlue
                            : const Color(0xFFD5E0E6),
                        width: hasLetter ? 1.7 : 1.3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        hasLetter ? userAnswer[index] : '',
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 7),
        const Center(
          child: Text(
            'Tap a filled letter to remove the last letter.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LETTER SECTION
  // ============================================================

  Widget _buildLetterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFCBEAF8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.apps_rounded,
                  color: primaryBlue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHOOSE LETTERS',
                      style: TextStyle(
                        color: deepBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Build the word from the letters below.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 9,
              runSpacing: 10,
              children: shuffledLetters.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final letter = entry.value;

                  final isUsed = _isLetterUsedAtIndex(index);

                  return _buildLetterButton(
                    letter: letter,
                    isUsed: isUsed,
                    onTap: isUsed
                        ? null
                        : () {
                            onLetterTap(letter);
                          },
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLetterUsedAtIndex(int index) {
    if (index >= userAnswer.length) {
      return false;
    }

    int occurrenceBefore = 0;

    for (int i = 0; i < index; i++) {
      if (shuffledLetters[i] == shuffledLetters[index]) {
        occurrenceBefore++;
      }
    }

    int occurrenceUsed = 0;

    for (int i = 0; i < userAnswer.length; i++) {
      if (userAnswer[i] == shuffledLetters[index]) {
        occurrenceUsed++;
      }
    }

    return occurrenceUsed > occurrenceBefore;
  }

  Widget _buildLetterButton({
    required String letter,
    required bool isUsed,
    required VoidCallback? onTap,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isUsed ? 0.35 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  skyBlue,
                  primaryBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.20),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                letter.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: isSubmitting ? null : resetAnswer,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
              ),
              label: const Text(
                'Reset',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: deepBlue,
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFC9DFEA),
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC857),
                    Color(0xFFFF9F43),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : checkAnswer,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.check_circle_rounded,
                        size: 21,
                      ),
                label: Text(
                  isSubmitting ? 'Saving...' : 'Check Answer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    lightBlue,
                    primaryBlue,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.abc_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading Guess the Word...',
              style: TextStyle(
                color: deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Get ready for a fun vocabulary challenge!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to Load the Game',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: loadQuestions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: softBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.abc_rounded,
                size: 48,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Guess the Word Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'There are no Guess the Word questions available for this level yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: loadQuestions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONFIGURATION ERROR
  // ============================================================

  Widget _buildConfigurationError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Question Configuration Error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'This Guess the Word question does not have a correct answer configured in the database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: deepBlue,
                  side: const BorderSide(
                    color: Color(0xFFC9DFEA),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}