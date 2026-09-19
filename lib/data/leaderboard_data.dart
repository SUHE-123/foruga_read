import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String name;
  int score;
  int correct;
  int wrong;

  LeaderboardEntry({
    required this.name,
    required this.score,
    required this.correct,
    required this.wrong,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "score": score,
        "correct": correct,
        "wrong": wrong,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json["name"],
      score: json["score"],
      correct: json["correct"],
      wrong: json["wrong"],
    );
  }
}

// Default dummy data
List<LeaderboardEntry> leaderboard = [
  LeaderboardEntry(name: "Andi", score: 70, correct: 7, wrong: 3),
  LeaderboardEntry(name: "Siti", score: 80, correct: 8, wrong: 2),
  LeaderboardEntry(name: "Budi", score: 60, correct: 6, wrong: 4),
];

const String _storageKey = "leaderboard_data";

// ================= SAVE =================
Future<void> saveLeaderboard() async {
  final prefs = await SharedPreferences.getInstance();

  final jsonData = leaderboard.map((e) => e.toJson()).toList();
  prefs.setString(_storageKey, jsonEncode(jsonData));
}

// ================= LOAD =================
Future<void> loadLeaderboard() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString(_storageKey);

  if (data != null) {
    final List decoded = jsonDecode(data);
    leaderboard = decoded
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList()
        .cast<LeaderboardEntry>();
  }
}

// ================= UPDATE =================
Future<void> updatePlayerResult({
  required String name,
  required int score,
  required int correct,
  required int wrong,
}) async {
  final index = leaderboard.indexWhere((e) => e.name == name);

  if (index != -1) {
    leaderboard[index].score = score;
    leaderboard[index].correct = correct;
    leaderboard[index].wrong = wrong;
  } else {
    leaderboard.add(
      LeaderboardEntry(
        name: name,
        score: score,
        correct: correct,
        wrong: wrong,
      ),
    );
  }

  leaderboard.sort((a, b) => b.score.compareTo(a.score));

  await saveLeaderboard();
}
