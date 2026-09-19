import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionUser {
  final String id;
  final String name;
  final String email;
  final int score;
  final int correct;
  final int wrong;

  const SessionUser({
    required this.id,
    required this.name,
    required this.email,
    required this.score,
    required this.correct,
    required this.wrong,
  });

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      score: _toInt(json["score"]),
      correct: _toInt(json["correct"]),
      wrong: _toInt(json["wrong"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "score": score,
      "correct": correct,
      "wrong": wrong,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? "0") ?? 0;
  }
}

class SessionService {
  static const String _sessionKey = "foruga_session";

  // ============================================================
  // SAVE SESSION
  // ============================================================

  static Future<void> saveSession(
    SessionUser user,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _sessionKey,
      jsonEncode(user.toJson()),
    );
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  static Future<SessionUser?> getCurrentUser() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data = prefs.getString(_sessionKey);

    if (data == null || data.isEmpty) {
      return null;
    }

    try {
      final json = jsonDecode(data);

      if (json is! Map<String, dynamic>) {
        return null;
      }

      return SessionUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();

    return user != null && user.id.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> clearSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_sessionKey);
  }

  // ============================================================
  // UPDATE SESSION USER
  // ============================================================

  static Future<void> updateSession({
    String? name,
    String? email,
    int? score,
    int? correct,
    int? wrong,
  }) async {
    final current = await getCurrentUser();

    if (current == null) {
      return;
    }

    final updatedUser = SessionUser(
      id: current.id,
      name: name ?? current.name,
      email: email ?? current.email,
      score: score ?? current.score,
      correct: correct ?? current.correct,
      wrong: wrong ?? current.wrong,
    );

    await saveSession(updatedUser);
  }
}