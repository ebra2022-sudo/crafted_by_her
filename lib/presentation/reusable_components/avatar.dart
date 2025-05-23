import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarProfile extends StatelessWidget {
  final String? avatarUrl; // Made nullable to handle null cases
  final double avatarSize;
  final Widget? fallback; // Optional fallback widget

  const AvatarProfile({
    super.key,
    this.avatarUrl,
    this.avatarSize = 40.0,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: _buildAvatarContent(context),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    // If avatarUrl is null, empty, or invalid, show fallback or placeholder
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return fallback ??
          Image.asset(
            'assets/images/profile_palceholder.jpg',
            fit: BoxFit.cover,
            width: avatarSize,
            height: avatarSize,
          );
    }

    // Validate URL
    try {
      final uri = Uri.parse(avatarUrl!);
      if (!uri.isAbsolute || !uri.hasAuthority) {
        return fallback ??
            Image.asset(
              'assets/images/profile_palceholder.jpg',
              fit: BoxFit.cover,
              width: avatarSize,
              height: avatarSize,
            );
      }

      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
        placeholder: (context, url) => Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/profile_palceholder.jpg',
              fit: BoxFit.cover,
              width: avatarSize,
              height: avatarSize,
            ),
            const CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ],
        ),
        errorWidget: (context, url, error) {
          print('Error loading avatar: $error, URL: $avatarUrl');
          return fallback ??
              Image.asset(
                'assets/images/profile_palceholder.jpg',
                fit: BoxFit.cover,
                width: avatarSize,
                height: avatarSize,
              );
        },
        // Cache images for 7 days
        memCacheWidth:
            (avatarSize * MediaQuery.of(context).devicePixelRatio).toInt(),
        memCacheHeight:
            (avatarSize * MediaQuery.of(context).devicePixelRatio).toInt(),
      );
    } catch (e) {
      print('Error parsing avatar URL: $e, URL: $avatarUrl');
      return fallback ??
          Image.asset(
            'assets/images/profile_palceholder.jpg',
            fit: BoxFit.cover,
            width: avatarSize,
            height: avatarSize,
          );
    }
  }
}
