import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../services/story_service.dart';
import 'game_menu_page.dart';

class StoryReaderPage extends StatefulWidget {
  final Story story;

  const StoryReaderPage({
    super.key,
    required this.story,
  });

  @override
  State<StoryReaderPage> createState() =>
      _StoryReaderPageState();
}

class _StoryReaderPageState
    extends State<StoryReaderPage> {
  final PdfViewerController _pdfViewerController =
      PdfViewerController();

  int currentPage = 1;
  int totalPages = 0;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
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
              // CUSTOM APP BAR
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

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Story Reader",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.story.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.18,
                        ),
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
              ),

              // ==================================================
              // MAIN CONTENT
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
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    child: Column(
                      children: [
                        // ==========================================
                        // STORY INFORMATION
                        // ==========================================

                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            16,
                            18,
                            12,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(
                              14,
                            ),
                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                    0xFFE5F6FD,
                                  ),
                                  Color(
                                    0xFFF5FBFE,
                                  ),
                                ],
                                begin:
                                    Alignment.topLeft,
                                end: Alignment
                                    .bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                              border: Border.all(
                                color: const Color(
                                  0xFFD4EDF7,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
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
                                      13,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .auto_stories_rounded,
                                    color:
                                        Colors.white,
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      const Text(
                                        "NOW READING",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              10,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          letterSpacing:
                                              0.6,
                                          color:
                                              Color(
                                            0xFF2980B9,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        widget.story
                                            .title,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              16,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Color(
                                            0xFF23495C,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Reading icon
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(8),
                                  decoration:
                                      BoxDecoration(
                                    color: const Color(
                                      0xFFFFC857,
                                    ).withValues(
                                      alpha: 0.18,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .lightbulb_rounded,
                                    color:
                                        Color(
                                      0xFFFFA000,
                                    ),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ==========================================
                        // PDF VIEWER
                        // ==========================================

                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(
                                    alpha: 0.06,
                                  ),
                                  blurRadius: 10,
                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                              child:
                                  SfPdfViewer.network(
                                widget.story.pdfFile,
                                controller:
                                    _pdfViewerController,
                                onDocumentLoaded:
                                    (
                                  PdfDocumentLoadedDetails
                                      details,
                                ) {
                                  if (!mounted) {
                                    return;
                                  }

                                  setState(() {
                                    totalPages =
                                        details
                                            .document
                                            .pages
                                            .count;
                                  });
                                },
                                onPageChanged:
                                    (
                                  PdfPageChangedDetails
                                      details,
                                ) {
                                  if (!mounted) {
                                    return;
                                  }

                                  setState(() {
                                    currentPage =
                                        details
                                            .newPageNumber;
                                  });
                                },
                                onDocumentLoadFailed:
                                    (
                                  PdfDocumentLoadFailedDetails
                                      details,
                                ) {
                                  debugPrint(
                                    'PDF ERROR: ${details.error}',
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // ==========================================
                        // PAGE INDICATOR
                        // ==========================================

                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            10,
                            18,
                            4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 11,
                                  vertical: 7,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                    0xFFE5F6FD,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .menu_book_rounded,
                                      size: 17,
                                      color:
                                          Color(
                                        0xFF2980B9,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      totalPages > 0
                                          ? "Page $currentPage / $totalPages"
                                          : "Loading...",
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            12,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color:
                                            Color(
                                          0xFF2980B9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              if (totalPages > 0)
                                Text(
                                  currentPage ==
                                          totalPages
                                      ? "Story completed! 🎉"
                                      : "Keep reading!",
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    color:
                                        Colors.black54,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ==========================================
                        // GAME BUTTON
                        // ==========================================

                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            8,
                            18,
                            16,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF2980B9,
                                ),
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    17,
                                  ),
                                ),
                                elevation: 5,
                                shadowColor:
                                    const Color(
                                  0xFF2980B9,
                                ).withValues(
                                  alpha: 0.35,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            GameMenuPage(
                                      storyId:
                                          widget.story
                                              .id,
                                      storyTitle:
                                          widget.story
                                              .title,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .sports_esports_rounded,
                                size: 23,
                              ),
                              label: const Text(
                                "Play Games from This Story",
                                style:
                                    TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}