class Episode {
  final int id;
  final int storyId;
  final String title;
  final String audioUrl;
  final int? duration;
  final int episodeNumber;

  Episode({
    required this.id,
    required this.storyId,
    required this.title,
    required this.audioUrl,
    this.duration,
    required this.episodeNumber,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      storyId: json['storyId'],
      title: json['title'],
      audioUrl: json['audioUrl'],
      duration: json['duration'],
      episodeNumber: json['episodeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'title': title,
      'audioUrl': audioUrl,
      'duration': duration,
      'episodeNumber': episodeNumber,
    };
  }

  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
