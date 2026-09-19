import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/game_models.dart';
import '../services/game_service.dart';
import '../services/session_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ============================================================
  // API
  // ============================================================

  static const String profileApiUrl =
      "https://api.sightsavers.id/api/profile";

  static const String avatarBaseUrl =
      "https://sightsavers.id/foruga_admin/uploads/profile/";

  // ============================================================
  // STATE
  // ============================================================

  SessionUser? user;
  LeaderboardItem? leaderboardUser;

  bool isLoading = true;
  bool isRefreshing = false;
  bool isUploadingAvatar = false;

  String? errorMessage;

  String? avatarUrl;

  Uint8List? selectedAvatarBytes;

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================================
  // RESOLVE AVATAR URL
  // ============================================================

  String _resolveAvatarUrl(String avatar) {
    String value = avatar.trim();

    if (value.isEmpty) {
      return '';
    }

    // Handle escaped slash from JSON.
    value = value.replaceAll(r'\/', '/');

    // Jika API sudah mengembalikan URL lengkap.
    if (value.startsWith('https://') ||
        value.startsWith('http://')) {
      return value;
    }

    // Bersihkan slash di awal.
    value = value.replaceFirst(RegExp(r'^/+'), '');

    // Jika database/API mengembalikan:
    // uploads/profile/nama_file.jpg
    if (value.startsWith('uploads/profile/')) {
      final fileName =
          value.substring('uploads/profile/'.length);

      return '$avatarBaseUrl$fileName';
    }

    // Jika hanya mengembalikan nama file:
    // nama_file.jpg
    return '$avatarBaseUrl$value';
  }

  // ============================================================
  // CACHE BUSTER
  // ============================================================

  String _avatarUrlWithCache(String url) {
    if (url.isEmpty) {
      return url;
    }

    final separator = url.contains('?') ? '&' : '?';

    return '$url${separator}v=${DateTime.now().millisecondsSinceEpoch}';
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> loadUser() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final current =
          await SessionService.getCurrentUser();

      if (current == null) {
        if (!mounted) return;

        setState(() {
          user = null;
          leaderboardUser = null;
          avatarUrl = null;
          selectedAvatarBytes = null;
          isLoading = false;
        });

        return;
      }

      // ========================================================
      // LOAD PROFILE AVATAR
      // ========================================================

      await _loadProfileAvatar(current.id);

      // ========================================================
      // LOAD LEADERBOARD
      // ========================================================

      LeaderboardItem? currentLeaderboardUser;

      try {
        final leaderboard =
            await GameService.getLeaderboard();

        for (final item in leaderboard) {
          if (item.userId == current.id) {
            currentLeaderboardUser = item;
            break;
          }
        }
      } catch (e) {
        debugPrint(
          'PROFILE LEADERBOARD ERROR: $e',
        );
      }

      if (!mounted) return;

      setState(() {
        user = current;
        leaderboardUser =
            currentLeaderboardUser;
        isLoading = false;
      });

      debugPrint(
        '========================================',
      );
      debugPrint('PROFILE LOADED');
      debugPrint('User ID : ${current.id}');
      debugPrint('Name    : ${current.name}');
      debugPrint('Email   : ${current.email}');
      debugPrint('Avatar  : $avatarUrl');

      if (currentLeaderboardUser != null) {
        debugPrint(
          'Rank    : #${currentLeaderboardUser.rank}',
        );

        debugPrint(
          'Score   : ${currentLeaderboardUser.score}',
        );

        debugPrint(
          'Correct : ${currentLeaderboardUser.correct}',
        );

        debugPrint(
          'Wrong   : ${currentLeaderboardUser.wrong}',
        );
      }

      debugPrint(
        '========================================',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      debugPrint(
        'PROFILE ERROR: $e',
      );
    }
  }

  // ============================================================
  // LOAD PROFILE AVATAR
  // ============================================================

  Future<void> _loadProfileAvatar(
    String userId,
  ) async {
    try {
      final uri = Uri.parse(
        '$profileApiUrl/show.php?user_id=${Uri.encodeComponent(userId)}',
      );

      final response = await http.get(uri);

      debugPrint(
        'PROFILE API STATUS: ${response.statusCode}',
      );

      debugPrint(
        'PROFILE API RESPONSE: ${response.body}',
      );

      if (response.statusCode != 200) {
        debugPrint(
          'PROFILE API ERROR: ${response.statusCode}',
        );

        return;
      }

      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        debugPrint(
          'PROFILE API INVALID JSON',
        );

        return;
      }

      if (json['success'] != true) {
        debugPrint(
          'PROFILE API SUCCESS FALSE: ${json['message']}',
        );

        return;
      }

      final data = json['data'];

      if (data is! Map<String, dynamic>) {
        debugPrint(
          'PROFILE API DATA INVALID',
        );

        return;
      }

      final avatar = data['avatar'];

      if (avatar != null &&
          avatar.toString().trim().isNotEmpty) {
        final resolvedUrl =
            _resolveAvatarUrl(
          avatar.toString(),
        );

        debugPrint(
          'PROFILE AVATAR ORIGINAL: $avatar',
        );

        debugPrint(
          'PROFILE AVATAR RESOLVED: $resolvedUrl',
        );

        if (!mounted) return;

        setState(() {
          avatarUrl = resolvedUrl;
        });
      } else {
        debugPrint(
          'PROFILE AVATAR: NULL',
        );

        if (!mounted) return;

        setState(() {
          avatarUrl = null;
        });
      }
    } catch (e) {
      debugPrint(
        'PROFILE AVATAR LOAD ERROR: $e',
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshProfile() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      final current =
          await SessionService.getCurrentUser();

      if (current == null) {
        if (!mounted) return;

        setState(() {
          user = null;
          leaderboardUser = null;
          avatarUrl = null;
          selectedAvatarBytes = null;
          isRefreshing = false;
        });

        return;
      }

      await _loadProfileAvatar(
        current.id,
      );

      LeaderboardItem? currentLeaderboardUser;

      try {
        final leaderboard =
            await GameService.getLeaderboard();

        for (final item in leaderboard) {
          if (item.userId == current.id) {
            currentLeaderboardUser = item;
            break;
          }
        }
      } catch (e) {
        debugPrint(
          'PROFILE REFRESH LEADERBOARD ERROR: $e',
        );
      }

      if (!mounted) return;

      setState(() {
        user = current;
        leaderboardUser =
            currentLeaderboardUser;
        isRefreshing = false;
      });

      debugPrint(
        'PROFILE REFRESHED',
      );

      debugPrint(
        'Avatar : $avatarUrl',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isRefreshing = false;
        errorMessage = e.toString();
      });

      debugPrint(
        'PROFILE REFRESH ERROR: $e',
      );
    }
  }

  // ============================================================
  // SELECT AVATAR
  // ============================================================

  Future<void> _selectAvatar() async {
    if (isUploadingAvatar) return;

    final source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: Container(
                    padding:
                        const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE3F2FD),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons
                          .photo_library_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  subtitle: const Text(
                    'Select a picture from your device',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),

                const SizedBox(height: 4),

                ListTile(
                  leading: Container(
                    padding:
                        const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFE3F2FD),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                  ),
                  subtitle: const Text(
                    'Use your device camera',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    await _pickAndUploadAvatar(source);
  }

  // ============================================================
  // PICK AND UPLOAD AVATAR
  // ============================================================

  Future<void> _pickAndUploadAvatar(
    ImageSource source,
  ) async {
    if (user == null) return;

    try {
      final XFile? image =
          await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (image == null) {
        debugPrint(
          'AVATAR SELECTION CANCELLED',
        );

        return;
      }

      final bytes =
          await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedAvatarBytes = bytes;
        isUploadingAvatar = true;
      });

      debugPrint(
        '========================================',
      );
      debugPrint('AVATAR UPLOAD START');
      debugPrint('User ID : ${user!.id}');
      debugPrint('File    : ${image.name}');
      debugPrint(
        'Size    : ${bytes.length} bytes',
      );
      debugPrint(
        '========================================',
      );

      final request =
          http.MultipartRequest(
        'POST',
        Uri.parse(
          '$profileApiUrl/upload_avatar.php',
        ),
      );

      request.fields['user_id'] =
          user!.id;

      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: image.name,
        ),
      );

      final streamedResponse =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        'AVATAR API STATUS: ${response.statusCode}',
      );

      debugPrint(
        'AVATAR API RESPONSE: ${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        try {
          final json =
              jsonDecode(response.body);

          if (json
              is! Map<String, dynamic>) {
            throw Exception(
              'Invalid server response.',
            );
          }

          if (json['success'] != true) {
            throw Exception(
              json['message']?.toString() ??
                  'Profile picture upload failed.',
            );
          }

          final data = json['data'];

          String? newAvatarUrl;

          if (data
              is Map<String, dynamic>) {
            final avatar =
                data['avatar'];

            if (avatar != null &&
                avatar
                    .toString()
                    .trim()
                    .isNotEmpty) {
              newAvatarUrl =
                  _resolveAvatarUrl(
                avatar.toString(),
              );
            }
          }

          debugPrint(
            'NEW AVATAR URL: $newAvatarUrl',
          );

          if (!mounted) return;

          setState(() {
            isUploadingAvatar = false;

            if (newAvatarUrl != null &&
                newAvatarUrl.isNotEmpty) {
              avatarUrl = newAvatarUrl;
            }
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile picture updated successfully.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          debugPrint(
            '========================================',
          );

          debugPrint(
            'AVATAR UPLOAD SUCCESS',
          );

          debugPrint(
            'Avatar URL : $newAvatarUrl',
          );

          debugPrint(
            '========================================',
          );
        } catch (e) {
          if (!mounted) return;

          setState(() {
            isUploadingAvatar = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile picture: $e',
              ),
              backgroundColor:
                  Colors.redAccent,
            ),
          );

          debugPrint(
            'AVATAR UPLOAD RESPONSE ERROR: $e',
          );
        }
      } else {
        if (!mounted) return;

        setState(() {
          isUploadingAvatar = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile picture.\n'
              '${response.body}',
            ),
            backgroundColor:
                Colors.redAccent,
          ),
        );

        debugPrint(
          'AVATAR UPLOAD FAILED: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploadingAvatar = false;
      });

      debugPrint(
        'AVATAR UPLOAD ERROR: $e',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload profile picture: $e',
          ),
          backgroundColor:
              Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // CURRENT SCORE
  // ============================================================

  int get currentScore {
    if (leaderboardUser != null) {
      return leaderboardUser!.score;
    }

    return user?.score ?? 0;
  }

  // ============================================================
  // CURRENT CORRECT
  // ============================================================

  int get currentCorrect {
    if (leaderboardUser != null) {
      return leaderboardUser!.correct;
    }

    return user?.correct ?? 0;
  }

  // ============================================================
  // CURRENT WRONG
  // ============================================================

  int get currentWrong {
    if (leaderboardUser != null) {
      return leaderboardUser!.wrong;
    }

    return user?.wrong ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    // ==========================================================
    // NO SESSION
    // ==========================================================

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_outlined,
                size: 60,
                color: Colors.grey,
              ),

              const SizedBox(height: 16),

              const Text(
                "No active session",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Go to Login",
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // PROFILE
    // ==========================================================

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF89F7FE),
              Color(0xFF66A6FF),
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
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Text(
                        "👤 My Profile",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: "Refresh",
                      onPressed:
                          isRefreshing
                              ? null
                              : refreshProfile,
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .refresh_rounded,
                              color:
                                  Colors.white,
                            ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // PROFILE CONTENT
              // ==================================================

              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.all(24),
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child:
                      RefreshIndicator(
                    onRefresh:
                        refreshProfile,
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: [
                        // ==================================================
                        // AVATAR
                        // ==================================================

                        Center(
                          child: Stack(
                            alignment:
                                Alignment.bottomRight,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(4),
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(
                                          0xFF6DD5FA),
                                      Color(
                                          0xFF2980B9),
                                    ],
                                    begin:
                                        Alignment.topLeft,
                                    end:
                                        Alignment.bottomRight,
                                  ),
                                ),
                                child:
                                    CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      Colors.blueAccent,

                                  // ==================================================
                                  // PRIORITAS:
                                  //
                                  // 1. Foto baru yang baru dipilih
                                  // 2. Foto dari server
                                  // 3. Initial nama
                                  // ==================================================

                                  backgroundImage:
                                      selectedAvatarBytes !=
                                              null
                                          ? MemoryImage(
                                              selectedAvatarBytes!,
                                            )
                                          : (avatarUrl !=
                                                      null &&
                                                  avatarUrl!
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                  _avatarUrlWithCache(
                                                    avatarUrl!,
                                                  ),
                                                )
                                              : null),

                                  child:
                                      selectedAvatarBytes ==
                                                  null &&
                                              (avatarUrl ==
                                                      null ||
                                                  avatarUrl!
                                                      .isEmpty)
                                          ? Text(
                                              user!.name.isNotEmpty
                                                  ? user!
                                                      .name[0]
                                                      .toUpperCase()
                                                  : "?",
                                              style:
                                                  const TextStyle(
                                                fontSize:
                                                    40,
                                                color:
                                                    Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                ),
                              ),

                              // ==================================================
                              // CAMERA BUTTON
                              // ==================================================

                              GestureDetector(
                                onTap:
                                    isUploadingAvatar
                                        ? null
                                        : _selectAvatar,
                                child:
                                    Container(
                                  width: 38,
                                  height: 38,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFF2980B9,
                                    ),
                                    shape:
                                        BoxShape.circle,
                                    border:
                                        Border.all(
                                      color:
                                          Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                                0.15),
                                        blurRadius: 5,
                                        offset:
                                            const Offset(
                                          0,
                                          2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child:
                                      isUploadingAvatar
                                          ? const Padding(
                                              padding:
                                                  EdgeInsets.all(
                                                8,
                                              ),
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth:
                                                    2.5,
                                                color: Colors
                                                    .white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons
                                                  .camera_alt_rounded,
                                              color: Colors
                                                  .white,
                                              size: 20,
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ==================================================
                        // CHANGE PHOTO
                        // ==================================================

                        Center(
                          child:
                              TextButton(
                            onPressed:
                                isUploadingAvatar
                                    ? null
                                    : _selectAvatar,
                            child:
                                const Text(
                              'Change Profile Picture',
                              style:
                                  TextStyle(
                                color: Color(
                                    0xFF2980B9),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // NAME
                        // ==================================================

                        Text(
                          user!.name,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        Text(
                          user!.email,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // STATISTICS
                        // ==================================================

                        const Text(
                          "Learning Statistics",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child:
                                  _statCard(
                                "Score",
                                currentScore
                                    .toString(),
                                Colors.orange,
                                Icons
                                    .star_rounded,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _statCard(
                                "Correct",
                                currentCorrect
                                    .toString(),
                                Colors.green,
                                Icons
                                    .check_circle_rounded,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _statCard(
                                "Wrong",
                                currentWrong
                                    .toString(),
                                Colors.red,
                                Icons
                                    .cancel_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // RANKING
                        // ==================================================

                        if (leaderboardUser !=
                            null)
                          Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets
                                    .all(20),
                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                      0xFFE3F2FD),
                                  Color(
                                      0xFFF1F8FF),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                              border:
                                  Border.all(
                                color: Colors
                                    .blueAccent
                                    .withOpacity(
                                        0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons
                                      .emoji_events_rounded,
                                  size: 42,
                                  color:
                                      Colors.orange,
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                const Text(
                                  "Your Ranking",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        14,
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  "#${leaderboardUser!.rank}",
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        32,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color: Colors
                                        .blueAccent,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  _getRankMessage(
                                    leaderboardUser!
                                        .rank,
                                  ),
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        13,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // ACCOUNT INFORMATION
                        // ==================================================

                        const Text(
                          "Account Information",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(16),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF5F7FA,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                          child: Column(
                            children: [
                              _infoRow(
                                icon: Icons
                                    .person_outline,
                                label: "Name",
                                value:
                                    user!.name,
                              ),

                              const Divider(
                                height: 24,
                              ),

                              _infoRow(
                                icon: Icons
                                    .email_outlined,
                                label: "Email",
                                value:
                                    user!.email,
                              ),

                              const Divider(
                                height: 24,
                              ),

                              _infoRow(
                                icon: Icons
                                    .verified_user_outlined,
                                label:
                                    "Account ID",
                                value:
                                    user!.id,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // LEARNING MESSAGE
                        // ==================================================

                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(16),
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .orange.shade50,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                            border:
                                Border.all(
                              color: Colors
                                  .orange
                                  .shade100,
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Icon(
                                Icons
                                    .lightbulb_outline_rounded,
                                color:
                                    Colors.orange,
                                size: 28,
                              ),

                              SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  "Keep learning and practicing your reading comprehension skills to improve your score and ranking!",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        13,
                                    color: Colors
                                        .black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // LOGOUT
                        // ==================================================

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton
                                  .icon(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors
                                      .redAccent,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                              ),
                            ),
                            onPressed:
                                logout,
                            icon:
                                const Icon(
                              Icons
                                  .logout_rounded,
                            ),
                            label:
                                const Text(
                              "Logout",
                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color:
            color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              color.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blueAccent,
          size: 23,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RANK MESSAGE
  // ============================================================

  String _getRankMessage(
    int rank,
  ) {
    if (rank == 1) {
      return "🏆 You are the top learner!";
    }

    if (rank == 2) {
      return "🥈 Amazing! Keep going!";
    }

    if (rank == 3) {
      return "🥉 Great achievement!";
    }

    if (rank <= 10) {
      return "🌟 You are in the Top 10!";
    }

    return "💪 Keep practicing to climb higher!";
  }
}