import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_models.dart';
import '../models/game_progress.dart';
import 'package:flutter/foundation.dart';

class GameService {
  static const String baseUrl =
      "https://api.sightsavers.id/api/games";

  // ============================================================
  // GET GAME TYPES
  // ============================================================

  static Future<List<GameType>> getGameTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/types.php'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load game types: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Failed to load game types.',
      );
    }

    final List<dynamic> data =
        result['data'] ?? [];

    return data
        .map(
          (item) => GameType.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET LEVELS
  // ============================================================

  static Future<List<GameLevel>> getLevels() async {
    final response = await http.get(
      Uri.parse('$baseUrl/levels.php'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load levels: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Failed to load levels.',
      );
    }

    final List<dynamic> data =
        result['data'] ?? [];

    return data
        .map(
          (item) => GameLevel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET USER PROGRESS
  // ============================================================

  static Future<UserProgress> getUserProgress({
    required String userId,
    required int storyId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/progress.php',
    ).replace(
      queryParameters: {
        'user_id': userId,
        'story_id': storyId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load user progress: '
        '${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ??
            'Failed to load user progress.',
      );
    }

    final data = result['data'];

    if (data == null || data is! Map) {
      throw Exception(
        'Invalid user progress data.',
      );
    }

    return UserProgress.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // GET QUESTIONS
  // ============================================================

  static Future<List<GameQuestion>> getQuestions({
    int? storyId,
    int? gameTypeId,
    int? levelId,
    int? readingSkillId,
  }) async {
    final Map<String, String> parameters = {};

    if (storyId != null) {
      parameters['story_id'] =
          storyId.toString();
    }

    if (gameTypeId != null) {
      parameters['game_type_id'] =
          gameTypeId.toString();
    }

    if (levelId != null) {
      parameters['level_id'] =
          levelId.toString();
    }

    if (readingSkillId != null) {
      parameters['reading_skill_id'] =
          readingSkillId.toString();
    }

    final uri = Uri.parse(
      '$baseUrl/questions.php',
    ).replace(
      queryParameters:
          parameters.isEmpty ? null : parameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load questions: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Failed to load questions.',
      );
    }

    final List<dynamic> data =
        result['data'] ?? [];

    return data
        .map(
          (item) => GameQuestion.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET QUESTIONS FOR SPECIFIC GAME
  // ============================================================

  static Future<List<GameQuestion>> getGameQuestions({
    required int storyId,
    required int gameTypeId,
    required int levelId,
    int? readingSkillId,
  }) async {
    return getQuestions(
      storyId: storyId,
      gameTypeId: gameTypeId,
      levelId: levelId,
      readingSkillId: readingSkillId,
    );
  }

  // ============================================================
  // SUBMIT GAME RESULT
  // ============================================================

  static Future<GameResult> submitResult({
    required String userId,
    required int storyId,
    required int gameTypeId,
    required int levelId,
    required int score,
    required int correct,
    required int wrong,
    required int totalQuestions,
    required double percentage,
  }) async {
    // ----------------------------------------------------------
    // REQUEST
    // ----------------------------------------------------------

    final request = GameResultRequest(
      userId: userId,
      storyId: storyId,
      gameTypeId: gameTypeId,
      levelId: levelId,
      score: score,
      correct: correct,
      wrong: wrong,
      totalQuestions: totalQuestions,
      percentage: percentage,
    );

    // ----------------------------------------------------------
    // SEND REQUEST
    // ----------------------------------------------------------

    final response = await http.post(
      Uri.parse('$baseUrl/result.php'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: request.toJsonString(),
    );

    // ----------------------------------------------------------
    // HTTP ERROR
    // ----------------------------------------------------------

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to submit game result: '
        '${response.statusCode}',
      );
    }

    // ----------------------------------------------------------
    // DECODE RESPONSE
    // ----------------------------------------------------------

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    // ----------------------------------------------------------
    // API ERROR
    // ----------------------------------------------------------

    if (result['success'] != true) {
      throw Exception(
        result['message'] ??
            'Failed to submit game result.',
      );
    }

    // ----------------------------------------------------------
    // VALIDATE DATA
    // ----------------------------------------------------------

    final data = result['data'];

    if (data == null || data is! Map) {
      throw Exception(
        'Invalid game result data.',
      );
    }

    final Map<String, dynamic> resultData =
        Map<String, dynamic>.from(data);

    // ----------------------------------------------------------
    // DEBUG RESPONSE
    // ----------------------------------------------------------

    debugPrint('========================================');
    debugPrint('GAME RESULT API RESPONSE');
    debugPrint(
      const JsonEncoder.withIndent('  ')
          .convert(resultData),
    );
    debugPrint('========================================');

    // ----------------------------------------------------------
    // PARSE GAME RESULT
    // ----------------------------------------------------------

    final gameResult = GameResult.fromJson(
      resultData,
    );

    // ----------------------------------------------------------
    // DEBUG NEXT LEVEL
    // ----------------------------------------------------------

    if (gameResult.nextLevel != null) {
      debugPrint('========================================');
      debugPrint('NEXT LEVEL AVAILABLE');
      debugPrint(
        'Level ID    : '
        '${gameResult.nextLevel!.levelId}',
      );
      debugPrint(
        'Level Name  : '
        '${gameResult.nextLevel!.name}',
      );
      debugPrint(
        'Level Order : '
        '${gameResult.nextLevel!.levelOrder}',
      );
      debugPrint(
        'Unlocked    : '
        '${gameResult.nextLevel!.isUnlocked}',
      );
      debugPrint('========================================');
    } else {
      debugPrint('========================================');
      debugPrint('NO NEXT LEVEL');
      debugPrint('========================================');
    }

    return gameResult;
  }

  // ============================================================
  // GET LEADERBOARD
  // ============================================================

  static Future<List<LeaderboardItem>>
      getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard.php'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load leaderboard: '
        '${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ??
            'Failed to load leaderboard.',
      );
    }

    final List<dynamic> data =
        result['data'] ?? [];

    return data
        .map(
          (item) => LeaderboardItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}