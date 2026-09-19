import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'result_page.dart';

class FiveWOneHPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int levelId;

  const FiveWOneHPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.levelId,
  });

  @override
  State<FiveWOneHPage> createState() => _FiveWOneHPageState();
}

class _FiveWOneHPageState extends State<FiveWOneHPage> {
  static const int _gameTypeId = 6;

  List<GameQuestion> _questions = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _errorMessage;

  int _currentIndex = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  bool _hasAnswered = false;
  bool _lastAnswerCorrect = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questions = await GameService.getGameQuestions(
        storyId: widget.storyId,
        gameTypeId: _gameTypeId,
        levelId: widget.levelId,
      );

      if (!mounted) return;

      if (questions.isEmpty) {
        setState(() {
          _questions = [];
          _isLoading = false;
          _errorMessage =
              'There are no 5W1H questions available for this story and level.';
        });
        return;
      }

      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _score = 0;
        _correct = 0;
        _wrong = 0;
        _isLoading = false;
      });

      _prepareQuestion();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load questions from the server.\n$e';
      });
    }
  }

  void _prepareQuestion() {
    _answerController.clear();

    setState(() {
      _hasAnswered = false;
      _lastAnswerCorrect = false;
      _feedbackMessage = '';
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _answerFocusNode.requestFocus();
    });
  }

  GameQuestion get _currentQuestion => _questions[_currentIndex];

  String get _questionCategory {
    final text = _currentQuestion.questionText.trim();

    final match = RegExp(
      r'^\[(Who|What|When|Where|Why|How)\]\s*',
      caseSensitive: false,
    ).firstMatch(text);

    if (match != null) {
      return match.group(1)!.toUpperCase();
    }

    return _detectCategoryFromQuestion(text);
  }

  String get _cleanQuestionText {
    final text = _currentQuestion.questionText.trim();

    return text.replaceFirst(
      RegExp(
        r'^\[(Who|What|When|Where|Why|How)\]\s*',
        caseSensitive: false,
      ),
      '',
    );
  }

  String _detectCategoryFromQuestion(String text) {
    final lower = text.toLowerCase();

    if (lower.startsWith('who') || lower.contains('siapa')) {
      return 'WHO';
    }

    if (lower.startsWith('what') || lower.contains('apa')) {
      return 'WHAT';
    }

    if (lower.startsWith('when') || lower.contains('kapan')) {
      return 'WHEN';
    }

    if (lower.startsWith('where') ||
        lower.contains('di mana') ||
        lower.contains('dimana')) {
      return 'WHERE';
    }

    if (lower.startsWith('why') ||
        lower.contains('mengapa') ||
        lower.contains('kenapa')) {
      return 'WHY';
    }

    if (lower.startsWith('how') || lower.contains('bagaimana')) {
      return 'HOW';
    }

    return '5W1H';
  }

  String? _getCorrectAnswer() {
    final question = _currentQuestion;

    if (question.options.isNotEmpty) {
      final correctOption =
          question.options.cast<QuestionOption?>().firstWhere(
                (option) => option?.isCorrect == true,
                orElse: () => null,
              );

      if (correctOption != null) {
        return correctOption.optionText.trim();
      }
    }

    return null;
  }

  String _normalizeAnswer(String value) {
    var result = value.toLowerCase().trim();

    result = result.replaceAll(
      RegExp(r'[.,!?;:"“”‘’()\[\]{}]'),
      '',
    );

    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result;
  }

  List<String> _answerVariants(String answer) {
    final normalized = _normalizeAnswer(answer);

    final variants = <String>{
      normalized,
    };

    variants.add(
      normalized.replaceAll(
        RegExp(r'^(the|a|an)\s+'),
        '',
      ),
    );

    variants.add(
      normalized.replaceAll(
        RegExp(r'\s+(is|was|are|were)\s+'),
        ' ',
      ),
    );

    return variants.where((e) => e.isNotEmpty).toList();
  }

  bool _isAnswerCorrect(
    String userAnswer,
    String correctAnswer,
  ) {
    final user = _normalizeAnswer(userAnswer);

    if (user.isEmpty) return false;

    final correctVariants = _answerVariants(correctAnswer);

    if (correctVariants.contains(user)) {
      return true;
    }

    for (final variant in correctVariants) {
      if (variant.length >= 4) {
        if (user.contains(variant) || variant.contains(user)) {
          return true;
        }
      }
    }

    final userWords = user
        .split(' ')
        .where((word) => word.length >= 3)
        .toSet();

    for (final variant in correctVariants) {
      final correctWords = variant
          .split(' ')
          .where((word) => word.length >= 3)
          .toSet();

      if (correctWords.isEmpty) continue;

      final commonWords = userWords.intersection(correctWords);

      if (commonWords.isNotEmpty &&
          commonWords.length >=
              (correctWords.length > 1 ? correctWords.length - 1 : 1)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _checkAnswer() async {
    if (_hasAnswered || _isSubmitting) return;

    final userAnswer = _answerController.text.trim();

    if (userAnswer.isEmpty) {
      _showMessage('Please type your answer first.');
      return;
    }

    final correctAnswer = _getCorrectAnswer();

    if (correctAnswer == null || correctAnswer.isEmpty) {
      _showMessage(
        'The correct answer has not been configured properly in the database.',
      );
      return;
    }

    final isCorrect = _isAnswerCorrect(
      userAnswer,
      correctAnswer,
    );

    setState(() {
      _hasAnswered = true;
      _lastAnswerCorrect = isCorrect;

      if (isCorrect) {
        _correct++;

        _score += _currentQuestion.points > 0
            ? _currentQuestion.points
            : 10;

        _feedbackMessage = 'Correct! Great job! 🎉';
      } else {
        _wrong++;

        _feedbackMessage =
            'Not quite. The correct answer is: $correctAnswer';
      }
    });

    if (isCorrect) {
      _showMessage(
        'Correct answer! +${_currentQuestion.points > 0 ? _currentQuestion.points : 10} points',
      );
    } else {
      _showMessage('Good try! Keep learning.');
    }

    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });

      _prepareQuestion();
    } else {
      await _finishGame();
    }
  }

  Future<void> _finishGame() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await SessionService.getCurrentUser();

      if (user == null || user.id.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isSubmitting = false;
        });

        _showMessage(
          'User session not found. Please log in again.',
        );

        return;
      }

      final totalQuestions = _questions.length;

      final percentage = totalQuestions > 0
          ? (_correct / totalQuestions) * 100
          : 0.0;

      final result = await GameService.submitResult(
        userId: user.id,
        storyId: widget.storyId,
        gameTypeId: _gameTypeId,
        levelId: widget.levelId,
        score: _score,
        correct: _correct,
        wrong: _wrong,
        totalQuestions: totalQuestions,
        percentage: percentage,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            storyId: widget.storyId,
            storyTitle: widget.storyTitle,
            gameTypeId: _gameTypeId,
            levelId: widget.levelId,
            score: _score,
            correct: _correct,
            wrong: _wrong,
            totalQuestions: totalQuestions,
            percentage: percentage,
            nextLevel: result.nextLevel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Failed to save game result.\n$e',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Color _categoryColor() {
    switch (_questionCategory) {
      case 'WHO':
        return const Color(0xFF2980B9);

      case 'WHAT':
        return const Color(0xFF43B883);

      case 'WHEN':
        return const Color(0xFFFFB52E);

      case 'WHERE':
        return const Color(0xFF8B72E8);

      case 'WHY':
        return const Color(0xFFFF6B6B);

      case 'HOW':
        return const Color(0xFF18A6A6);

      default:
        return const Color(0xFF4FACFE);
    }
  }

  IconData _categoryIcon() {
    switch (_questionCategory) {
      case 'WHO':
        return Icons.person_rounded;

      case 'WHAT':
        return Icons.help_rounded;

      case 'WHEN':
        return Icons.access_time_rounded;

      case 'WHERE':
        return Icons.location_on_rounded;

      case 'WHY':
        return Icons.psychology_rounded;

      case 'HOW':
        return Icons.lightbulb_rounded;

      default:
        return Icons.quiz_rounded;
    }
  }

  String _categoryDescription() {
    switch (_questionCategory) {
      case 'WHO':
        return 'Find the person involved in the story.';

      case 'WHAT':
        return 'Find out what happened in the story.';

      case 'WHEN':
        return 'Find out when something happened.';

      case 'WHERE':
        return 'Find the place mentioned in the story.';

      case 'WHY':
        return 'Find the reason behind an event.';

      case 'HOW':
        return 'Explain how something happened.';

      default:
        return 'Answer the question based on the story.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFE),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    return SafeArea(
      child: Column(
        children: [
          _buildTopHeader(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                28,
              ),
              child: Column(
                children: [
                  _buildCategoryCard(),

                  const SizedBox(height: 16),

                  _buildQuestionCard(),

                  const SizedBox(height: 16),

                  _buildAnswerCard(),

                  const SizedBox(height: 16),

                  _buildFeedback(),

                  const SizedBox(height: 10),

                  _buildBottomStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
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
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),

            SizedBox(height: 18),

            Text(
              'Loading your challenge...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final progress = (_currentIndex + 1) / _questions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6DD5FA),
            Color(0xFF2980B9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // BACK BUTTON
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Back',
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                  onPressed: () {
                    if (_isSubmitting) return;

                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(width: 10),

              // GAME ICON
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              // TITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5W1H CHALLENGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              _buildScoreBadge(),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_questions.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                'Correct: $_correct',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Color(0xFFFFD54F),
            size: 20,
          ),

          const SizedBox(width: 5),

          Text(
            '$_score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    final color = _categoryColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _categoryIcon(),
              color: color,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _questionCategory,
                      style: TextStyle(
                        color: color,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '5W1H',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5E6B75),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  _categoryDescription(),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
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

  Widget _buildQuestionCard() {
    final color = _categoryColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F5F8B).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.question_mark_rounded,
                  color: color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'QUESTION',
                style: TextStyle(
                  color: Color(0xFF71808B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            _cleanQuestionText,
            style: const TextStyle(
              color: Color(0xFF1E2A32),
              fontSize: 19,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard() {
    final disabled = _hasAnswered || _isSubmitting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F5F8B).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF2980B9),
                size: 23,
              ),

              SizedBox(width: 8),

              Text(
                'YOUR ANSWER',
                style: TextStyle(
                  color: Color(0xFF26343D),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            enabled: !disabled,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _checkAnswer(),
            style: const TextStyle(
              color: Color(0xFF26343D),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF4F9FC),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 8,
                  top: 11,
                ),
                child: Icon(
                  Icons.keyboard_rounded,
                  color: Color(0xFF4FACFE),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: const Color(0xFFB9DCEE)
                      .withValues(alpha: 0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: const Color(0xFFB9DCEE)
                      .withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: const BorderSide(
                  color: Color(0xFF2980B9),
                  width: 1.7,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton.icon(
              onPressed: disabled ? null : _checkAnswer,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_rounded,
                      size: 21,
                    ),
              label: Text(
                _isSubmitting
                    ? 'Saving Result...'
                    : 'Check Answer',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2980B9),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    if (!_hasAnswered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7FD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFBFE7F7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF4FACFE)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF2980B9),
                size: 21,
              ),
            ),

            const SizedBox(width: 11),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Think carefully! 🧠',
                    style: TextStyle(
                      color: Color(0xFF1F5F8B),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Read the story carefully and answer based on the information in the story.',
                    style: TextStyle(
                      color: Color(0xFF607784),
                      fontSize: 12.5,
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

    final feedbackColor = _lastAnswerCorrect
        ? const Color(0xFF43B883)
        : const Color(0xFFE85D5D);

    final backgroundColor = _lastAnswerCorrect
        ? const Color(0xFFEAF9F1)
        : const Color(0xFFFFEEEE);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: feedbackColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: feedbackColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _lastAnswerCorrect
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: feedbackColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              _feedbackMessage,
              style: TextStyle(
                color: _lastAnswerCorrect
                    ? const Color(0xFF267A55)
                    : const Color(0xFFB23B3B),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle_rounded,
            label: 'Correct',
            value: '$_correct',
            color: const Color(0xFF43B883),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatItem(
            icon: Icons.close_rounded,
            label: 'Wrong',
            value: '$_wrong',
            color: const Color(0xFFE85D5D),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatItem(
            icon: Icons.stars_rounded,
            label: 'Score',
            value: '$_score',
            color: const Color(0xFFFFB52E),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D5D)
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Color(0xFFE85D5D),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Unable to Load Game',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF26343D),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _errorMessage ??
                      'An unknown error occurred.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loadQuestions,
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Try Again',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2980B9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FACFE)
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Color(0xFF2980B9),
                    size: 39,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'No Questions Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF26343D),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'There are no 5W1H questions available for this story and level.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                OutlinedButton.icon(
                  onPressed: _loadQuestions,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text(
                    'Reload',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2980B9),
                    side: const BorderSide(
                      color: Color(0xFF2980B9),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}