import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class DragMatchPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const DragMatchPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<DragMatchPage> createState() => _DragMatchPageState();
}

class _DragMatchPageState extends State<DragMatchPage> {
  List<GameQuestion> questions = [];
  List<QuestionPair> pairs = [];

  final Set<int> matchedPairIds = {};

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
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadQuestions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      questions = [];
      pairs = [];
      matchedPairIds.clear();
      score = 0;
      correct = 0;
      wrong = 0;
    });

    try {
      debugPrint('========================================');
      debugPrint('LOADING WORD MATCHING');
      debugPrint('Story ID : ${widget.storyId}');
      debugPrint('Story    : ${widget.storyTitle}');
      debugPrint('Game ID  : 2');
      debugPrint('Level ID : ${widget.levelId}');
      debugPrint('========================================');

      final loadedQuestions =
          await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: 2,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      final List<QuestionPair> loadedPairs = [];

      for (final question in loadedQuestions) {
        loadedPairs.addAll(question.pairs);
      }

      loadedPairs.shuffle(Random());

      setState(() {
        questions = loadedQuestions;
        pairs = loadedPairs;
        isLoading = false;
      });

      debugPrint(
        'Total Questions : ${loadedQuestions.length}',
      );
      debugPrint(
        'Total Pairs     : ${loadedPairs.length}',
      );

      if (loadedPairs.isEmpty) {
        setState(() {
          errorMessage =
              'No Word Matching pairs are available for this level.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint('WORD MATCHING ERROR: $e');
    }
  }

  // ============================================================
  // CORRECT MATCH
  // ============================================================

  void _handleCorrectMatch(QuestionPair pair) {
    if (matchedPairIds.contains(pair.id)) {
      return;
    }

    setState(() {
      matchedPairIds.add(pair.id);
      score += 10;
      correct++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 9),
            Text(
              'Correct! Great job! 🎉',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(15),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  // ============================================================
  // WRONG MATCH
  // ============================================================

  void _handleWrongMatch() {
    setState(() {
      wrong++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                "Oops! Try another meaning.",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(15),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  // ============================================================
  // FINISH GAME
  // ============================================================

  Future<void> finishGame() async {
    if (isSubmitting) return;

    if (pairs.isEmpty) return;

    if (matchedPairIds.length != pairs.length) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final totalQuestions = pairs.length;

      final percentage = totalQuestions == 0
          ? 0.0
          : (correct / totalQuestions) * 100;

      debugPrint('========================================');
      debugPrint('WORD MATCHING FINISHED');
      debugPrint('Story ID        : ${widget.storyId}');
      debugPrint('Game Type ID    : 2');
      debugPrint('Level ID        : ${widget.levelId}');
      debugPrint('Total Questions : $totalQuestions');
      debugPrint('Correct         : $correct');
      debugPrint('Wrong           : $wrong');
      debugPrint('Score           : $score');
      debugPrint('Percentage      : $percentage');
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
        gameTypeId: 2,
        levelId: widget.levelId,
        score: score,
        correct: correct,
        wrong: wrong,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      if (!mounted) return;

      debugPrint('WORD MATCHING RESULT SAVED');
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: 2,
            levelId: widget.levelId,
            score: gameResult.score,
            correct: gameResult.correct,
            wrong: gameResult.wrong,
            totalQuestions:
                gameResult.totalQuestions,
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
          margin: const EdgeInsets.all(15),
        ),
      );

      debugPrint(
        'WORD MATCHING SUBMIT ERROR: $e',
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
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
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.extension_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WORD MATCHING',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            widget.storyTitle,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w800,
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

          const SizedBox(height: 12),

          Row(
            children: [
              _buildHeaderStat(
                Icons.check_circle_rounded,
                '$correct',
              ),

              const SizedBox(width: 8),

              _buildHeaderStat(
                Icons.close_rounded,
                '$wrong',
              ),

              const Spacer(),

              Text(
                levelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
  // HEADER STAT
  // ============================================================

  Widget _buildHeaderStat(
    IconData icon,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
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

    if (pairs.isEmpty) {
      return _buildEmpty();
    }

    return _buildGame();
  }

  // ============================================================
  // GAME
  // ============================================================

  Widget _buildGame() {
    final completed =
        matchedPairIds.length == pairs.length;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              15,
            ),
            child: Column(
              children: [
                _buildInstructionCard(),

                const SizedBox(height: 16),

                _buildProgressCard(),

                const SizedBox(height: 18),

                _buildColumnTitle(
                  'WORDS',
                  Icons.translate_rounded,
                  primaryBlue,
                ),

                const SizedBox(height: 9),

                _buildWordsColumn(),

                const SizedBox(height: 18),

                _buildColumnTitle(
                  'MEANINGS',
                  Icons.menu_book_rounded,
                  green,
                ),

                const SizedBox(height: 9),

                _buildMeaningsColumn(),

                const SizedBox(height: 15),

                if (completed)
                  _buildFinishButton(),
              ],
            ),
          ),
        ),

        if (!completed)
          _buildBottomHint(),
      ],
    );
  }

  // ============================================================
  // INSTRUCTION
  // ============================================================

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF8FE),
            Color(0xFFF7FCFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: lightBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  lightBlue,
                  primaryBlue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Match the Words! 🧩',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Press and hold a word, then drag it to the correct meaning.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11.5,
                    height: 1.4,
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

  Widget _buildProgressCard() {
    final progress = pairs.isEmpty
        ? 0.0
        : matchedPairIds.length / pairs.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                primaryBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: primaryBlue,
                size: 19,
              ),

              const SizedBox(width: 7),

              const Text(
                'Matching Progress',
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                '${matchedPairIds.length}/${pairs.length}',
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Colors.grey.shade100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLUMN TITLE
  // ============================================================

  Widget _buildColumnTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Container(
            height: 1,
            color: color.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WORDS
  // ============================================================

  Widget _buildWordsColumn() {
    return Column(
      children: pairs.map((pair) {
        final matched =
            matchedPairIds.contains(pair.id);

        if (matched) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: 9),
            child: _buildMatchedWord(pair),
          );
        }

        return Padding(
          padding:
              const EdgeInsets.only(bottom: 9),
          child: _buildDraggableWord(pair),
        );
      }).toList(),
    );
  }

  // ============================================================
  // MATCHED WORD
  // ============================================================

  Widget _buildMatchedWord(
    QuestionPair pair,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 58,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F2),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: green.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: green,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              pair.leftText,
              style: const TextStyle(
                color: green,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const Text(
            'Matched!',
            style: TextStyle(
              color: green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MEANINGS
  // ============================================================

  Widget _buildMeaningsColumn() {
    return Column(
      children: pairs.map((pair) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 9),
          child: _buildDropTarget(pair),
        );
      }).toList(),
    );
  }

  // ============================================================
  // DRAGGABLE WORD
  // ============================================================

  Widget _buildDraggableWord(
    QuestionPair pair,
  ) {
    return LongPressDraggable<int>(
      data: pair.id,

      delay: const Duration(
        milliseconds: 250,
      ),

      maxSimultaneousDrags: 1,

      feedback: Material(
        color: Colors.transparent,
        elevation: 10,
        child: SizedBox(
          width: 280,
          child: _dragItem(
            pair.leftText,
            dragging: true,
          ),
        ),
      ),

      childWhenDragging: Opacity(
        opacity: 0.25,
        child: _dragItem(
          pair.leftText,
        ),
      ),

      onDragStarted: () {
        debugPrint(
          'DRAG START: ${pair.leftText}',
        );
      },

      onDragEnd: (details) {
        debugPrint(
          'DRAG END: ${pair.leftText}',
        );
      },

      child: _dragItem(
        pair.leftText,
      ),
    );
  }

  // ============================================================
  // DROP TARGET
  // ============================================================

  Widget _buildDropTarget(
    QuestionPair pair,
  ) {
    final isMatched =
        matchedPairIds.contains(pair.id);

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) {
        final draggedPairId = details.data;

        if (isMatched) {
          return false;
        }

        debugPrint(
          'DRAG OVER: $draggedPairId -> TARGET ${pair.id}',
        );

        return true;
      },

      onAcceptWithDetails: (details) {
        final draggedPairId = details.data;

        debugPrint(
          'DROP: $draggedPairId -> TARGET ${pair.id}',
        );

        if (draggedPairId == pair.id) {
          _handleCorrectMatch(pair);
        } else {
          _handleWrongMatch();
        }
      },

      builder: (
        context,
        candidateData,
        rejectedData,
      ) {
        final isHovering =
            candidateData.isNotEmpty;

        return AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),

          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 64,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),

          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFFEAF9F2)
                : isHovering
                    ? const Color(0xFFE5F5FD)
                    : Colors.white,

            borderRadius:
                BorderRadius.circular(18),

            border: Border.all(
              color: isMatched
                  ? green
                  : isHovering
                      ? primaryBlue
                      : const Color(0xFFD9EAF2),
              width: isHovering ? 2 : 1.3,
            ),

            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: primaryBlue
                          .withValues(alpha: 0.12),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.025),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),

          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isMatched
                      ? green.withValues(alpha: 0.12)
                      : isHovering
                          ? primaryBlue
                              .withValues(alpha: 0.12)
                          : Colors.grey
                              .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  isMatched
                      ? Icons.check_circle_rounded
                      : isHovering
                          ? Icons.download_rounded
                          : Icons
                              .south_rounded,
                  color: isMatched
                      ? green
                      : isHovering
                          ? primaryBlue
                          : Colors.grey.shade400,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  pair.rightText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: isMatched
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isMatched
                        ? green
                        : deepBlue,
                  ),
                ),
              ),

              if (isMatched)
                const Icon(
                  Icons.check_circle_rounded,
                  color: green,
                  size: 20,
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DRAG ITEM
  // ============================================================

  Widget _dragItem(
    String text, {
    bool dragging = false,
  }) {
    return Container(
      width: dragging ? 280 : double.infinity,

      constraints: const BoxConstraints(
        minHeight: 62,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            lightBlue,
            primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                primaryBlue.withValues(alpha: 0.20),
            blurRadius: dragging ? 15 : 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.18),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.drag_indicator_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(width: 5),

          const Icon(
            Icons.open_with_rounded,
            color: Colors.white70,
            size: 17,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FINISH BUTTON
  // ============================================================

  Widget _buildFinishButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB52E),
            Color(0xFFFF8A65),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                orange.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed:
            isSubmitting ? null : finishGame,

        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.emoji_events_rounded,
              ),

        label: Text(
          isSubmitting
              ? 'Saving Result...'
              : 'Finish Game',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize:
              const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM HINT
  // ============================================================

  Widget _buildBottomHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        9,
        16,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.touch_app_rounded,
            color: primaryBlue,
            size: 18,
          ),

          const SizedBox(width: 7),

          Text(
            '${matchedPairIds.length} of ${pairs.length} matched',
            style: const TextStyle(
              color: deepBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7FD),
              borderRadius:
                  BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: primaryBlue,
              size: 48,
            ),
          ),

          const SizedBox(height: 20),

          const CircularProgressIndicator(
            color: primaryBlue,
            strokeWidth: 3,
          ),

          const SizedBox(height: 15),

          const Text(
            'Preparing Word Matching...',
            style: TextStyle(
              color: deepBlue,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Get ready to match the words!',
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
  // ERROR
  // ============================================================

  Widget _buildError() {
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

            const SizedBox(height: 20),

            const Text(
              'Oops! Something went Incorrect',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              errorMessage ??
                  'Unable to load the game.',
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
                  horizontal: 23,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
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
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
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
                Icons.extension_outlined,
                size: 52,
                color: primaryBlue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Matching Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'There are no matching pairs available for this level yet.',
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
                'Refresh',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
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