import 'package:flutter/material.dart';

class DevelopmentPage extends StatelessWidget {
  const DevelopmentPage({super.key});

  // ============================================================
  // FORUGA READ THEME
  // ============================================================

  static const Color primaryBlue = Color(0xFF2980B9);
  static const Color gradientBlue = Color(0xFF6DD5FA);
  static const Color lightBlue = Color(0xFFE6F5FC);
  static const Color backgroundColor = Color(0xFFF5FAFD);
  static const Color darkBlue = Color(0xFF23495C);
  static const Color greyText = Color(0xFF667781);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientBlue,
                primaryBlue,
              ],
            ),
          ),
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
                      // =================================================
                      // INTRO
                      // =================================================

                      _buildIntroCard(),

                      const SizedBox(height: 16),

                      // =================================================
                      // BACKGROUND & PROBLEM
                      // =================================================

                      _buildSectionCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Background & Problem',
                        child: _buildBackgroundContent(),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // SOLUTION
                      // =================================================

                      _buildSectionCard(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'The Solution',
                        child: _buildSolutionContent(),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // DEVELOPMENT TEAM
                      // =================================================

                      _buildSectionCard(
                        icon: Icons.groups_rounded,
                        title: 'Developers Team',
                        child: _buildTeamContent(),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // DEVELOPMENT PROCESS
                      // =================================================

                      _buildSectionCard(
                        icon: Icons.developer_mode_rounded,
                        title: 'Developers Process',
                        child: _buildDevelopmentProcess(),
                      ),

                      const SizedBox(height: 16),

                      // =================================================
                      // VISION
                      // =================================================

                      _buildSectionCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Developers Vision',
                        child: _buildVisionContent(),
                      ),

                      const SizedBox(height: 22),

                      // =================================================
                      // FOOTER
                      // =================================================

                      const Text(
                        'FORUGA READ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Learn • Read • Play • Grow',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
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
        8,
        8,
        16,
        10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 2),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Developers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Behind the Developers of FORUGA READ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.developer_mode_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: primaryBlue,
              size: 42,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Behind FORUGA READ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: darkBlue,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'FORUGA READ is an educational application that combines '
            'Indonesian folktales, English learning, reading activities, '
            'and interactive games in one learning experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND & PROBLEM
  // ============================================================

  Widget _buildBackgroundContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Developers of FORUGA READ was motivated by the need '
          'for an English learning medium that is interesting, '
          'interactive, and connected with Indonesian culture.',
          style: TextStyle(
            fontSize: 14,
            height: 1.65,
            color: greyText,
          ),
        ),

        SizedBox(height: 14),

        Text(
          'Several learning challenges became the basis for the '
          'Developers of this application:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),

        SizedBox(height: 12),

        _BulletItem(
          icon: Icons.menu_book_outlined,
          text:
              'Reading activities can become less engaging when '
              'presented only through conventional learning materials.',
        ),

        _BulletItem(
          icon: Icons.translate_rounded,
          text:
              'Learners need opportunities to develop English vocabulary '
              'and reading comprehension through meaningful contexts.',
        ),

        _BulletItem(
          icon: Icons.auto_stories_rounded,
          text:
              'Indonesian folktales contain cultural stories and values '
              'that can be integrated into digital learning media.',
        ),

        _BulletItem(
          icon: Icons.games_outlined,
          text:
              'Learning activities can be combined with interactive '
              'games to encourage active participation.',
        ),

        _BulletItem(
          icon: Icons.devices_rounded,
          text:
              'There is an opportunity to integrate reading activities '
              'and interactive learning activities into one application.',
        ),
      ],
    );
  }

  // ============================================================
  // SOLUTION
  // ============================================================

  Widget _buildSolutionContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FORUGA READ provides an integrated learning experience '
          'by combining story reading, English learning, and '
          'interactive games in one application.',
          style: TextStyle(
            fontSize: 14,
            height: 1.65,
            color: greyText,
          ),
        ),

        SizedBox(height: 14),

        Text(
          'The application provides:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),

        SizedBox(height: 12),

        _BulletItem(
          icon: Icons.auto_stories_rounded,
          text:
              'Indonesian folktales presented as English learning stories.',
        ),

        _BulletItem(
          icon: Icons.spellcheck_rounded,
          text:
              'Vocabulary and reading comprehension activities based '
              'on the stories.',
        ),

        _BulletItem(
          icon: Icons.games_rounded,
          text:
              'Interactive learning games that are connected with '
              'the story content.',
        ),

        _BulletItem(
          icon: Icons.layers_rounded,
          text:
              'Multiple learning levels ranging from Beginner '
              'to Master.',
        ),

        _BulletItem(
          icon: Icons.scoreboard_rounded,
          text:
              'Scores and progress tracking to support the learning journey.',
        ),

        _BulletItem(
          icon: Icons.leaderboard_rounded,
          text:
              'Leaderboard functionality that presents learning results '
              'and achievements.',
        ),
      ],
    );
  }

  // ============================================================
  // DEVELOPMENT TEAM
  // ============================================================

  Widget _buildTeamContent() {
    return Column(
      children: [
        const Text(
          'FORUGA READ was developed through collaboration between '
          'project management and technical Developers roles.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: greyText,
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // RUDI PERMADI
        // ========================================================

        _buildMemberCard(
          imagePath:
              'assets/images/development/rudi.jpeg',
          name: 'Rudi Permadi, M.Pd.',
          role: 'Project Manager',
          description:
              'An English lecturer of Universitas Islam Tasikmalaya ( A converting campus from Institut Agama Islam Tasikmalaya) '
              'and also English lecturer at several universities who manages,'
              'directs, and responsible for overall project developments of the application',
        ),

        const SizedBox(height: 14),

        // ========================================================
        // UDIN ZAENUDIN
        // ========================================================

        _buildMemberCard(
          imagePath:
              'assets/images/development/udin.jpeg',
          name: 'Udin Zaenudin, M.Ed.',
          role: 'Project Manager',
          description:
              'An Arabic lecturer of Universitas Islam Tasikmalaya ( A converting campus from Institut Agama Islam Tasikmalaya)'
              'who manages, directs and responsible for overall project developments of the application',
        ),

        const SizedBox(height: 14),

        // ========================================================
        // ASEP SUHENDAR
        // ========================================================

        _buildMemberCard(
          imagePath:
              'assets/images/development/suhee.jpg',
          name: 'Asep Suhendar',
          role: 'Full Stack Developer',
          description:
              'An Informatics Engineering student at Universitas Mayasari Bakti '
              'who contributes as a Full Stack Developer in the Developers '
              'and implementation of the FORUGA READ application.',
        ),

        const SizedBox(height: 14),

        // ========================================================
        // ANDHIKA TIRTPRANA ARDI
        // ========================================================

        _buildMemberCard(
          imagePath:
              'assets/images/development/andika.jpeg',
          name: 'Andhika Tirtaprana Ardi',
          role: 'Full Stack Developer',
          description:
              'An Informatics Engineering student at Universitas Mayasari Bakti '
              'who contributes as a Full Stack Developer in the Developers '
              'and implementation of the FORUGA READ application.',
        ),
      ],
    );
  }

  // ============================================================
  // MEMBER CARD
  // ============================================================

  Widget _buildMemberCard({
    required String imagePath,
    required String name,
    required String role,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5EEF3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: 88,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 88,
                  height: 110,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: primaryBlue,
                    size: 42,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: greyText,
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
  // DEVELOPMENT PROCESS
  // ============================================================

  Widget _buildDevelopmentProcess() {
    return const Column(
      children: [
        _ProcessItem(
          number: '01',
          icon: Icons.lightbulb_outline_rounded,
          title: 'Planning',
          description:
              'Identifying the learning needs, application goals, '
              'and overall concept of FORUGA READ.',
        ),

        SizedBox(height: 12),

        _ProcessItem(
          number: '02',
          icon: Icons.architecture_rounded,
          title: 'System Design',
          description:
              'Designing the application structure, user flow, '
              'database, and supporting system components.',
        ),

        SizedBox(height: 12),

        _ProcessItem(
          number: '03',
          icon: Icons.code_rounded,
          title: 'Development',
          description:
              'Implementing the application interface, backend, '
              'database, stories, games, and learning features.',
        ),

        SizedBox(height: 12),

        _ProcessItem(
          number: '04',
          icon: Icons.bug_report_outlined,
          title: 'Testing',
          description:
              'Testing application functions, learning activities, '
              'data processing, and user interaction.',
        ),

        SizedBox(height: 12),

        _ProcessItem(
          number: '05',
          icon: Icons.rocket_launch_rounded,
          title: 'Implementation',
          description:
              'Preparing the application for use as an interactive '
              'English learning platform.',
        ),
      ],
    );
  }

  // ============================================================
  // VISION
  // ============================================================

  Widget _buildVisionContent() {
    return const Column(
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: primaryBlue,
          size: 40,
        ),

        SizedBox(height: 10),

        Text(
          'Learn Through Stories and Play',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),

        SizedBox(height: 9),

        Text(
          'FORUGA READ is designed to create a learning experience '
          'where reading, English learning, Indonesian culture, '
          'and interactive activities can work together.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: greyText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: primaryBlue,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// BULLET ITEM
// ================================================================

class _BulletItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: DevelopmentPage.lightBlue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 16,
              color: DevelopmentPage.primaryBlue,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: DevelopmentPage.greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DEVELOPMENT PROCESS ITEM
// ================================================================

class _ProcessItem extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _ProcessItem({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: DevelopmentPage.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5EEF3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: DevelopmentPage.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: DevelopmentPage.primaryBlue,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: DevelopmentPage.primaryBlue,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DevelopmentPage.darkBlue,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: DevelopmentPage.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}