import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/playlistvideo.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<Map<String, dynamic>> playlists = [];
  bool isLoading = true;
  static String youtubeApiKey = "";
  static String youtubeChannelId = "";
  late Timer _timerPlaying;

  // Tambahan state
  String? selectedPlaylistId;
  String? selectedPlaylistTitle;

  @override
  void initState() {
    super.initState();
    fetchDataAndUpdateVariablesFromFirebase();
    _timerPlaying = Timer.periodic(const Duration(seconds: 40), (timer) async {
      final data = await fetchDataFromFirebase();

      final firebaseYoutubeApiKey = data['youtubeApiKey'];
      final firebaseYoutubeChannelId = data['youtubeChannelId'];

      if (firebaseYoutubeApiKey != null &&
          firebaseYoutubeChannelId != null &&
          (firebaseYoutubeApiKey != youtubeApiKey ||
              firebaseYoutubeChannelId != youtubeChannelId)) {
        youtubeApiKey = firebaseYoutubeApiKey;
        youtubeChannelId = firebaseYoutubeChannelId;

        print('🔁 Data Firebase diupdate!');
        print('YouTube API Key baru: $youtubeApiKey');
        print('YouTube Channel ID baru: $youtubeChannelId');

        // Panggil ulang fetch playlist setelah perubahan
        await fetchYouTubePlaylists();
      } else {
        print('📡 Tidak ada perubahan data Firebase.');
        print('YouTube API Key baru: $youtubeApiKey');
        print('YouTube Channel ID baru: $youtubeChannelId');
      }
    });
  }

  Future<Map<String, dynamic>> fetchDataFromFirebase() async {
    try {
      final response = await http.get(Uri.parse(
          'https://live--suara-madiun-default-rtdb.firebaseio.com/.json'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data from Firebase');
      }
    } catch (error) {
      print('Error fetching data from Firebase: $error');
      rethrow;
    }
  }

  Future<void> fetchDataAndUpdateVariablesFromFirebase() async {
    try {
      final data = await fetchDataFromFirebase();

      final firebaseYoutubeApiKey = data['youtubeApiKey'];
      final firebaseYoutubeChannelId = data['youtubeChannelId'];

      if (firebaseYoutubeApiKey != null && firebaseYoutubeChannelId != null) {
        // Simpan ke variabel class agar bisa digunakan global
        youtubeApiKey = firebaseYoutubeApiKey;
        youtubeChannelId = firebaseYoutubeChannelId;

        print('✅ Data YouTube berhasil disimpan');
        print('YouTube API Key firebase: $youtubeApiKey');
        print('YouTube Channel ID firebase: $youtubeChannelId');

        // Setelah berhasil ambil dan set, panggil fetch playlist
        fetchYouTubePlaylists();
      } else {
        print('❌ youtubeApiKey atau youtubeChannelId dari Firebase null');
      }
    } catch (error) {
      print('Error fetching data from Firebase: $error');
    }
  }

  Future<void> fetchYouTubePlaylists() async {
    if (youtubeApiKey.isEmpty || youtubeChannelId.isEmpty) {
      print('❌ API Key atau Channel ID kosong!');
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> allPlaylists = [];
    String? nextPageToken;

    try {
      do {
        final url =
            'https://www.googleapis.com/youtube/v3/playlists?part=snippet,contentDetails&channelId=$youtubeChannelId&maxResults=50&pageToken=${nextPageToken ?? ''}&key=$youtubeApiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final items = data['items'] ?? [];
          allPlaylists.addAll(List<Map<String, dynamic>>.from(items.map((item) {
            return {
              'title': item['snippet']['title'],
              'thumbnail': item['snippet']['thumbnails']['medium']['url'],
              'videoCount': item['contentDetails']['itemCount'],
              'playlistId': item['id'],
            };
          })));

          nextPageToken = data['nextPageToken'];
        } else {
          throw Exception('Gagal memuat playlist');
        }
      } while (nextPageToken != null);

      setState(() {
        playlists = allPlaylists;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timerPlaying.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = MediaQuery.of(context).size.width * 0.04;
    // Ambil ukuran layar
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Jika user memilih playlist, tampilkan daftar videonya di bawah ini
    if (selectedPlaylistId != null && selectedPlaylistTitle != null) {
      return PlaylistVideoListPage(
        playlistId: selectedPlaylistId!,
        playlistTitle: selectedPlaylistTitle!,
        youtubeApiKey: youtubeApiKey,
        onBack: () {
          setState(() {
            selectedPlaylistId = null;
            selectedPlaylistTitle = null;
          });
        },
      );
    }

    // Jika belum memilih, tampilkan daftar playlist
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 20),
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: paddingHorizontal * 2,
          //     vertical: 20, // Tambahkan padding vertikal untuk menambah tinggi
          //   ),
          //   decoration: BoxDecoration(
          //     color: Color.fromARGB(255, 33, 72, 122),
          //     borderRadius: BorderRadius.circular(24),
          //     boxShadow: const [
          //       BoxShadow(
          //         color: Color.fromARGB(186, 141, 86, 15),
          //         blurRadius: 4,
          //         offset: Offset(0, 0),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Padding(
          //           padding: EdgeInsets.only(left: 8.0),
          //           child: Center(
          //             child: Text(
          //               'Playlist',
          //               style: TextStyle(
          //                 color: Colors.white,
          //                 fontSize: screenWidth * 0.06, // font responsif
          //                 fontWeight: FontWeight.w600,
          //               ),
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPlaylistId = playlist['playlistId'];
                            selectedPlaylistTitle = playlist['title'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  playlist['thumbnail'],
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  playlist['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '${playlist['videoCount']} video',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
