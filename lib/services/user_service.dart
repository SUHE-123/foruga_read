import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  String id;
  String name;
  String email;
  String password;
  int score;
  int correct;
  int wrong;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.score = 0,
    this.correct = 0,
    this.wrong = 0,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "score": score,
        "correct": correct,
        "wrong": wrong,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        score: json["score"],
        correct: json["correct"],
        wrong: json["wrong"],
      );
}

class UserService {
  static const _usersKey = "users";
  static const _currentUserKey = "current_user";

  // ================= REGISTER =================
  static Future<bool> register(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    // Cek email sudah ada
    if (users.any((u) => u.email == email)) {
      return false;
    }

    final newUser = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
    );

    users.add(newUser);

    prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );

    return true;
  }

  // ================= LOGIN =================
  static Future<UserModel?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();

    try {
      final user =
          users.firstWhere((u) => u.email == email && u.password == password);

      prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      return null;
    }
  }

  // ================= GET CURRENT USER =================
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_currentUserKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  // ================= UPDATE USER STATS =================
  static Future<void> updateStats(int score, int correct, int wrong) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    final current = await getCurrentUser();

    if (current == null) return;

    final index = users.indexWhere((u) => u.id == current.id);
    if (index == -1) return;

    users[index].score += score;
    users[index].correct += correct;
    users[index].wrong += wrong;

    prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );

    prefs.setString(_currentUserKey, jsonEncode(users[index].toJson()));
  }

  // ================= GET ALL USERS =================
  static Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_usersKey);

    if (data == null) return [];

    final list = jsonDecode(data) as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_currentUserKey);
  }
}
