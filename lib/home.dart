// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, must_call_super, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unnecessary_null_comparison, prefer_is_empty, sized_box_for_whitespace, unused_local_variable, no_leading_underscores_for_local_identifiers
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePlayer extends StatefulWidget {
  @override
  _HomePlayerState createState() => _HomePlayerState();
}

class _HomePlayerState extends State<HomePlayer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static String url = "https://play-93fm.madiunkota.go.id/live";

  final player = AudioPlayer();
  var duration;
  var position;
  List<double> audioSamples = []; // Data sampel audio
  static const int MAX_SAMPLES = 44100; // Ubah nilai sesuai kebutuhan Anda

  late List<Map<String, dynamic>> _instagramPosts;
  late String profileLink = ""; // Deklarasikan profileLink di sini
  late bool _isLoadingPosts;
  bool _isAudioPlaying = false;

  final List<Color> colors = [
    Colors.red[900]!,
    Colors.green[900]!,
    Colors.blue[900]!,
    Colors.brown[900]!
  ];
  var phoneNumber = 'tel:+6285748630511';

  var urlWa =
      'https://wa.me/+6281556451817/?text=${Uri.encodeFull('Halo Radio Suara Madiun !')}';

  final List<int> visDurasi = [900, 700, 600, 800, 500];
  final _controller = SiriWaveController(); // Menambahkan SiriWaveController

  @override
  void initState() {
    super.initState();
    SetUriPlay();
    playAudio();
    // SystemChrome.setEnabledSystemUIOverlays([]); // Hide the system status bar

    // Fetch Instagram RSS feed
    _fetchInstagramPosts().then((instagramPosts) {
      setState(() {
        _instagramPosts = instagramPosts;
      });
    }).catchError((error) {
      print('Error fetching Instagram posts: $error');
    });
  }

  @override
  void dispose() {
    player.dispose();
    SystemChrome.setEnabledSystemUIOverlays(
        SystemUiOverlay.values); // Show the system status bar
    super.dispose();
  }

  void loadAudioSamples() {
    final audioPlayer = player;

    // Pastikan audio player tidak null
    if (audioPlayer != null) {
      // Dapatkan stream posisi yang di-buffer dari audio player
      final bufferedPositionStream = audioPlayer.bufferedPositionStream;

      // Mendengarkan perubahan dalam stream posisi yang di-buffer
      bufferedPositionStream.listen((bufferedPosition) {
        // Lakukan sesuatu dengan bufferedPosition, misalnya konversi ke sampel audio
        // Kemudian tambahkan ke daftar sampel audio
        setState(() {
          // Tambahkan sampel audio ke dalam daftar
          audioSamples.add(bufferedPosition.inMilliseconds.toDouble());

          // Atau, Anda mungkin ingin membatasi jumlah sampel yang disimpan untuk mencegah memori berlebihan
          if (audioSamples.length > MAX_SAMPLES) {
            audioSamples.removeAt(
                0); // Hapus sampel tertua jika jumlah sampel melebihi batas maksimum
          }
        });
      });
    }
  }

  Future<void> launchInstagramProfile(Uri profileLink) async {
    if (await launchUrl(profileLink)) {
    } else {
      throw 'Could not launch $profileLink';
    }
  }

  Future<void> launchWa(Uri noWa) async {
    if (await launchUrl(noWa)) {
    } else {
      throw 'Could not launch $noWa';
    }
  }

  Future<List<Map<String, dynamic>>> _fetchInstagramPosts() async {
    setState(() {
      _isLoadingPosts =
          true; // Set _isLoadingPosts menjadi true saat proses pengambilan data dimulai
    });

    try {
      final response = await http
          .get(Uri.parse('https://rss.app/feeds/v1.1/oBYCZ1GV2crnFf21.json'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String profileLinkIcon = responseData['home_page_url'];
        final List<Map<String, dynamic>> instagramPosts =
            List<Map<String, dynamic>>.from(responseData['items']);

        // Simpan profileLinkIcon ke dalam variabel profileLink yang telah dideklarasikan
        profileLink = profileLinkIcon;

        return instagramPosts;
      } else {
        throw Exception('Failed to load Instagram posts');
      }
    } catch (error) {
      print('Error fetching Instagram posts: $error');
      return []; // Atau handle error sesuai kebutuhan
    } finally {
      setState(() {
        _isLoadingPosts =
            false; // Set _isLoadingPosts menjadi false setelah proses pengambilan data selesai
      });
    }
  }

  void updateVisualPosition(Duration bufferPosition) {
    setState(() {});
  }

  double calculateVisualPosition(Duration bufferPosition) {
    return bufferPosition.inMilliseconds.toDouble();
  }

  void setWaveAmplitude(double volume) {
    // Map nilai volume dari rentang 0-1 ke rentang 0-100
    var amplitudeValue = volume * 100;
    _controller
        .setAmplitude(amplitudeValue); // Gunakan controller yang disediakan
  }

  Future<void> SetUriPlay() async {
    duration = await player.setUrl(url);
  }

  Future<void> playAudio() async {
    if (!_isAudioPlaying) {
      // Periksa apakah audio tidak sedang diputar
      await player.play();
      setState(() {
        _isAudioPlaying = true; // Atur status pemutaran audio menjadi true
      });
    }
  }

  void stopAudio() {
    if (_isAudioPlaying) {
      // Periksa apakah audio sedang diputar
      player.stop();
      setState(() {
        _isAudioPlaying = false; // Atur status pemutaran audio menjadi false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/img/bglppl.jpg"),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffDFEAFE), Color(0xffECF5FC)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Image.asset(
                    "assets/img/logopemkotxradio.png",
                    width: 150,
                    height: 80,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              child: _isLoadingPosts
                  ? Center(child: CircularProgressIndicator())
                  : _instagramPosts == null || _instagramPosts.isEmpty
                      ? Center(child: Text('No Instagram posts available'))
                      : buildInstagramCarousel(size, _instagramPosts),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: IconButton(
                        iconSize: 30,
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        onPressed: () {
                          launchInstagramProfile(Uri.parse(profileLink));
                        },
                        icon: Icon(FontAwesomeIcons.instagram),
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://www.youtube.com/@93fmlpplradiosuaramadiun76"));
                      },
                      icon: Icon(FontAwesomeIcons.youtube),
                    ),
                    SizedBox(width: 5),
                    IconButton(
                      iconSize: 30,
                      padding: EdgeInsets.zero,
                      color: Colors.white,
                      onPressed: () {
                        launchUrl(Uri.parse(urlWa));
                      },
                      icon: Icon(FontAwesomeIcons.whatsapp),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 35),
                  child: IconButton(
                    iconSize: 25,
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    onPressed: () {
                      launchUrl(Uri.parse(phoneNumber));
                    },
                    icon: Icon(FontAwesomeIcons.phoneVolume),
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: AudioPlayerWidget(
                player: player,
                audioSamples: audioSamples,
                updateVisualPosition: updateVisualPosition,
                isPlaying:
                    _isAudioPlaying, // Pass the audio playing status to AudioPlayerWidget
                playAudio:
                    playAudio, // Pass the playAudio method to AudioPlayerWidget
                stopAudio:
                    stopAudio, // Pass the stopAudio method to AudioPlayerWidget
              ),
            ),
            SizedBox(height: 80),
            Image.asset("assets/img/follow.png",
                width: 200, fit: BoxFit.fitHeight // Penyesuaian ukuran gambar
                ),
            SizedBox(
                height: size.height *
                    0.01), // Mengatur jarak antara gambar dan widget berikutnya
          ],
        ),
      ),
    );
  }

  Widget buildInstagramCarousel(
      Size size, List<Map<String, dynamic>> instagramPosts) {
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: size.width,
        height: size.height,
        child: CarouselSlider.builder(
          itemCount: instagramPosts.length,
          itemBuilder: (context, index, realIndex) {
            final post = instagramPosts[index];
            final imageUrl = post['attachments'][0]['url'];
            final caption = post['content_text'];
            final profileLink = post['url'];

            return Container(
              width: size.width,
              height: size.height,
              child: InstagramCard(
                imageUrl: imageUrl,
                caption: caption,
                profileLink: profileLink,
              ),
            );
          },
          options: CarouselOptions(
            height: double.infinity,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
          ),
        ),
      ),
    );
  }
}

class InstagramCard extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final String profileLink;

  InstagramCard({
    required this.imageUrl,
    required this.caption,
    required this.profileLink,
  });

  void launchInstagramProfile(Uri profileLink) async {
    if (await launchUrl(profileLink)) {
      // Berhasil membuka tautan
    } else {
      // Gagal membuka tautan
      throw 'Could not launch $profileLink';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        if (profileLink.isNotEmpty) {
          // tambahkan pengecekan ini
          launchInstagramProfile(Uri.parse(profileLink));
          print("url $profileLink");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20),
                bottomRight:
                    Radius.circular(20)), // Menambahkan efek lengkungan
          ),
          child: Container(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  width: size.width,
                  height: size.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        20.0), // Menambahkan efek lengkungan
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fitWidth,
                      width: size.width,
                      height: size.height,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final List<double> audioSamples;
  final void Function(Duration) updateVisualPosition;
  final bool isPlaying; // Tambahkan properti untuk status pemutaran audio
  final VoidCallback playAudio; // Tambahkan properti untuk metode playAudio
  final VoidCallback stopAudio; // Tambahkan properti untuk metode stopAudio

  AudioPlayerWidget({
    Key? key,
    required this.player,
    required this.audioSamples,
    required this.updateVisualPosition,
    required this.isPlaying,
    required this.playAudio,
    required this.stopAudio,
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late SiriWaveController _controller;
  double _amplitude = 0.0;
  bool _isPlaying = false;

  void _updateAmplitude(double amplitude) {
    setState(() {
      _amplitude = amplitude;
      _controller.setAmplitude(_amplitude);
    });
  }

  void _togglePlayback() async {
    if (_isPlaying) {
      widget.stopAudio(); // Stop audio if it's playing
      setState(() {
        _isPlaying = false; // Update playback status
      });
    } else {
      widget.playAudio(); // Start audio if it's not playing
      setState(() {
        _isPlaying = true; // Update playback status
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = SiriWaveController();

    widget.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed ||
          playerState.processingState == ProcessingState.idle) {
        setState(() {
          _isPlaying = false;
          _updateAmplitude(0.0);
        });
      } else if (playerState.processingState == ProcessingState.ready ||
          playerState.processingState == ProcessingState.buffering ||
          playerState.processingState == ProcessingState.ready) {
        setState(() {
          _isPlaying = true;
          _updateAmplitude(1.0);
        });
      }
    });
  }

  @override
  void dispose() {
    widget.player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: SiriWave(
              controller: _controller,
              style: SiriWaveStyle.ios_9,
              options: SiriWaveOptions(
                height: kIsWeb ? 300 : 180,
                width: kIsWeb ? 600 : 360,
                showSupportBar: true,
                backgroundColor: Colors.black,
              ),
            ),
          ),
          Container(
            height: size.height * 0.1,
            padding: const EdgeInsets.only(top: 0.0),
            child: ElevatedButton(
              onPressed: () {
                if (_isPlaying) {
                  widget.player.stop(); // Stop audio if it's playing
                } else {
                  widget.player.play(); // Start audio if it's not playing
                }
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                elevation: 5,
                padding: EdgeInsets.all(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _isPlaying
                    ? Icon(
                        Icons.stop,
                        size: 50,
                      )
                    : Icon(
                        Icons.play_circle_filled,
                        size: 50,
                      ),
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
        ],
      ),
    );
  }
}
