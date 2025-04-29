import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlaylistVideoListPage extends StatefulWidget {
  final String playlistId;
  final String playlistTitle;
  final String youtubeApiKey;
  final VoidCallback? onBack; // Tambahan

  const PlaylistVideoListPage({
    super.key,
    required this.playlistId,
    required this.playlistTitle,
    required this.youtubeApiKey,
    this.onBack,
  });

  @override
  State<PlaylistVideoListPage> createState() => _PlaylistVideoListPageState();
}

class _PlaylistVideoListPageState extends State<PlaylistVideoListPage> {
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  YoutubePlayerController? _youtubePlayerController;
  String? _selectedVideoId;

  @override
  void initState() {
    super.initState();

    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: '',
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    fetchPlaylistVideos();
  }

  Future<void> fetchPlaylistVideos() async {
    String baseUrl =
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=${widget.playlistId}&maxResults=50&key=${widget.youtubeApiKey}';

    List<Map<String, dynamic>> allVideos = [];
    String? nextPageToken;

    try {
      do {
        final url = nextPageToken == null
            ? baseUrl
            : '$baseUrl&pageToken=$nextPageToken';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['items'] != null) {
            allVideos.addAll(
                List<Map<String, dynamic>>.from(data['items'].map((item) {
              return {
                'title': item['snippet']['title'],
                'thumbnail': item['snippet']['thumbnails']['medium']['url'],
                'videoId': item['snippet']['resourceId']['videoId'],
              };
            })));
          }
          nextPageToken = data['nextPageToken'];
        } else {
          throw Exception('Failed to fetch videos');
        }
      } while (nextPageToken != null);

      setState(() {
        videos = allVideos;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _youtubePlayerController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = MediaQuery.of(context).size.width * 0.04;

    return SafeArea(
      child: Column(
        children: [
          // Bagian header dengan background transparan atau blur
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal * 1,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 33, 72, 122),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(186, 141, 86, 15),
                  blurRadius: 4,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tombol back mepet kiri
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 0), // pastikan tidak ada margin kiri
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.playlistTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ), /////////.
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Hanya tampil jika ada video dipilih
          if (_selectedVideoId != null && _youtubePlayerController != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: YoutubePlayerIFrame(
                controller: _youtubePlayerController!,
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: paddingHorizontal),
                    child: ListView.separated(
                      itemCount: videos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVideoId = video['videoId'];
                              _youtubePlayerController?.load(_selectedVideoId!);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    video['thumbnail'],
                                    width: 120,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      video['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
