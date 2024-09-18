import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;

  const StarRating({required this.rating, this.starCount = 5});

  @override
  Widget build(BuildContext context) {
    int filledStars = rating.round();
    int emptyStars = starCount - filledStars;

    return Row(
      children: List.generate(
            filledStars,
            (index) => const Icon(
              Icons.star,
              color: Colors.yellow,
              size: 20.0,
            ),
          ) +
          List.generate(
            emptyStars,
            (index) => const Icon(
              Icons.star_border,
              color: Colors.yellow,
              size: 20.0,
            ),
          ),
    );
  }
}
