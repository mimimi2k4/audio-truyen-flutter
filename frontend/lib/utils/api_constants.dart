class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8081'; // Android emulator
  // static const String baseUrl = 'http://localhost:8081'; // iOS/Web
  
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  
  // User endpoints
  static const String profile = '/api/users/profile';
  static const String updateProfile = '/api/users/profile';
  static const String changePassword = '/api/users/password';
  static const String uploadAvatar = '/api/users/avatar';
  
  // Story endpoints
  static const String stories = '/api/stories';
  static const String searchStories = '/api/stories/search';
  
  // Category endpoints
  static const String categories = '/api/categories';
  
  // Favorite endpoints
  static const String favorites = '/api/favorites';
  
  // Admin endpoints
  static const String adminUsers = '/api/admin/users';
  static const String adminCategories = '/api/admin/categories';
  static const String adminStories = '/api/admin/stories';
  static const String adminEpisodes = '/api/admin/episodes';
  static const String adminUploadImage = '/api/admin/upload/image';
  static const String adminUploadAudio = '/api/admin/upload/audio';
  
  static String storyDetail(int id) => '/api/stories/$id';
  static String storyEpisodes(int storyId) => '/api/stories/$storyId/episodes';
  static String addFavorite(int storyId) => '/api/favorites/$storyId';
  static String removeFavorite(int storyId) => '/api/favorites/$storyId';
  static String checkFavorite(int storyId) => '/api/favorites/$storyId/check';
  static String adminStoryEpisodes(int storyId) => '/api/admin/stories/$storyId/episodes';
}
