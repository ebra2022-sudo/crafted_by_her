import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
  final String imagePath;

  const BannerWidget({
    super.key,
    required this.imagePath,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        // Image with semi-transparent white overlay
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/hero_image.png', // Fallback placeholder image
                      fit: BoxFit.cover,
                    );
                  },
                ),

                // Semi-transparent white overlay
                Container(
                  color: Colors.white
                      .withValues(alpha: 0.5), // White with 50% opacity
                ),
              ],
            ),
          ),
        ),
        // Text overlay
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Crafted by Her',
                      style: TextStyle(
                          fontFamily: 'DMSerif',
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 242, 92, 5)),
                    ),
                    TextSpan(
                      text: ', Loved by You',
                      style: TextStyle(
                          fontFamily: 'DMSerif',
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text:
                          '\nCelebrate handmade creations by women across Ethiopia.',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
