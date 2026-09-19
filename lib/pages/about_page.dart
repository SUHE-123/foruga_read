import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ============================================================
  // PDF GUIDE URL
  // ============================================================
  //
  // For Android Emulator, the computer's localhost is usually:
  // 10.0.2.2
  //
  // For Flutter Web/Desktop, localhost can be used.
  //
  // If the application is deployed to a hosting server,
  // simply replace this URL with the hosting URL.
  //
  static const String guidePdfUrl =
      "https://sightsavers.id/foruga_admin/uploads/panduan/FORUGA_READ_Panduan_Aplikasi.pdf";

  Future<void> _openGuidePdf(BuildContext context) async {
    final uri = Uri.parse(guidePdfUrl);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The PDF guide could not be opened.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open the PDF guide: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFD),
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
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    30,
                  ),
                  child: Column(
                    children: [
                      _buildAppIdentity(),
                      const SizedBox(height: 18),

                      _buildGuideCard(context),
                      const SizedBox(height: 16),

                      _buildAboutCard(),
                      const SizedBox(height: 16),

                      _buildGoalsCard(),
                      const SizedBox(height: 16),

                      _buildHowToUseCard(),
                      const SizedBox(height: 16),

                      _buildStoryCard(),
                      const SizedBox(height: 16),

                      _buildGamesCard(),
                      const SizedBox(height: 16),

                      _buildLevelsCard(),
                      const SizedBox(height: 16),

                      _buildScoreProgressCard(),
                      const SizedBox(height: 16),

                      _buildLeaderboardCard(),
                      const SizedBox(height: 16),

                      _buildProfileCard(),
                      const SizedBox(height: 16),

                      _buildTipsCard(),
                      const SizedBox(height: 22),

                      _buildFooter(),
                    ],
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        16,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 4),

          const Expanded(
            child: Text(
              'About & App Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP IDENTITY
  // ============================================================

  Widget _buildAppIdentity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6DD5FA),
                  Color(0xFF2980B9),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2980B9)
                      .withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'FORUGA READ',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F5F8B),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Interactive Story Learning App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '📖 Read • 🎮 Play • 🏆 Learn',
              style: TextStyle(
                color: Color(0xFF1F5F8B),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF GUIDE
  // ============================================================

  Widget _buildGuideCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F5F8B),
            Color(0xFF2980B9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Text(
                  'Complete App Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Not sure how to use FORUGA READ? '
            'Read the complete guide to learn how to register, '
            'read stories, play games, earn scores, '
            'check your progress, and use other features.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _openGuidePdf(context);
              },
              icon: const Icon(
                Icons.open_in_new_rounded,
              ),
              label: const Text(
                'Open PDF Guide',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F5F8B),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ABOUT
  // ============================================================

  Widget _buildAboutCard() {
    return _buildSectionCard(
      icon: Icons.auto_stories_rounded,
      title: 'About FORUGA READ',
      children: [
        _buildParagraph(
          'FORUGA READ is an English learning application '
          'that combines story reading activities with '
          'interactive games.',
        ),
        _buildParagraph(
          'Through this application, users can read Indonesian '
          'folktales in English, learn new vocabulary, '
          'understand the story, and test their comprehension '
          'through various mini games.',
        ),
        _buildParagraph(
          'With a learn-through-play concept, FORUGA READ helps '
          'make reading activities more interesting, enjoyable, '
          'and engaging.',
        ),
      ],
    );
  }

  // ============================================================
  // GOALS
  // ============================================================

  Widget _buildGoalsCard() {
    return _buildSectionCard(
      icon: Icons.flag_rounded,
      title: 'App Goals',
      children: [
        _buildGoalItem(
          Icons.menu_book_rounded,
          'Improve English reading skills.',
        ),
        _buildGoalItem(
          Icons.translate_rounded,
          'Build English vocabulary through stories.',
        ),
        _buildGoalItem(
          Icons.psychology_rounded,
          'Practice understanding story content and details.',
        ),
        _buildGoalItem(
          Icons.sports_esports_rounded,
          'Make the learning process more fun and enjoyable.',
        ),
        _buildGoalItem(
          Icons.trending_up_rounded,
          'Encourage users to continuously improve their skills.',
        ),
      ],
    );
  }

  // ============================================================
  // HOW TO USE
  // ============================================================

  Widget _buildHowToUseCard() {
    return _buildSectionCard(
      icon: Icons.route_rounded,
      title: 'How to Use the App',
      children: [
        _buildStepItem(
          1,
          'Create an Account',
          'Register using your name, email, and password.',
        ),
        _buildStepItem(
          2,
          'Login',
          'Sign in using the account you have created.',
        ),
        _buildStepItem(
          3,
          'Choose a Story',
          'Open the Story Library and choose a story you want to learn.',
        ),
        _buildStepItem(
          4,
          'Read the Story',
          'Read the story carefully and pay attention to important information.',
        ),
        _buildStepItem(
          5,
          'Play the Games',
          'Open Mini Games to test your understanding of the story.',
        ),
        _buildStepItem(
          6,
          'Earn Scores',
          'Answer questions correctly to earn scores.',
        ),
        _buildStepItem(
          7,
          'Increase Your Level',
          'Complete levels and continue to the next level.',
        ),
        _buildStepItem(
          8,
          'Check Your Progress',
          'Check your learning development through results and progress.',
        ),
      ],
    );
  }

  // ============================================================
  // STORY
  // ============================================================

  Widget _buildStoryCard() {
    return _buildSectionCard(
      icon: Icons.library_books_rounded,
      title: 'Story Library & Story Reader',
      children: [
        _buildParagraph(
          'The Story Library is where you can choose the stories '
          'you want to read and learn from.',
        ),
        const SizedBox(height: 4),
        _buildStoryChip('Timun Mas'),
        _buildStoryChip('Malin Kundang'),
        _buildStoryChip('Roro Jonggrang'),
        _buildStoryChip('Keong Mas'),
        _buildStoryChip('Jaka Tarub'),
        const SizedBox(height: 10),
        _buildParagraph(
          'While reading, pay attention to the characters, setting, '
          'time, events, new vocabulary, and cause-and-effect '
          'relationships in the story.',
        ),
      ],
    );
  }

  Widget _buildStoryChip(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.book_rounded,
            color: Color(0xFF2980B9),
            size: 19,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334E5C),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GAMES
  // ============================================================

  Widget _buildGamesCard() {
    return _buildSectionCard(
      icon: Icons.sports_esports_rounded,
      title: 'Mini Games',
      children: [
        _buildGameInfo(
          '1',
          'Quiz',
          'Answer multiple-choice questions based on the story.',
          Icons.quiz_rounded,
        ),
        _buildGameInfo(
          '2',
          'Word Matching',
          'Match English words with the correct pairs.',
          Icons.compare_arrows_rounded,
        ),
        _buildGameInfo(
          '3',
          'Guess the Word',
          'Guess the correct word based on the given clues.',
          Icons.lightbulb_rounded,
        ),
        _buildGameInfo(
          '4',
          'True or False',
          'Decide whether a statement is true or false.',
          Icons.check_circle_outline_rounded,
        ),
        _buildGameInfo(
          '5',
          'Sentence Matching',
          'Match sentences with the correct pair or meaning.',
          Icons.format_align_left_rounded,
        ),
        _buildGameInfo(
          '6',
          '5W1H Challenge',
          'Answer Who, What, When, Where, Why, and How questions.',
          Icons.help_center_rounded,
        ),
      ],
    );
  }

  Widget _buildGameInfo(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE1EEF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2980B9),
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23495C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.black54,
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
  // LEVELS
  // ============================================================

  Widget _buildLevelsCard() {
    return _buildSectionCard(
      icon: Icons.stairs_rounded,
      title: 'Level Progression',
      children: [
        _buildLevelItem(
          'Beginner',
          'Basic vocabulary and simple questions.',
          Icons.looks_one_rounded,
        ),
        _buildLevelItem(
          'Elementary',
          'Main ideas, vocabulary, synonyms, antonyms, and basic comprehension.',
          Icons.looks_two_rounded,
        ),
        _buildLevelItem(
          'Intermediate',
          'References, inferences, cause and effect, and story details.',
          Icons.looks_3_rounded,
        ),
        _buildLevelItem(
          'Advanced',
          'Complex inferences, contextual vocabulary, and relationships between events.',
          Icons.looks_4_rounded,
        ),
        _buildLevelItem(
          'Master',
          'Overall reading ability and comprehensive understanding.',
          Icons.looks_5_rounded,
        ),
      ],
    );
  }

  Widget _buildLevelItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2980B9),
            size: 30,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF23495C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Colors.black54,
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
  // SCORE & PROGRESS
  // ============================================================

  Widget _buildScoreProgressCard() {
    return _buildSectionCard(
      icon: Icons.bar_chart_rounded,
      title: 'Score & Progress',
      children: [
        _buildFeatureRow(
          Icons.star_rounded,
          'Score',
          'Shows the total score you have earned.',
        ),
        _buildFeatureRow(
          Icons.check_circle_rounded,
          'Correct',
          'Shows the number of correctly answered questions.',
        ),
        _buildFeatureRow(
          Icons.cancel_rounded,
          'Wrong',
          'Shows the number of incorrectly answered questions.',
        ),
        _buildFeatureRow(
          Icons.percent_rounded,
          'Percentage',
          'Shows the percentage of your game result.',
        ),
        _buildFeatureRow(
          Icons.trending_up_rounded,
          'Progress',
          'Shows your learning development at each level.',
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2980B9),
            size: 24,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF23495C),
                    ),
                  ),
                  TextSpan(
                    text: description,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEADERBOARD
  // ============================================================

  Widget _buildLeaderboardCard() {
    return _buildSectionCard(
      icon: Icons.emoji_events_rounded,
      title: 'Leaderboard',
      children: [
        _buildParagraph(
          'The Leaderboard displays user rankings based on '
          'the total score they have earned.',
        ),
        _buildGoalItem(
          Icons.menu_book_rounded,
          'Read the stories carefully.',
        ),
        _buildGoalItem(
          Icons.translate_rounded,
          'Understand important vocabulary.',
        ),
        _buildGoalItem(
          Icons.quiz_rounded,
          'Answer questions based on the story.',
        ),
        _buildGoalItem(
          Icons.replay_rounded,
          'Repeat games that you still find difficult.',
        ),
        _buildGoalItem(
          Icons.trending_up_rounded,
          'Complete the levels step by step.',
        ),
      ],
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfileCard() {
    return _buildSectionCard(
      icon: Icons.person_rounded,
      title: 'Profile',
      children: [
        _buildParagraph(
          'The Profile page is used to view your account '
          'information and learning statistics.',
        ),
        _buildProfileItem(
          Icons.person_outline_rounded,
          'Username',
        ),
        _buildProfileItem(
          Icons.email_outlined,
          'Email',
        ),
        _buildProfileItem(
          Icons.emoji_events_outlined,
          'Ranking',
        ),
        _buildProfileItem(
          Icons.star_outline_rounded,
          'Total Score',
        ),
        _buildProfileItem(
          Icons.check_circle_outline_rounded,
          'Number of correct answers',
        ),
        _buildProfileItem(
          Icons.cancel_outlined,
          'Number of wrong answers',
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF2980B9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF455A64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIPS
  // ============================================================

  Widget _buildTipsCard() {
    return _buildSectionCard(
      icon: Icons.lightbulb_rounded,
      title: 'Learning Tips',
      children: [
        _buildTipItem(
          'Do not rush when reading the stories.',
        ),
        _buildTipItem(
          'Try to understand difficult words from the context of the sentence.',
        ),
        _buildTipItem(
          'Do not be afraid of making mistakes while playing.',
        ),
        _buildTipItem(
          'Use your game results to identify areas that need more practice.',
        ),
        _buildTipItem(
          'Repeat the games to improve your understanding.',
        ),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            '📖 Read the story\n'
            '🎮 Play the games\n'
            '🏆 Improve your score\n'
            '📚 Keep learning English',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F5F8B),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'FORUGA READ • Interactive Story Learning App',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Version 1.0',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENERIC SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2980B9),
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23495C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // TEXT
  // ============================================================

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        height: 1.65,
        color: Color(0xFF455A64),
      ),
    );
  }

  // ============================================================
  // GOAL ITEM
  // ============================================================

  Widget _buildGoalItem(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5FC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF2980B9),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF455A64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP ITEM
  // ============================================================

  Widget _buildStepItem(
    int number,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6DD5FA),
                  Color(0xFF2980B9),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23495C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Colors.black54,
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
  // TIP ITEM
  // ============================================================

  Widget _buildTipItem(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF5D5340),
              ),
            ),
          ),
        ],
      ),
    );
  }
}