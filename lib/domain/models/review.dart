class ReviewModel {
  final String name;
  final double rating;
  final String reviewText;
  final String date;
  final String? avatarUrl;

  ReviewModel({
    required this.name,
    required this.rating,
    required this.reviewText,
    required this.date,
    this.avatarUrl,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['reviewText'] as String,
      date: json['date'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rating': rating,
      'reviewText': reviewText,
      'date': date,
      'avatarUrl': avatarUrl,
    };
  }
}
