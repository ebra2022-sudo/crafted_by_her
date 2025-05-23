import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'avatar.dart';
import 'score_to_rating_stars.dart';

class ReviewCard extends StatelessWidget {
  final double ratingScore;
  final String userName;
  final String avatarImageUrl;
  final String date;
  final String comment;
  final String seeMoreText;

  const ReviewCard({
    required this.ratingScore,
    required this.userName,
    required this.avatarImageUrl,
    required this.date,
    required this.comment,
    this.seeMoreText = 'Show more',
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSeeMoreEnabled = comment.split('\n').length > 2;

    return Container(
      width: double.infinity,
      height: 150,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AvatarProfile(avatarUrl: ''),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.15),
                      ),
                      const SizedBox(height: 4),
                      RatingDisplay(rating: ratingScore)
                    ],
                  )
                ],
              ),
              const SizedBox(width: 16),
              Text(
                comment,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF191D23),
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
