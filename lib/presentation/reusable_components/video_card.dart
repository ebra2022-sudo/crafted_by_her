import 'dart:convert';
import 'package:crafted_by_her/presentation/reusable_components/section_item_grid.dart';
import 'package:crafted_by_her/presentation/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YouTubeVideoCard extends StatelessWidget {
  final String youtubeUrl;
  final String videoTitle;
  final String videoDuration;

  const YouTubeVideoCard({
    super.key,
    required this.youtubeUrl,
    required this.videoTitle,
    required this.videoDuration,
  });

  String _getThumbnailUrl(String url) {
    final videoId = Uri.parse(url).queryParameters['v'];
    return "https://img.youtube.com/vi/$videoId/0.jpg";
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = _getThumbnailUrl(youtubeUrl);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoLink: youtubeUrl,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight;
            final imageHeight =
                cardHeight * 0.7; // Image takes 65% of card height

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          thumbnailUrl,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              height: imageHeight,
                              child:
                                  const Center(child: Icon(Icons.broken_image)),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            videoDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        videoTitle,
                        style: const TextStyle(
                          fontFamily: 'DMSerif',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ]);
          },
        ),
      ),
    );
  }
}

/// Fetches YouTube video details: title, thumbnail, and duration.
Future<Map<String, String>> fetchYouTubeVideoDetails(
    String videoUrl, String apiKey) async {
  try {
    final uri = Uri.parse(videoUrl);
    final videoId = uri.queryParameters['v'];

    if (videoId == null || videoId.isEmpty) {
      throw Exception("Invalid YouTube URL: missing video ID.");
    }

    final apiUrl = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos'
      '?part=snippet,contentDetails'
      '&id=$videoId'
      '&key=$apiKey',
    );

    final response = await http.get(apiUrl);
    if (response.statusCode != 200)
      throw Exception('Failed to load video details');

    final data = jsonDecode(response.body);
    final items = data['items'] as List;

    if (items.isEmpty) throw Exception("No video found for the provided ID.");

    final item = items[0];
    final title = item['snippet']['title'];
    final durationISO = item['contentDetails']['duration'];

    return {
      'title': title as String,
      'duration': _convertIsoDurationToMinutes(durationISO as String),
    };
  } catch (e) {
    print("Error fetching video details: $e");
    return {
      'title': 'Unavailable',
      'duration': '0:00',
    };
  }
}

String _convertIsoDurationToMinutes(String isoDuration) {
  final regex = RegExp(r'PT(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(isoDuration);

  if (match != null) {
    final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
  return '0:00';
}
