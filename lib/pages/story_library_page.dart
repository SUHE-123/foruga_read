import 'package:flutter/material.dart';
import '../services/story_service.dart';
import 'story_reader_page.dart';

class StoryLibraryPage extends StatefulWidget {
  const StoryLibraryPage({super.key});

  @override
  State<StoryLibraryPage> createState() =>
      _StoryLibraryPageState();
}

class _StoryLibraryPageState
    extends State<StoryLibraryPage> {
  late Future<List<Story>> _storiesFuture;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _storiesFuture = StoryService.getStories();
  }

  // ============================================================
  // REFRESH STORIES
  // ============================================================

  Future<void> _refreshStories() async {
    setState(() {
      _storiesFuture =
          StoryService.getStories();
    });

    await _storiesFuture;
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
                        color: Colors.white.withValues(
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
                            "Story Library",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Explore amazing Indonesian folktales!",
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

                    // Refresh
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        tooltip: "Refresh stories",
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        onPressed:
                            _refreshStories,
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
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7FBFE),
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child:
                      FutureBuilder<List<Story>>(
                    future: _storiesFuture,
                    builder:
                        (context, snapshot) {
                      // ==========================================
                      // LOADING
                      // ==========================================

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 3,
                                color:
                                    Color(0xFF2980B9),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Loading stories...",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                  color:
                                      Color(0xFF607D8B),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ==========================================
                      // ERROR
                      // ==========================================

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              24,
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration:
                                      BoxDecoration(
                                    color: const Color(
                                      0xFFE3F2FD,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons
                                        .cloud_off_rounded,
                                    size: 46,
                                    color:
                                        Color(0xFF2980B9),
                                  ),
                                ),

                                const SizedBox(
                                  height: 18,
                                ),

                                const Text(
                                  "Oops! Stories could not be loaded.",
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
                                  snapshot.error
                                      .toString(),
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                ElevatedButton.icon(
                                  onPressed:
                                      _refreshStories,
                                  icon: const Icon(
                                    Icons
                                        .refresh_rounded,
                                  ),
                                  label:
                                      const Text(
                                    "Try Again",
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
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
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // ==========================================
                      // DATA
                      // ==========================================

                      final stories =
                          snapshot.data ?? [];

                      // ==========================================
                      // EMPTY
                      // ==========================================

                      if (stories.isEmpty) {
                        return RefreshIndicator(
                          color:
                              const Color(0xFF2980B9),
                          onRefresh:
                              _refreshStories,
                          child: ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(
                                height: 100,
                              ),

                              Container(
                                width: 110,
                                height: 110,
                                margin:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 100,
                                ),
                                decoration:
                                    BoxDecoration(
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(
                                        0xFF6DD5FA,
                                      ),
                                      Color(
                                        0xFF2980B9,
                                      ),
                                    ],
                                  ),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons
                                      .auto_stories_rounded,
                                  size: 55,
                                  color:
                                      Colors.white,
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              const Center(
                                child: Text(
                                  "No stories available",
                                  style:
                                      TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Color(
                                      0xFF23495C,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              const Center(
                                child: Text(
                                  "Stories will appear here when\n"
                                  "they are added by the administrator.",
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ==========================================
                      // STORY LIST
                      // ==========================================

                      return RefreshIndicator(
                        color:
                            const Color(0xFF2980B9),
                        onRefresh:
                            _refreshStories,
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),
                          itemCount:
                              stories.length,
                          itemBuilder:
                              (context, index) {
                            final story =
                                stories[index];

                            return _storyCard(
                              title: story.title,
                              image: story.image,
                              index: index,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            StoryReaderPage(
                                      story: story,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
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
  // STORY CARD
  // ============================================================

  Widget _storyCard({
    required String title,
    required String image,
    required int index,
    required VoidCallback onTap,
  }) {
    // ==========================================================
    // COLOR VARIATION
    // ==========================================================

    final colors = [
      const Color(0xFF4FACFE),
      const Color(0xFF43D6A5),
      const Color(0xFFFFC857),
      const Color(0xFFA78BFA),
      const Color(0xFFFF8A65),
    ];

    final cardColor =
        colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.08,
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
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(22),
          child: Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                // ==================================================
                // STORY IMAGE
                // ==================================================

                Container(
                  width: 92,
                  height: 105,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            cardColor.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 8,
                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),
                    child: Image.network(
                      image,
                      width: 92,
                      height: 105,
                      fit: BoxFit.cover,

                      // ==========================================
                      // LOADING IMAGE
                      // ==========================================

                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress ==
                            null) {
                          return child;
                        }

                        return Container(
                          color:
                              cardColor
                                  .withValues(
                            alpha: 0.15,
                          ),
                          child:
                              const Center(
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color:
                                  Color(
                                0xFF2980B9,
                              ),
                            ),
                          ),
                        );
                      },

                      // ==========================================
                      // IMAGE ERROR
                      // ==========================================

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              colors: [
                                cardColor
                                    .withValues(
                                  alpha: 0.35,
                                ),
                                cardColor
                                    .withValues(
                                  alpha: 0.15,
                                ),
                              ],
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .menu_book_rounded,
                            size: 38,
                            color:
                                Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                // ==================================================
                // STORY INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Story badge
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color: cardColor
                              .withValues(
                            alpha: 0.15,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          "📖 STORY",
                          style:
                              TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                cardColor
                                    .withValues(
                              alpha: 0.95,
                            ),
                            letterSpacing:
                                0.4,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // Story title
                      Text(
                        title,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF23495C),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      const Text(
                        "Read this story and discover a new adventure!",
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color:
                              Colors.black54,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // Read button
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                    0xFF6DD5FA,
                                  ),
                                  Color(
                                    0xFF2980B9,
                                  ),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                Text(
                                  "Read Story",
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 11.5,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons
                                      .arrow_forward_rounded,
                                  color:
                                      Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Small decorative icon
                          Container(
                            width: 34,
                            height: 34,
                            decoration:
                                BoxDecoration(
                              color: cardColor
                                  .withValues(
                                alpha: 0.12,
                              ),
                              shape:
                                  BoxShape
                                      .circle,
                            ),
                            child: Icon(
                              Icons
                                  .auto_stories_rounded,
                              color:
                                  cardColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
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