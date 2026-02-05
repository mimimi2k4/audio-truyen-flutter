import 'episode.dart';

class Story {
  final int id;
  final String title;
  final String? description;
  final String? author;
  final int? categoryId;
  final String? categoryName;
  final List<String> images;
  final List<Episode> episodes;
  final int episodeCount;

  Story({
    required this.id,
    required this.title,
    this.description,
    this.author,
    this.categoryId,
    this.categoryName,
    this.images = const [],
    this.episodes = const [],
    this.episodeCount = 0,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      episodes: json['episodes'] != null
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList()
          : [],
      episodeCount: json['episodeCount'] ?? 0,
    );
  }

  String get coverImage => images.isNotEmpty ? images.first : '';
}
