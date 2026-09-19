import 'dart:convert';
import 'package:http/http.dart' as http;

class Story {
  final int id;
  final String title;
  final String image;
  final String pdfFile;
  final String description;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Story({
    required this.id,
    required this.title,
    required this.image,
    required this.pdfFile,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      pdfFile: json['pdf_file'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'].toString() == '1',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class StoryService {
  static const String baseUrl =
      "https://api.sightsavers.id/api/stories";

  // ==========================================
  // GET ALL STORIES
  // ==========================================

  static Future<List<Story>> getStories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/index.php'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load stories: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Failed to load stories',
      );
    }

    final List<dynamic> data = result['data'] ?? [];

    return data
        .map(
          (item) => Story.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ==========================================
  // GET STORY DETAIL
  // ==========================================

  static Future<Story> getStoryDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/show.php?id=$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load story: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> result =
        jsonDecode(response.body);

    if (result['success'] != true) {
      throw Exception(
        result['message'] ?? 'Story not found',
      );
    }

    return Story.fromJson(
      result['data'] as Map<String, dynamic>,
    );
  }
}