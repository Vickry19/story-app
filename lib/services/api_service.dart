import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class ApiService {
  static const baseUrl = "https://story-api.dicoding.dev/v1";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {"email": email, "password": password},
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse("$baseUrl/register"),
            body: {"name": name, "email": email, "password": password},
          )
          .timeout(const Duration(seconds: 10));

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      return jsonDecode(res.body);
    } catch (e) {
      print("ERROR: $e");
      return {"error": true, "message": e.toString()};
    }
  }

  Future<List<Story>> getStories(String token, int page) async {
    final response = await http.get(
      Uri.parse('https://story-api.dicoding.dev/v1/stories?page=$page&size=10'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    return (data['listStory'] as List).map((e) => Story.fromJson(e)).toList();
  }
}
