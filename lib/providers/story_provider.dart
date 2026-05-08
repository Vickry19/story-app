import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/api_service.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  List<Story> stories = [];

  int page = 1;

  bool loading = false;
  bool hasMore = true;

  String? errorMessage;

  static const int pageSize = 10;

  Future<void> fetchStories(String token) async {
    if (loading || !hasMore) return;

    if (loading) return;

    loading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final newStories = await apiService.getStories(token, page);

      if (newStories.isEmpty) {
        hasMore = false;
      } else {
        stories.addAll(newStories);

        if (newStories.length < pageSize) {
          hasMore = false;
        }

        page++;
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    loading = false;

    notifyListeners();
  }

  Future<void> refresh(String token) async {
    stories = [];

    page = 1;

    hasMore = true;

    errorMessage = null;

    notifyListeners();

    await fetchStories(token);
  }
}
