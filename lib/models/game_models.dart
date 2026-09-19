import 'dart:convert';

/// ============================================================
/// GAME TYPE
/// ============================================================

class GameType {
  final int id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;

  GameType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  factory GameType.fromJson(Map<String, dynamic> json) {
    return GameType(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      isActive: _parseBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
    };
  }
}

/// ============================================================
/// LEVEL
/// ============================================================

class GameLevel {
  final int id;
  final String name;
  final int levelOrder;
  final String description;
  final int minScore;
  final bool isActive;

  GameLevel({
    required this.id,
    required this.name,
    required this.levelOrder,
    required this.description,
    required this.minScore,
    required this.isActive,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    return GameLevel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      levelOrder:
          int.tryParse(json['level_order'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      minScore:
          int.tryParse(json['min_score'].toString()) ?? 0,
      isActive: _parseBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level_order': levelOrder,
      'description': description,
      'min_score': minScore,
      'is_active': isActive,
    };
  }
}

/// ============================================================
/// READING SKILL
/// ============================================================

class ReadingSkill {
  final int id;
  final String name;

  ReadingSkill({
    required this.id,
    required this.name,
  });

  factory ReadingSkill.fromJson(Map<String, dynamic> json) {
    return ReadingSkill(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// ============================================================
/// QUESTION OPTION
/// ============================================================

class QuestionOption {
  final int id;
  final String optionText;
  final bool isCorrect;
  final int optionOrder;

  QuestionOption({
    required this.id,
    required this.optionText,
    required this.isCorrect,
    required this.optionOrder,
  });

  factory QuestionOption.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuestionOption(
      id: int.tryParse(json['id'].toString()) ?? 0,
      optionText:
          json['option_text']?.toString() ?? '',
      isCorrect:
          _parseBool(json['is_correct']),
      optionOrder:
          int.tryParse(
                json['option_order'].toString(),
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_text': optionText,
      'is_correct': isCorrect,
      'option_order': optionOrder,
    };
  }
}

/// ============================================================
/// QUESTION PAIR
/// ============================================================

class QuestionPair {
  final int id;
  final String leftText;
  final String rightText;
  final int pairOrder;

  QuestionPair({
    required this.id,
    required this.leftText,
    required this.rightText,
    required this.pairOrder,
  });

  factory QuestionPair.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuestionPair(
      id: int.tryParse(json['id'].toString()) ?? 0,
      leftText:
          json['left_text']?.toString() ?? '',
      rightText:
          json['right_text']?.toString() ?? '',
      pairOrder:
          int.tryParse(
                json['pair_order'].toString(),
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'left_text': leftText,
      'right_text': rightText,
      'pair_order': pairOrder,
    };
  }
}

/// ============================================================
/// GAME QUESTION
/// ============================================================

class GameQuestion {
  final int id;

  final int storyId;
  final String storyTitle;

  final int gameTypeId;
  final String gameType;
  final String gameIcon;

  final int levelId;
  final String level;
  final int levelOrder;

  final int? readingSkillId;
  final String? readingSkill;

  final String questionText;
  final String questionType;

  final String explanation;
  final int points;

  final bool isActive;

  final String createdAt;
  final String updatedAt;

  final List<QuestionOption> options;
  final List<QuestionPair> pairs;

  GameQuestion({
    required this.id,
    required this.storyId,
    required this.storyTitle,
    required this.gameTypeId,
    required this.gameType,
    required this.gameIcon,
    required this.levelId,
    required this.level,
    required this.levelOrder,
    required this.readingSkillId,
    required this.readingSkill,
    required this.questionText,
    required this.questionType,
    required this.explanation,
    required this.points,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
    required this.pairs,
  });

  factory GameQuestion.fromJson(
    Map<String, dynamic> json,
  ) {
    final optionsJson = json['options'];
    final pairsJson = json['pairs'];

    return GameQuestion(
      id: int.tryParse(json['id'].toString()) ?? 0,

      storyId:
          int.tryParse(
                json['story_id'].toString(),
              ) ??
              0,

      storyTitle:
          json['story_title']?.toString() ?? '',

      gameTypeId:
          int.tryParse(
                json['game_type_id'].toString(),
              ) ??
              0,

      gameType:
          json['game_type']?.toString() ?? '',

      gameIcon:
          json['game_icon']?.toString() ?? '',

      levelId:
          int.tryParse(
                json['level_id'].toString(),
              ) ??
              0,

      level:
          json['level']?.toString() ?? '',

      levelOrder:
          int.tryParse(
                json['level_order'].toString(),
              ) ??
              0,

      readingSkillId:
          json['reading_skill_id'] == null
              ? null
              : int.tryParse(
                  json['reading_skill_id'].toString(),
                ),

      readingSkill:
          json['reading_skill'] == null
              ? null
              : json['reading_skill'].toString(),

      questionText:
          json['question_text']?.toString() ?? '',

      questionType:
          json['question_type']?.toString() ?? '',

      explanation:
          json['explanation']?.toString() ?? '',

      points:
          int.tryParse(
                json['points'].toString(),
              ) ??
              0,

      isActive:
          _parseBool(json['is_active']),

      createdAt:
          json['created_at']?.toString() ?? '',

      updatedAt:
          json['updated_at']?.toString() ?? '',

      options:
          optionsJson is List
              ? optionsJson
                  .map(
                    (item) =>
                        QuestionOption.fromJson(
                      Map<String, dynamic>.from(
                        item,
                      ),
                    ),
                  )
                  .toList()
              : [],

      pairs:
          pairsJson is List
              ? pairsJson
                  .map(
                    (item) =>
                        QuestionPair.fromJson(
                      Map<String, dynamic>.from(
                        item,
                      ),
                    ),
                  )
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'story_id': storyId,
      'story_title': storyTitle,
      'game_type_id': gameTypeId,
      'game_type': gameType,
      'game_icon': gameIcon,
      'level_id': levelId,
      'level': level,
      'level_order': levelOrder,
      'reading_skill_id': readingSkillId,
      'reading_skill': readingSkill,
      'question_text': questionText,
      'question_type': questionType,
      'explanation': explanation,
      'points': points,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'options':
          options.map((item) => item.toJson()).toList(),
      'pairs':
          pairs.map((item) => item.toJson()).toList(),
    };
  }
}

/// ============================================================
/// GAME RESULT REQUEST
/// ============================================================

class GameResultRequest {
  final String userId;
  final int storyId;
  final int gameTypeId;
  final int levelId;
  final int score;
  final int correct;
  final int wrong;
  final int totalQuestions;
  final double percentage;

  GameResultRequest({
    required this.userId,
    required this.storyId,
    required this.gameTypeId,
    required this.levelId,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.totalQuestions,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'story_id': storyId,
      'game_type_id': gameTypeId,
      'level_id': levelId,
      'score': score,
      'correct': correct,
      'wrong': wrong,
      'total_questions': totalQuestions,
      'percentage': percentage,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

/// ============================================================
/// NEXT LEVEL
/// ============================================================

class NextLevel {
  final int levelId;
  final String name;
  final int levelOrder;
  final String description;
  final int minScore;
  final bool isUnlocked;

  const NextLevel({
    required this.levelId,
    required this.name,
    required this.levelOrder,
    required this.description,
    required this.minScore,
    required this.isUnlocked,
  });

  factory NextLevel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NextLevel(
      levelId:
          int.tryParse(
                json['level_id']?.toString() ??
                    json['id']?.toString() ??
                    '0',
              ) ??
              0,

      name:
          json['name']?.toString() ?? '',

      levelOrder:
          int.tryParse(
                json['level_order']?.toString() ??
                    '0',
              ) ??
              0,

      description:
          json['description']?.toString() ?? '',

      minScore:
          int.tryParse(
                json['min_score']?.toString() ??
                    '0',
              ) ??
              0,

      isUnlocked:
          _parseBool(
            json['is_unlocked'] ??
                json['unlocked'],
          ),
    );
  }
}

/// ============================================================
/// GAME RESULT RESPONSE
/// ============================================================

class GameResult {
  final int resultId;
  final String userId;

  final int storyId;
  final String storyTitle;

  final int gameTypeId;
  final String gameTypeName;

  final int levelId;
  final String levelName;
  final int levelOrder;

  final int score;
  final int correct;
  final int wrong;
  final int totalQuestions;
  final double percentage;

  /// Level berikutnya yang berhasil dibuka.
  ///
  /// Null jika:
  /// - user belum lulus
  /// - level sekarang adalah Master
  /// - API tidak mengirim next_level
  final NextLevel? nextLevel;

  GameResult({
    required this.resultId,
    required this.userId,
    required this.storyId,
    required this.storyTitle,
    required this.gameTypeId,
    required this.gameTypeName,
    required this.levelId,
    required this.levelName,
    required this.levelOrder,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.totalQuestions,
    required this.percentage,
    this.nextLevel,
  });

  factory GameResult.fromJson(
    Map<String, dynamic> json,
  ) {
    // ----------------------------------------------------------
    // SUPPORT FLAT RESPONSE
    // ----------------------------------------------------------

    Map<String, dynamic> source = json;

    // ----------------------------------------------------------
    // SUPPORT NESTED "result"
    // ----------------------------------------------------------

    if (json['result'] is Map) {
      source = {
        ...json,
        ...Map<String, dynamic>.from(
          json['result'],
        ),
      };
    }

    // ----------------------------------------------------------
    // STORY
    // ----------------------------------------------------------

    final story =
        source['story'] is Map
            ? Map<String, dynamic>.from(
                source['story'],
              )
            : <String, dynamic>{};

    // ----------------------------------------------------------
    // GAME TYPE
    // ----------------------------------------------------------

    final gameType =
        source['game_type'] is Map
            ? Map<String, dynamic>.from(
                source['game_type'],
              )
            : <String, dynamic>{};

    // ----------------------------------------------------------
    // LEVEL
    // ----------------------------------------------------------

    final level =
        source['level'] is Map
            ? Map<String, dynamic>.from(
                source['level'],
              )
            : <String, dynamic>{};

    // ----------------------------------------------------------
    // NEXT LEVEL
    // ----------------------------------------------------------

    NextLevel? nextLevel;

    if (json['next_level'] is Map) {
      nextLevel = NextLevel.fromJson(
        Map<String, dynamic>.from(
          json['next_level'],
        ),
      );
    }

    // ----------------------------------------------------------
    // BUILD RESULT
    // ----------------------------------------------------------

    return GameResult(
      resultId:
          int.tryParse(
                source['result_id']?.toString() ??
                    source['id']?.toString() ??
                    '0',
              ) ??
              0,

      userId:
          source['user_id']?.toString() ?? '',

      storyId:
          int.tryParse(
                story['id']?.toString() ??
                    source['story_id']?.toString() ??
                    '0',
              ) ??
              0,

      storyTitle:
          story['title']?.toString() ??
              source['story_title']?.toString() ??
              '',

      gameTypeId:
          int.tryParse(
                gameType['id']?.toString() ??
                    source['game_type_id']?.toString() ??
                    '0',
              ) ??
              0,

      gameTypeName:
          gameType['name']?.toString() ??
              source['game_type_name']?.toString() ??
              '',

      levelId:
          int.tryParse(
                level['id']?.toString() ??
                    source['level_id']?.toString() ??
                    '0',
              ) ??
              0,

      levelName:
          level['name']?.toString() ??
              source['level_name']?.toString() ??
              '',

      levelOrder:
          int.tryParse(
                level['level_order']?.toString() ??
                    source['level_order']?.toString() ??
                    '0',
              ) ??
              0,

      score:
          int.tryParse(
                source['score']?.toString() ?? '0',
              ) ??
              0,

      correct:
          int.tryParse(
                source['correct']?.toString() ?? '0',
              ) ??
              0,

      wrong:
          int.tryParse(
                source['wrong']?.toString() ?? '0',
              ) ??
              0,

      totalQuestions:
          int.tryParse(
                source['total_questions']
                        ?.toString() ??
                    '0',
              ) ??
              0,

      percentage:
          double.tryParse(
                source['percentage']?.toString() ??
                    '0',
              ) ??
              0.0,

      nextLevel: nextLevel,
    );
  }
}

/// ============================================================
/// LEADERBOARD ITEM
/// ============================================================

class LeaderboardItem {
  final int rank;
  final String userId;
  final String name;
  final int score;
  final int correct;
  final int wrong;

  LeaderboardItem({
    required this.rank,
    required this.userId,
    required this.name,
    required this.score,
    required this.correct,
    required this.wrong,
  });

  factory LeaderboardItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return LeaderboardItem(
      rank:
          int.tryParse(
                json['rank'].toString(),
              ) ??
              0,

      userId:
          json['user_id']?.toString() ?? '',

      name:
          json['name']?.toString() ?? '',

      score:
          int.tryParse(
                json['score'].toString(),
              ) ??
              0,

      correct:
          int.tryParse(
                json['correct'].toString(),
              ) ??
              0,

      wrong:
          int.tryParse(
                json['wrong'].toString(),
              ) ??
              0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'name': name,
      'score': score,
      'correct': correct,
      'wrong': wrong,
    };
  }
}

/// ============================================================
/// HELPER BOOLEAN
/// ============================================================

bool _parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is int) {
    return value == 1;
  }

  if (value is String) {
    return value == '1' ||
        value.toLowerCase() == 'true';
  }

  return false;
}