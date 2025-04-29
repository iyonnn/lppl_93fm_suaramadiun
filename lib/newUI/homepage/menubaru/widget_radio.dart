import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';

class LiveBroadcastButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const LiveBroadcastButton({
    super.key,
    required this.isPlaying,
    required this.onPlay,
    required this.onStop,
  });

  @override
  State<LiveBroadcastButton> createState() => _LiveBroadcastButtonState();
}

class _LiveBroadcastButtonState extends State<LiveBroadcastButton>
    with SingleTickerProviderStateMixin {
  String _nowPlayingTitle = '';
  late Timer _timerPlaying;

  Future<void> fetchNowPlayingTitle() async {
    try {
      final response = await http
          .get(Uri.parse('https://play-93fm.madiunkota.go.id/status-json.xsl'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final source = data['icestats']['source'];
        String title;

        if (source is List && source.length > 1) {
          title = source[1]?['title'] ?? 'Live Broadcast';
        } else if (source is Map) {
          title = source['title'] ?? 'Live Broadcast';
        } else {
          title = 'Live Broadcast';
        }

        setState(() {
          _nowPlayingTitle = title;
        });
      } else {
        throw Exception('Failed to fetch now playing title');
      }
    } catch (error) {
      print('Error Pengambilan Data title: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    fetchNowPlayingTitle();
    _timerPlaying = Timer.periodic(const Duration(seconds: 40), (timer) {
      fetchNowPlayingTitle();
      print('=====UPDATE NowPlaying=====');
    });
  }

  @override
  void dispose() {
    _timerPlaying.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil ukuran layar
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        if (widget.isPlaying) {
          widget.onStop();
        } else {
          widget.onPlay();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.015), // padding minimalis
        decoration: BoxDecoration(
          color: Color.fromARGB(
              255, 33, 72, 122), // Warna solid untuk kesan modern
          borderRadius: BorderRadius.circular(12), // Sudut tumpul
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Play/Stop yang responsif dan minimalis
            Icon(
              widget.isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.amber.shade700,
              size: screenWidth * 0.06, // ukuran icon lebih kecil
            ),
            SizedBox(
                width: screenWidth * 0.03), // Spasi kecil antar ikon dan teks
            Expanded(
              child: SizedBox(
                height: screenHeight * 0.03, // tinggi responsif
                child: Marquee(
                  text: " ${_nowPlayingTitle}",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // Ukuran font responsif
                    fontWeight: FontWeight.w500, // Berat font lebih ringan
                    color: Colors.amber.shade700,
                  ),
                  blankSpace: 50,
                  velocity: 40,
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  showFadingOnlyWhenScrolling: true,
                  fadingEdgeStartFraction: 0.1,
                  fadingEdgeEndFraction: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
