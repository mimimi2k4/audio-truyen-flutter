import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/category.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class StoryService extends ChangeNotifier {
  List<Story> _stories = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Story> get stories => _stories;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchStories({int? categoryId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String endpoint = ApiConstants.stories;
      if (categoryId != null) {
        endpoint += '?categoryId=$categoryId';
      }
      
      final response = await ApiService.get(endpoint, auth: false);
      if (response['success'] == true) {
        _stories = (response['data'] as List)
            .map((json) => Story.fromJson(json))
            .toList();
      }
    } catch (e) {
      _stories = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Story>> searchStories(String keyword) async {
    try {
      final response = await ApiService.get(
        '${ApiConstants.searchStories}?keyword=$keyword',
        auth: false,
      );
      if (response['success'] == true) {
        return (response['data'] as List)
            .map((json) => Story.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  Future<Story?> getStoryDetail(int id) async {
    try {
      final response = await ApiService.get(
        ApiConstants.storyDetail(id),
        auth: false,
      );
      if (response['success'] == true) {
        return Story.fromJson(response['data']);
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.get(ApiConstants.categories, auth: false);
      if (response['success'] == true) {
        _categories = (response['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _categories = [];
    }
  }
}
