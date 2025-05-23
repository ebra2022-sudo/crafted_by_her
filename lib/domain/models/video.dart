class Video {
  final String title;
  final String thumbnailUrl;
  final String channel;
  final String views;
  final String date;

  Video({
    required this.title,
    required this.thumbnailUrl,
    required this.channel,
    required this.views,
    required this.date,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      views: json['views'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }
}
