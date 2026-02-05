import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    final userData = prefs.getString('user');
    if (userData != null) {
      try {
        _user = User.fromJson(Map<String, dynamic>.from(
          Uri.splitQueryString(userData).map((key, value) => MapEntry(key, value))
        ));
      } catch (_) {}
    }
    
    if (_token != null) {
      await fetchProfile();
    }
    
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiConstants.login,
        {'email': email, 'password': password},
        auth: false,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        await ApiService.saveToken(_token!);
        
        // Create user from auth response
        _user = User(
          id: data['userId'],
          email: data['email'],
          name: data['name'],
          role: data['role'],
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['userId'].toString());
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiConstants.register,
        {'name': name, 'email': email, 'password': password},
        auth: false,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _token = data['token'];
        await ApiService.saveToken(_token!);
        
        _user = User(
          id: data['userId'],
          email: data['email'],
          name: data['name'],
          role: data['role'],
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchProfile() async {
    try {
      final response = await ApiService.get(ApiConstants.profile);
      if (response['success'] == true) {
        _user = User.fromJson(response['data']);
        notifyListeners();
      }
    } catch (e) {
      // Token might be invalid
      await logout();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    DateTime? birthday,
    String? gender,
    String? address,
  }) async {
    final response = await ApiService.put(
      ApiConstants.updateProfile,
      {
        'name': name ?? _user?.name,
        'phone': phone ?? _user?.phone,
        'birthday': birthday?.toIso8601String().split('T')[0] ?? _user?.birthday?.toIso8601String().split('T')[0],
        'gender': gender ?? _user?.gender,
        'address': address ?? _user?.address,
      },
    );

    if (response['success'] == true) {
      _user = User.fromJson(response['data']);
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await ApiService.put(
      ApiConstants.changePassword,
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<String?> uploadAvatar(String filePath) async {
    final response = await ApiService.uploadFile(
      ApiConstants.uploadAvatar,
      filePath,
      'file',
    );

    if (response['success'] == true) {
      await fetchProfile();
      return response['data'];
    }
    return null;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await ApiService.clearToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
