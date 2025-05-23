import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double starSize;

  const RatingDisplay({
    required this.rating,
    this.starSize = 17.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    double halfStar = rating - fullStars >= 0.25 ? 0.5 : 0.0;
    int emptyStars = 5 - fullStars - (halfStar > 0 ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
            fullStars, (index) => Flexible(child: _buildStar(true, starSize))),
        if (halfStar > 0) Flexible(child: _buildHalfStar(starSize)),
        ...List.generate(emptyStars,
            (index) => Flexible(child: _buildStar(false, starSize))),
      ],
    );
  }

  Widget _buildStar(bool isFilled, double size) {
    return Icon(
      isFilled ? Icons.star : Icons.star_border,
      color: isFilled ? Colors.yellow[700] : Colors.grey[400],
      size: size,
    );
  }

  Widget _buildHalfStar(double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_half,
          color: Colors.yellow[700],
          size: size,
        ),
      ],
    );
  }
}
