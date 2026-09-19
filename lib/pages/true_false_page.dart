import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class TrueFalsePage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const TrueFalsePage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<TrueFalsePage> createState() => _TrueFalsePageState();
}

class _TrueFalsePageState extends State<TrueFalsePage> {
  // ============================================================
  // QUESTIONS
  // ============================================================

  List<GameQuestion> questions = [];
  int currentIndex = 0;

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
  bool isAnswered = false;

  String? errorMessage;

  bool? selectedAnswer;
  bool? correctAnswer;

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

      score = 0;
      correct = 0;
      wrong = 0;

      selectedAnswer = null;
      correctAnswer = null;
      isAnswered = false;
    });

    try {
      debugPrint('========================================');
      debugPrint('LOADING TRUE OR FALSE');
      debugPrint('Story ID : ${widget.storyId}');
      debugPrint('Story    : ${widget.storyTitle}');
      debugPrint('Game ID  : 4');
      debugPrint('Level ID : ${widget.levelId}');
      debugPrint('========================================');

      final loadedQuestions =
          await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: 4,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      if (loadedQuestions.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage =
              'No True or False questions are available for this level.';
        });

        return;
      }

      // ========================================================
      // VALIDATE QUESTIONS
      // ========================================================

      final validQuestions =
          loadedQuestions.where((question) {
        return question.options.length >= 2;
      }).toList();

      if (validQuestions.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage =
              'True or False questions are not configured correctly.';
        });

        return;
      }

      setState(() {
        questions = validQuestions;
        isLoading = false;
      });

      debugPrint('========================================');
      debugPrint('TRUE OR FALSE LOADED');
      debugPrint(
        'Total Questions : ${validQuestions.length}',
      );

      for (final question in validQuestions) {
        debugPrint(
          'Question ID : ${question.id}',
        );

        debugPrint(
          'Statement   : ${question.questionText}',
        );

        for (final option in question.options) {
          debugPrint(
            'Option      : ${option.optionText} '
            '| Correct: ${option.isCorrect}',
          );
        }
      }

      debugPrint('========================================');

      prepareQuestion();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint(
        'TRUE OR FALSE ERROR: $e',
      );
    }
  }

  // ============================================================
  // PREPARE QUESTION
  // ============================================================

  void prepareQuestion() {
    if (questions.isEmpty) return;

    final question = questions[currentIndex];

    bool? answer;

    for (final option in question.options) {
      final text =
          option.optionText.trim().toLowerCase();

      if (option.isCorrect) {
        if (text == 'true') {
          answer = true;
        } else if (text == 'false') {
          answer = false;
        }
      }
    }

    if (answer == null) {
      debugPrint(
        'TRUE/FALSE CONFIGURATION ERROR '
        'for question ${question.id}',
      );

      setState(() {
        correctAnswer = null;
        selectedAnswer = null;
        isAnswered = false;
      });

      return;
    }

    setState(() {
      correctAnswer = answer;
      selectedAnswer = null;
      isAnswered = false;
    });

    debugPrint('========================================');
    debugPrint(
      'TRUE/FALSE QUESTION ${currentIndex + 1}',
    );
    debugPrint(
      'Question ID : ${question.id}',
    );
    debugPrint(
      'Statement   : ${question.questionText}',
    );
    debugPrint(
      'Correct     : $answer',
    );
    debugPrint('========================================');
  }

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  void selectAnswer(bool answer) {
    if (isSubmitting || isAnswered) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    final isCorrect = answer == correctAnswer;

    if (isCorrect) {
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
          duration: const Duration(
            milliseconds: 800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } else {
      wrong++;

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
                  'Not quite right. Keep learning! 💪',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            milliseconds: 900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }

    Future.delayed(
      const Duration(
        milliseconds: 950,
      ),
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
      debugPrint('TRUE OR FALSE FINISHED');
      debugPrint(
        'Story ID        : ${widget.storyId}',
      );
      debugPrint(
        'Game Type ID    : 4',
      );
      debugPrint(
        'Level ID        : ${widget.levelId}',
      );
      debugPrint(
        'Total Questions : $totalQuestions',
      );
      debugPrint(
        'Correct         : $correct',
      );
      debugPrint(
        'Wrong           : $wrong',
      );
      debugPrint(
        'Score           : $score',
      );
      debugPrint(
        'Percentage      : $percentage',
      );
      debugPrint('========================================');

      final user =
          await SessionService.getCurrentUser();

      if (user == null || user.id.isEmpty) {
        throw Exception(
          'User session not found. Please login again.',
        );
      }

      final gameResult =
          await GameService.submitResult(
        userId: user.id,
        storyId: widget.storyId,
        gameTypeId: 4,
        levelId: widget.levelId,
        score: score,
        correct: correct,
        wrong: wrong,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      if (!mounted) return;

      debugPrint('========================================');
      debugPrint('TRUE OR FALSE RESULT SAVED');
      debugPrint(
        'Result ID : ${gameResult.resultId}',
      );
      debugPrint(
        'Score     : ${gameResult.score}',
      );
      debugPrint(
        'Correct   : ${gameResult.correct}',
      );
      debugPrint(
        'Wrong     : ${gameResult.wrong}',
      );
      debugPrint(
        'Percentage: ${gameResult.percentage}',
      );

      if (gameResult.nextLevel != null) {
        debugPrint(
          'Next Level      : '
          '${gameResult.nextLevel!.name}',
        );

        debugPrint(
          'Next Level ID   : '
          '${gameResult.nextLevel!.levelId}',
        );

        debugPrint(
          'Next Level Order: '
          '${gameResult.nextLevel!.levelOrder}',
        );

        debugPrint(
          'Next Unlocked   : '
          '${gameResult.nextLevel!.isUnlocked}',
        );
      } else {
        debugPrint(
          'Next Level      : NONE',
        );
      }

      debugPrint('========================================');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: 4,
            levelId: widget.levelId,
            score: gameResult.score,
            correct: gameResult.correct,
            wrong: gameResult.wrong,
            totalQuestions:
                gameResult.totalQuestions,
            percentage:
                gameResult.percentage,
            nextLevel:
                gameResult.nextLevel,
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

      debugPrint(
        'TRUE OR FALSE SUBMIT ERROR: $e',
      );
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
  // ANSWER COLOR
  // ============================================================

  Color _getAnswerColor(bool answer) {
    if (!isAnswered) {
      return answer
          ? Colors.green.shade600
          : Colors.redAccent.shade200;
    }

    if (answer == correctAnswer) {
      return Colors.green.shade600;
    }

    if (answer == selectedAnswer) {
      return Colors.redAccent.shade200;
    }

    return Colors.grey.shade400;
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
                    borderRadius:
                        const BorderRadius.vertical(
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
            color:
                Colors.white.withValues(alpha: 0.18),
            borderRadius:
                BorderRadius.circular(14),
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(14),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRUE OR FALSE',
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
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.18),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$score',
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
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

    if (correctAnswer == null) {
      return _buildConfigurationError();
    }

    final current =
        questions[currentIndex];

    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        28,
      ),
      child: Column(
        children: [
          _buildGameInfo(),
          const SizedBox(height: 14),
          _buildProgress(),
          const SizedBox(height: 18),
          _buildStatementCard(current),
          const SizedBox(height: 20),
          _buildAnswerButtons(),
          const SizedBox(height: 18),
          _buildStats(),
          if (isAnswered) ...[
            const SizedBox(height: 16),
            _buildFeedback(),
          ],
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
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFE7F7FF),
            Colors.white,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFC4E7F7),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue
                .withValues(alpha: 0.07),
            blurRadius: 14,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  lightBlue,
                  primaryBlue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'STORY CHECK',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$levelName • Question ${currentIndex + 1} of ${questions.length}',
                  style:
                      const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.amber.shade50,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .emoji_events_rounded,
                  color:
                      Colors.amber.shade700,
                  size: 19,
                ),
                const SizedBox(height: 2),
                Text(
                  '+10',
                  style: TextStyle(
                    color:
                        Colors.amber.shade800,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
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
    final progress =
        (currentIndex + 1) /
            questions.length;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            const Text(
              'Question progress',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style:
                  const TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(20),
          child:
              LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            backgroundColor:
                const Color(
              0xFFDDECF5,
            ),
            valueColor:
                const AlwaysStoppedAnimation<
                    Color>(
              primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATEMENT CARD
  // ============================================================

  Widget _buildStatementCard(
    GameQuestion question,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        24,
      ),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFEAF8FF),
            Colors.white,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color:
              const Color(0xFFC8EAF8),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue
                .withValues(alpha: 0.08),
            blurRadius: 17,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  lightBlue,
                  primaryBlue,
                ],
              ),
              shape:
                  BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue
                      .withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 12,
                  offset:
                      const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color: skyBlue
                  .withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child:
                const Text(
              'TRUE OR FALSE?',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            question.questionText,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Color(0xFF17324D),
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Read the statement carefully, then choose your answer.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANSWER BUTTONS
  // ============================================================

  Widget _buildAnswerButtons() {
    return Column(
      children: [
        _buildAnswerButton(
          answer: true,
          icon:
              Icons.check_circle_rounded,
          title: 'TRUE',
          subtitle:
              'The statement is correct',
        ),
        const SizedBox(height: 13),
        _buildAnswerButton(
          answer: false,
          icon:
              Icons.cancel_rounded,
          title: 'FALSE',
          subtitle:
              'The statement is incorrect',
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required bool answer,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final color =
        _getAnswerColor(answer);

    final selected =
        selectedAnswer == answer;

    final isCorrectOption =
        isAnswered &&
            answer == correctAnswer;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
      width: double.infinity,
      height: 78,
      decoration: BoxDecoration(
        gradient: selected ||
                isCorrectOption
            ? LinearGradient(
                colors: [
                  color,
                  color.withValues(
                    alpha: 0.82,
                  ),
                ],
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
              )
            : null,
        color: selected ||
                isCorrectOption
            ? null
            : Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: selected ||
                  isCorrectOption
              ? color
              : const Color(
                  0xFFD8E6ED,
                ),
          width:
              selected ||
                      isCorrectOption
                  ? 2
                  : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ||
                    isCorrectOption
                ? color.withValues(
                    alpha: 0.20,
                  )
                : Colors.black.withValues(
                    alpha: 0.035,
                  ),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          onTap: isSubmitting ||
                  isAnswered
              ? null
              : () {
                  selectAnswer(
                    answer,
                  );
                },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 17,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color: selected ||
                            isCorrectOption
                        ? Colors.white
                            .withValues(
                            alpha: 0.22,
                          )
                        : color.withValues(
                            alpha: 0.10,
                          ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: selected ||
                            isCorrectOption
                        ? Colors.white
                        : color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            TextStyle(
                          color: selected ||
                                  isCorrectOption
                              ? Colors.white
                              : color,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing:
                              0.4,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        subtitle,
                        style:
                            TextStyle(
                          color: selected ||
                                  isCorrectOption
                              ? Colors.white
                                  .withValues(
                                  alpha: 0.86,
                                )
                              : Colors.grey,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAnswered &&
                    answer ==
                        correctAnswer)
                  const Icon(
                    Icons
                        .check_circle_rounded,
                    color: Colors.white,
                    size: 23,
                  )
                else if (isAnswered &&
                    answer ==
                        selectedAnswer)
                  const Icon(
                    Icons
                        .cancel_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFE0E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon:
                  Icons.check_circle_rounded,
              iconColor:
                  Colors.green.shade600,
              title: 'Correct',
              value: '$correct',
            ),
          ),
          Container(
            height: 35,
            width: 1,
            color:
                const Color(0xFFE5EBEF),
          ),
          Expanded(
            child: _buildStatItem(
              icon:
                  Icons.cancel_rounded,
              iconColor:
                  Colors.redAccent.shade200,
              title: 'Wrong',
              value: '$wrong',
            ),
          ),
          Container(
            height: 35,
            width: 1,
            color:
                const Color(0xFFE5EBEF),
          ),
          Expanded(
            child: _buildStatItem(
              icon:
                  Icons.stars_rounded,
              iconColor:
                  Colors.amber.shade700,
              title: 'Score',
              value: '$score',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              const TextStyle(
            color: deepBlue,
            fontSize: 16,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  Widget _buildFeedback() {
    final isCorrect =
        selectedAnswer ==
            correctAnswer;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: isCorrect
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(
              color: isCorrect
                  ? Colors.green
                  : Colors.orange,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              isCorrect
                  ? Icons
                      .check_rounded
                  : Icons
                      .lightbulb_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? 'Excellent!'
                      : 'Keep going!',
                  style: TextStyle(
                    color: isCorrect
                        ? Colors
                            .green
                            .shade800
                        : Colors
                            .orange
                            .shade800,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  isCorrect
                      ? 'You understood the story correctly. 🎉'
                      : 'Read the story again and learn from each challenge.',
                  style:
                      const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.35,
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    lightBlue,
                    primaryBlue,
                  ],
                ),
                shape:
                    BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue
                        .withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 20,
                    offset:
                        const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fact_check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 3,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Loading True or False...',
              style: TextStyle(
                color: deepBlue,
                fontSize: 15,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Get ready to test your story knowledge!',
              textAlign:
                  TextAlign.center,
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
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration:
                  BoxDecoration(
                color:
                    Colors.red.shade50,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 43,
                color:
                    Colors.red.shade400,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Unable to Load the Game',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              height: 48,
              child:
                  ElevatedButton.icon(
                onPressed:
                    loadQuestions,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
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
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration:
                  const BoxDecoration(
                color: softBlue,
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_rounded,
                size: 47,
                color: primaryBlue,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'No True or False Data',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'There are no True or False questions available for this level yet.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              height: 48,
              child:
                  ElevatedButton.icon(
                onPressed:
                    loadQuestions,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
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
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration:
                  BoxDecoration(
                color:
                    Colors.orange.shade50,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .warning_amber_rounded,
                size: 48,
                color:
                    Colors.orange.shade600,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Question Configuration Error',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 9,
            ),
            const Text(
              'The True or False question must have True or False options with one correct answer.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            SizedBox(
              height: 48,
              child:
                  OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                icon: const Icon(
                  Icons
                      .arrow_back_rounded,
                ),
                label: const Text(
                  'Back',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      deepBlue,
                  side:
                      const BorderSide(
                    color: Color(
                      0xFFC9DFEA,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
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