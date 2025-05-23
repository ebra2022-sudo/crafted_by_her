class Rating {
  final String userId;
  final String userEmail;
  final String fullName;
  final String? profilePhoto;
  final double score;
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.userId,
    required this.userEmail,
    required this.fullName,
    this.profilePhoto,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    try {
      return Rating(
        userId: json['userId']?.toString() ?? '', // Handle userId as a string
        userEmail: json['userEmail']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        profilePhoto: json['profilePhoto'] as String?,
        score: double.tryParse(json['score']?.toString() ?? '0') ?? 0.0,
        comment: json['comment']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    } catch (e) {
      print('Error parsing rating JSON: $e');
      print('Rating JSON: $json');
      rethrow;
    }
  }
}
