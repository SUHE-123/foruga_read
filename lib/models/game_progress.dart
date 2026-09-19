class UserProgress {
  final String userId;
  final String userName;
  final int storyId;
  final String storyTitle;
  final List<LevelProgress> levels;

  const UserProgress({
    required this.userId,
    required this.userName,
    required this.storyId,
    required this.storyTitle,
    required this.levels,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    final story = json['story'] is Map
        ? Map<String, dynamic>.from(json['story'])
        : <String, dynamic>{};

    final levelsData = json['levels'] is List
        ? json['levels'] as List
        : <dynamic>[];

    return UserProgress(
      userId: user['id']?.toString() ?? '',
      userName: user['name']?.toString() ?? '',
      storyId: _toInt(story['id']),
      storyTitle: story['title']?.toString() ?? '',
      levels: levelsData
          .whereType<Map>()
          .map(
            (item) => LevelProgress.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  LevelProgress? getLevel(int levelId) {
    for (final level in levels) {
      if (level.levelId == levelId) {
        return level;
      }
    }

    return null;
  }

  LevelProgress? getNextLevel(int currentLevelId) {
    final current = getLevel(currentLevelId);

    if (current == null) {
      return null;
    }

    final nextOrder = current.levelOrder + 1;

    for (final level in levels) {
      if (level.levelOrder == nextOrder) {
        return level;
      }
    }

    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }
}


class LevelProgress {
  final int levelId;
  final String name;
  final int levelOrder;
  final String description;
  final int minScore;

  final double progressPercentage;
  final bool completed;
  final int lastScore;
  final bool isUnlocked;

  const LevelProgress({
    required this.levelId,
    required this.name,
    required this.levelOrder,
    required this.description,
    required this.minScore,
    required this.progressPercentage,
    required this.completed,
    required this.lastScore,
    required this.isUnlocked,
  });

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelId: _toInt(json['level_id']),
      name: json['name']?.toString() ?? '',
      levelOrder: _toInt(json['level_order']),
      description: json['description']?.toString() ?? '',
      minScore: _toInt(json['min_score']),
      progressPercentage: _toDouble(
        json['progress_percentage'],
      ),
      completed: _toBool(json['completed']),
      lastScore: _toInt(json['last_score']),
      isUnlocked: _toBool(json['is_unlocked']),
    );
  }

  bool get isLocked => !isUnlocked;

  bool get isPassed => completed || progressPercentage >= 70;

  String get status {
    if (completed) {
      return 'Completed';
    }

    if (isUnlocked) {
      return 'Unlocked';
    }

    return 'Locked';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '0',
        ) ??
        0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    if (value is int) {
      return value == 1;
    }

    final text = value?.toString().toLowerCase() ?? '';

    return text == '1' ||
        text == 'true' ||
        text == 'yes';
  }
}