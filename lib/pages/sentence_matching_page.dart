import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class SentenceMatchingPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const SentenceMatchingPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<SentenceMatchingPage> createState() =>
      _SentenceMatchingPageState();
}

class _SentenceMatchingPageState extends State<SentenceMatchingPage> {
  final Random _random = Random();

  // ============================================================
  // DATA
  // ============================================================

  List<QuestionPair> _pairs = [];
  List<QuestionPair> _shuffledPairs = [];

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _errorMessage;

  // ============================================================
  // SCORE
  // ============================================================

  int _score = 0;
  int _correct = 0;
  int _wrong = 0;

  // ============================================================
  // SELECTION
  // ============================================================

  int? _selectedLeftId;
  int? _selectedRightId;

  final Set<int> _matchedLeftIds = {};
  final Set<int> _matchedRightIds = {};

  final Set<int> _wrongLeftIds = {};
  final Set<int> _wrongRightIds = {};

  Timer? _feedbackTimer;

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
    _loadQuestions();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // LOAD QUESTIONS
  // ============================================================

  Future<void> _loadQuestions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: 5,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      final allPairs = <QuestionPair>[];

      for (final question in questions) {
        allPairs.addAll(question.pairs);
      }

      if (allPairs.isEmpty) {
        setState(() {
          _pairs = [];
          _shuffledPairs = [];
          _isLoading = false;
          _errorMessage =
              'No Sentence Matching questions are available for this level.';
        });

        return;
      }

      final shuffled = List<QuestionPair>.from(allPairs)
        ..shuffle(_random);

      setState(() {
        _pairs = allPairs;
        _shuffledPairs = shuffled;
        _isLoading = false;

        _score = 0;
        _correct = 0;
        _wrong = 0;

        _selectedLeftId = null;
        _selectedRightId = null;

        _matchedLeftIds.clear();
        _matchedRightIds.clear();

        _wrongLeftIds.clear();
        _wrongRightIds.clear();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load Sentence Matching.\n$e';
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int get _totalPairs => _pairs.length;

  int get _matchedCount => _matchedLeftIds.length;

  bool get _isFinished =>
      _totalPairs > 0 && _matchedCount >= _totalPairs;

  double get _progress {
    if (_totalPairs == 0) return 0;
    return (_matchedCount / _totalPairs).clamp(0.0, 1.0);
  }

  QuestionPair? _getPairById(int id) {
    for (final pair in _pairs) {
      if (pair.id == id) {
        return pair;
      }
    }

    return null;
  }

  // ============================================================
  // SELECT LEFT
  // ============================================================

  void _selectLeft(QuestionPair pair) {
    if (_matchedLeftIds.contains(pair.id) || _isSubmitting) {
      return;
    }

    setState(() {
      _selectedLeftId = pair.id;
      _wrongLeftIds.clear();
      _wrongRightIds.clear();
    });

    _tryMatch();
  }

  // ============================================================
  // SELECT RIGHT
  // ============================================================

  void _selectRight(QuestionPair pair) {
    if (_matchedRightIds.contains(pair.id) || _isSubmitting) {
      return;
    }

    setState(() {
      _selectedRightId = pair.id;
      _wrongLeftIds.clear();
      _wrongRightIds.clear();
    });

    _tryMatch();
  }

  // ============================================================
  // TRY MATCH
  // ============================================================

  void _tryMatch() {
    if (_selectedLeftId == null ||
        _selectedRightId == null) {
      return;
    }

    final leftPair = _getPairById(_selectedLeftId!);
    final rightPair = _getPairById(_selectedRightId!);

    if (leftPair == null || rightPair == null) {
      return;
    }

    if (leftPair.id == rightPair.id) {
      _handleCorrectMatch(leftPair.id);
    } else {
      _handleWrongMatch(
        leftPair.id,
        rightPair.id,
      );
    }
  }

  // ============================================================
  // CORRECT
  // ============================================================

  void _handleCorrectMatch(int pairId) {
    _feedbackTimer?.cancel();

    setState(() {
      _matchedLeftIds.add(pairId);
      _matchedRightIds.add(pairId);

      _score += 10;
      _correct++;

      _selectedLeftId = null;
      _selectedRightId = null;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

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
                'Correct match! 🎉 +10 points',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    if (_isFinished) {
      _finishGame();
    }
  }

  // ============================================================
  // WRONG
  // ============================================================

  void _handleWrongMatch(
    int leftId,
    int rightId,
  ) {
    _feedbackTimer?.cancel();

    setState(() {
      _wrong++;

      _wrongLeftIds.add(leftId);
      _wrongRightIds.add(rightId);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

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
                'Not quite. Try another match! 💪',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );

    _feedbackTimer = Timer(
      const Duration(milliseconds: 800),
      () {
        if (!mounted) return;

        setState(() {
          _selectedLeftId = null;
          _selectedRightId = null;

          _wrongLeftIds.clear();
          _wrongRightIds.clear();
        });
      },
    );
  }

  // ============================================================
  // FINISH
  // ============================================================

  Future<void> _finishGame() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await SessionService.getCurrentUser();

      if (user == null || user.id.isEmpty) {
        throw Exception(
          'User session not found. Please login again.',
        );
      }

      final total = _totalPairs;

      final percentage = total == 0
          ? 0.0
          : (_correct / total) * 100;

      final result = await GameService.submitResult(
        userId: user.id,
        storyId: widget.storyId,
        gameTypeId: 5,
        levelId: widget.levelId,
        score: _score,
        correct: _correct,
        wrong: _wrong,
        totalQuestions: total,
        percentage: percentage,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: 5,
            levelId: widget.levelId,
            score: _score,
            correct: _correct,
            wrong: _wrong,
            totalQuestions: total,
            percentage: result.percentage,
            nextLevel: result.nextLevel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save game result.\n$e',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
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
  // CARD COLORS
  // ============================================================

  Color _leftCardColor(QuestionPair pair) {
    if (_matchedLeftIds.contains(pair.id)) {
      return Colors.green.shade50;
    }

    if (_wrongLeftIds.contains(pair.id)) {
      return Colors.red.shade50;
    }

    if (_selectedLeftId == pair.id) {
      return const Color(0xFFE4F5FF);
    }

    return Colors.white;
  }

  Color _rightCardColor(QuestionPair pair) {
    if (_matchedRightIds.contains(pair.id)) {
      return Colors.green.shade50;
    }

    if (_wrongRightIds.contains(pair.id)) {
      return Colors.red.shade50;
    }

    if (_selectedRightId == pair.id) {
      return Colors.orange.shade50;
    }

    return Colors.white;
  }

  Color _borderColor({
    required bool selected,
    required bool matched,
    required bool wrong,
  }) {
    if (matched) {
      return Colors.green;
    }

    if (wrong) {
      return Colors.redAccent;
    }

    if (selected) {
      return primaryBlue;
    }

    return const Color(0xFFD8E5EC);
  }

  // ============================================================
  // MAIN BUILD
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
                    child: _buildBody(),
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
              onTap: _isSubmitting
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
                  'SENTENCE MATCHING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.storyTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    Colors.white.withValues(alpha: 0.28),
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
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_pairs.isEmpty) {
      return _buildEmpty();
    }

    if (_isFinished) {
      return _buildFinished();
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
        children: [
          _buildGameInfo(),
          const SizedBox(height: 14),
          _buildProgress(),
          const SizedBox(height: 16),
          _buildInstruction(),
          const SizedBox(height: 18),
          _buildStats(),
          const SizedBox(height: 20),
          _buildMatchingArea(),
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
          color: const Color(0xFFC4E7F7),
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
              Icons.compare_arrows_rounded,
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
                  'MATCHING CHALLENGE',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$levelName • $_totalPairs pairs',
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Matching progress',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${(_progress * 100).round()}%',
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
            value: _progress,
            minHeight: 9,
            backgroundColor:
                const Color(0xFFDCECF5),
            valueColor:
                const AlwaysStoppedAnimation<Color>(
              primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INSTRUCTION
  // ============================================================

  Widget _buildInstruction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: softBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC8E9F8),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: primaryBlue,
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
                  'How to play',
                  style: TextStyle(
                    color: deepBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap one sentence on the left, then tap the correct meaning on the right.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
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
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              iconColor: Colors.green.shade600,
              title: 'Correct',
              value: '$_correct',
            ),
          ),
          Container(
            height: 35,
            width: 1,
            color: const Color(0xFFE5EBEF),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.cancel_rounded,
              iconColor: Colors.redAccent.shade200,
              title: 'Wrong',
              value: '$_wrong',
            ),
          ),
          Container(
            height: 35,
            width: 1,
            color: const Color(0xFFE5EBEF),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.stars_rounded,
              iconColor: Colors.amber.shade700,
              title: 'Score',
              value: '$_score',
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
          style: const TextStyle(
            color: deepBlue,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MATCHING AREA
  // ============================================================

  Widget _buildMatchingArea() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildColumnHeader(
                icon: Icons.menu_book_rounded,
                title: 'Sentences',
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildColumnHeader(
                icon: Icons.translate_rounded,
                title: 'Meanings',
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: _pairs
                    .map(_buildLeftCard)
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: _shuffledPairs
                    .map(_buildRightCard)
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // COLUMN HEADER
  // ============================================================

  Widget _buildColumnHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEFT CARD
  // ============================================================

  Widget _buildLeftCard(QuestionPair pair) {
    final matched =
        _matchedLeftIds.contains(pair.id);

    final selected =
        _selectedLeftId == pair.id;

    final wrong =
        _wrongLeftIds.contains(pair.id);

    return GestureDetector(
      onTap: matched || _isSubmitting
          ? null
          : () => _selectLeft(pair),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        margin:
            const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _leftCardColor(pair),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: _borderColor(
              selected: selected,
              matched: matched,
              wrong: wrong,
            ),
            width:
                selected || matched || wrong
                    ? 2
                    : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: matched
                    ? null
                    : selected
                        ? const LinearGradient(
                            colors: [
                              skyBlue,
                              primaryBlue,
                            ],
                          )
                        : null,
                color: matched
                    ? Colors.green
                    : selected
                        ? null
                        : const Color(0xFFEAF6FD),
                shape: BoxShape.circle,
              ),
              child: matched
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    )
                  : Text(
                      '${pair.pairOrder}',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : deepBlue,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                pair.leftText,
                style: TextStyle(
                  color: matched
                      ? Colors.green.shade800
                      : Colors.black87,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight:
                      selected || matched
                          ? FontWeight.w700
                          : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RIGHT CARD
  // ============================================================

  Widget _buildRightCard(QuestionPair pair) {
    final matched =
        _matchedRightIds.contains(pair.id);

    final selected =
        _selectedRightId == pair.id;

    final wrong =
        _wrongRightIds.contains(pair.id);

    return GestureDetector(
      onTap: matched || _isSubmitting
          ? null
          : () => _selectRight(pair),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        margin:
            const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _rightCardColor(pair),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: _borderColor(
              selected: selected,
              matched: matched,
              wrong: wrong,
            ),
            width:
                selected || matched || wrong
                    ? 2
                    : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pair.rightText,
                style: TextStyle(
                  color: matched
                      ? Colors.green.shade800
                      : Colors.black87,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight:
                      selected || matched
                          ? FontWeight.w700
                          : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: matched
                    ? Colors.green
                    : selected
                        ? Colors.orange
                        : const Color(0xFFFFF2E2),
                shape: BoxShape.circle,
              ),
              child: matched
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    )
                  : Icon(
                      Icons.link_rounded,
                      color: selected
                          ? Colors.white
                          : Colors.orange.shade700,
                      size: 17,
                    ),
            ),
          ],
        ),
      ),
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
              width: 78,
              height: 78,
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
                    color: primaryBlue.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
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
              'Loading Sentence Matching...',
              style: TextStyle(
                color: deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Get ready to connect the right pairs!',
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
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 43,
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
              _errorMessage ??
                  'Something went wrong.',
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
                onPressed: _loadQuestions,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
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
                Icons.extension_rounded,
                size: 47,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Sentence Matching Data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: deepBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'There are no Sentence Matching questions available for this level yet.',
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
                onPressed: _loadQuestions,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
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
                    borderRadius:
                        BorderRadius.circular(15),
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
  // FINISHED
  // ============================================================

  Widget _buildFinished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE9FFF1),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.green.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'All Matches Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deepBlue,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You matched all $_totalPairs pairs.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_score Points',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 10),
              const Text(
                'Saving your result...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}