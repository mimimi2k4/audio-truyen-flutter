import 'package:flutter/material.dart';
import '../models/story.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class FavoriteService extends ChangeNotifier {
  List<Story> _favorites = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;

  List<Story> get favorites => _favorites;
  bool get isLoading => _isLoading;

  bool isFavorite(int storyId) => _favoriteIds.contains(storyId);

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConstants.favorites);
      if (response['success'] == true) {
        _favorites = (response['data'] as List)
            .map((json) => Story.fromJson(json))
            .toList();
        _favoriteIds = _favorites.map((s) => s.id).toSet();
      }
    } catch (e) {
      _favorites = [];
      _favoriteIds = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkFavorite(int storyId) async {
    try {
      final response = await ApiService.get(ApiConstants.checkFavorite(storyId));
      if (response['success'] == true) {
        final isFav = response['data'] == true;
        if (isFav) {
          _favoriteIds.add(storyId);
        } else {
          _favoriteIds.remove(storyId);
        }
        notifyListeners();
        return isFav;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<void> addFavorite(int storyId) async {
    try {
      final response = await ApiService.post(
        ApiConstants.addFavorite(storyId),
        {},
      );
      if (response['success'] == true) {
        _favoriteIds.add(storyId);
        await fetchFavorites();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(int storyId) async {
    try {
      final response = await ApiService.delete(
        ApiConstants.removeFavorite(storyId),
      );
      if (response['success'] == true) {
        _favoriteIds.remove(storyId);
        _favorites.removeWhere((s) => s.id == storyId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavorite(int storyId) async {
    if (isFavorite(storyId)) {
      await removeFavorite(storyId);
    } else {
      await addFavorite(storyId);
    }
  }
}
