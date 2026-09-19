import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import 'level_selection_page.dart';

class GameMenuPage extends StatefulWidget {
  final int storyId;
  final String storyTitle;

  const GameMenuPage({
    super.key,
    required this.storyId,
    required this.storyTitle,
  });

  @override
  State<GameMenuPage> createState() =>
      _GameMenuPageState();
}

class _GameMenuPageState
    extends State<GameMenuPage> {
  List<GameType> _games = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  // ============================================================
  // LOAD GAMES
  // ============================================================

  Future<void> _loadGames() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final games =
          await GameService.getGameTypes();

      if (!mounted) return;

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // OPEN LEVEL SELECTION
  // ============================================================

  void _openLevelSelection(GameType game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LevelSelectionPage(
          storyId: widget.storyId,
          storyTitle: widget.storyTitle,
          gameTypeId: game.id,
          gameTitle: game.name,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN GAME
  // ============================================================

  void _openGame(GameType game) {
    // All available games go through level selection first.

    switch (game.id) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
        _openLevelSelection(game);
        break;

      default:
        _showUnavailable(game.name);
    }
  }

  // ============================================================
  // UNAVAILABLE GAME
  // ============================================================

  void _showUnavailable(String gameName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Game Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '$gameName is not available yet.',
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GAME ICON
  // ============================================================

  IconData _getGameIcon(String icon) {
    switch (icon.toLowerCase()) {
      case 'quiz':
        return Icons.quiz_rounded;

      case 'match':
        return Icons.compare_arrows_rounded;

      case 'guess':
        return Icons.psychology_rounded;

      case 'true_false':
        return Icons.check_circle_outline_rounded;

      case 'sentence':
        return Icons.format_align_left_rounded;

      case '5w1h':
        return Icons.question_answer_rounded;

      default:
        return Icons.games_rounded;
    }
  }

  // ============================================================
  // GAME COLOR
  // ============================================================

  Color _getGameColor(int gameId) {
    switch (gameId) {
      case 1:
        return const Color(0xFF2980B9);

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
        return const Color(0xFF2980B9);
    }
  }

  // ============================================================
  // GAME NUMBER
  // ============================================================

  String _getGameNumber(int gameId) {
    switch (gameId) {
      case 1:
        return '01';

      case 2:
        return '02';

      case 3:
        return '03';

      case 4:
        return '04';

      case 5:
        return '05';

      case 6:
        return '06';

      default:
        return '--';
    }
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
          child: Column(
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Game Center",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Play, learn, and improve your English!",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white70,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons
                            .sports_esports_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7FBFE),
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: RefreshIndicator(
                    color:
                        const Color(0xFF2980B9),
                    onRefresh: _loadGames,
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
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF2980B9),
            ),
            SizedBox(height: 16),
            Text(
              "Loading games...",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF607D8B),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_games.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      children: [
        _buildStoryHeader(),

        const SizedBox(height: 22),

        // ========================================================
        // SECTION TITLE
        // ========================================================

        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE4F4FB,
                ),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons
                    .sports_esports_rounded,
                color: Color(0xFF2980B9),
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
                    'Choose Your Game',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                      color: Color(0xFF23495C),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Choose a game and test your story understanding!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        ..._games.map(
          _buildGameCard,
        ),
      ],
    );
  }

  // ============================================================
  // STORY HEADER
  // ============================================================

  Widget _buildStoryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6DD5FA),
            Color(0xFF2980B9),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT STORY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.storyTitle.isEmpty
                      ? 'English Story'
                      : widget.storyTitle,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Ready for a new challenge? 🚀',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
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
  // GAME CARD
  // ============================================================

  Widget _buildGameCard(GameType game) {
    final color =
        _getGameColor(game.id);

    final icon =
        _getGameIcon(game.icon);

    final bool isAvailable =
        game.id >= 1 &&
        game.id <= 6;

    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.07,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius:
            BorderRadius.circular(22),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(22),
          onTap: isAvailable
              ? () => _openGame(game)
              : () => _showUnavailable(
                    game.name,
                  ),
          child: Padding(
            padding:
                const EdgeInsets.all(14),
            child: Row(
              children: [
                // ==================================================
                // GAME NUMBER
                // ==================================================

                Container(
                  width: 32,
                  height: 32,
                  alignment:
                      Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    _getGameNumber(
                      game.id,
                    ),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                // ==================================================
                // GAME ICON
                // ==================================================

                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        color.withValues(
                          alpha: 0.18,
                        ),
                        color.withValues(
                          alpha: 0.08,
                        ),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Stack(
                    alignment:
                        Alignment.center,
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 31,
                      ),

                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration:
                              BoxDecoration(
                            color: color,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // ==================================================
                // INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF23495C),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        game.description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color:
                              Colors.black54,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .play_circle_outline_rounded,
                            size: 16,
                            color: color,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Text(
                            'Play Now',
                            style:
                                TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ==================================================
                // ARROW
                // ==================================================

                Container(
                  width: 32,
                  height: 32,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withValues(
                      alpha: 0.08,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .arrow_forward_ios_rounded,
                    size: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.22,
        ),

        Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFEBEE,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .cloud_off_rounded,
                    size: 46,
                    color:
                        Colors.redAccent,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'Oops! Games could not be loaded.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF23495C),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  _errorMessage!,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ElevatedButton.icon(
                  onPressed: _loadGames,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label:
                      const Text(
                    'Try Again',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2980B9,
                    ),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.22,
        ),

        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    colors: [
                      Color(0xFF6DD5FA),
                      Color(0xFF2980B9),
                    ],
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .sports_esports_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'No games available',
                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF23495C),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Games will appear here when\nthey are added by the administrator.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}