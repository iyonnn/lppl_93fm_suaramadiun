// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lppl_93fm_suara_madiun/newUI/constants/constant.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/berita_berita.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/bottom%20navigation.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/menu_menu.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/playlist.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/program_unggulan.dart';
import 'package:lppl_93fm_suara_madiun/newUI/homepage/menubaru/semuaberita.dart';
import 'package:lppl_93fm_suara_madiun/newUI/radioscreen.dart';

class HomePage2 extends StatefulWidget {
  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  static const instagramFeedUrl =
      'https://rss.app/feeds/v1.1/oBYCZ1GV2crnFf21.json';

  static const kabarWargaUrl =
      'https://kominfo.madiunkota.go.id/api/berita/getKabarWarga';

  List<Map<String, dynamic>> _instagramPosts = [];
  List<Map<String, dynamic>> _kabarWarga = [];
  List<Map<String, dynamic>> _MadiunTodayPosts = [];

  bool _isLoadingPosts = false;
  String profileLink = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllPosts();
  }

  Future<void> _loadAllPosts() async {
    setState(() => _isLoadingPosts = true);
    final instagramData = await _fetchInstagramPosts();
    if (mounted) setState(() => _instagramPosts = instagramData);

    await _fetchKabarWargaAPI();
    await _fetchMadiunTodayAPI();

    if (mounted) setState(() => _isLoadingPosts = false);
  }

  Future<List<Map<String, dynamic>>> _fetchInstagramPosts() async {
    try {
      final response = await http.get(Uri.parse(instagramFeedUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        profileLink = data['home_page_url'] ?? "";

        return (data['items'] as List)
            .map<Map<String, dynamic>>((post) => {
                  'title': post['title'],
                  'description': post['attachments'] ?? '',
                  'url': post['url'],
                  'image': (post['attachments'] != null &&
                          post['attachments'].isNotEmpty)
                      ? post['attachments'][0]['url']
                      : null,
                })
            .toList();
      } else {
        debugPrint('Failed to fetch Instagram posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Instagram posts: $e');
    }
    return [];
  }

  Future<void> _fetchKabarWargaAPI() async {
    try {
      final response = await http.post(
        Uri.parse(kabarWargaUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password1,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)['data'] as List;

        final posts = data.reversed
            .map((item) => {
                  'title': item['judul'],
                  'description': item['content'],
                  'url': item['link'],
                  'image': item['gambar'],
                })
            .toList();

        if (mounted) setState(() => _kabarWarga = posts);
      } else {
        debugPrint('Gagal memuat Kabar Warga: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Kabar Warga: $e');
    }
  }

  Future<void> _fetchMadiunTodayAPI() async {
    try {
      final response = await http.post(
        Uri.parse('https://MadiunToday.id/api/berita/semua'),
        headers: {
          'passcode': passcode2, // Kalau butuh token
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body)['data'] as List;

        final posts = data
            .map((item) => {
                  'title': item['slug'] ??
                      'No Title', // Menggunakan 'title' dari JSON
                  'description': item['content'] ??
                      'No Description', // Menggunakan 'content' dari JSON
                  'url': item['link'] ?? 'No link',
                  'image': item['thumbnail'] ??
                      '', // Menggunakan 'gambar' untuk URL gambar
                })
            .toList();

        if (mounted) setState(() => _MadiunTodayPosts = posts);
      } else {
        debugPrint('Gagal memuat berita MadiunToday: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching MadiunToday: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = MediaQuery.of(context).size.width * 0.04;
    final radioScreenHeight = 62.0; // Misalnya, tinggi RadioScreen

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/bglppl.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: SafeArea(
              child: Stack(
                children: [
                  const Positioned(
                    top: 1, // Tempatkan RadioScreen di bagian atas
                    left: 0,
                    right: 0,
                    child: RadioScreen(), // Audio player di bagian atas
                  ),
                  Positioned(
                    top:
                        radioScreenHeight, // Konten utama dimulai setelah RadioScreen
                    left: 0,
                    right: 0,
                    bottom: 0, // Mengisi sisa ruang di bawah
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _getSelectedPage(), // Konten yang berubah-ubah
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      shrinkWrap: true,
      children: [
        // const SizedBox(height: 20),
        const Text(
          "Menu",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        MenuPage(),
        const SizedBox(height: 20),
        ProgramUnggulanSection(),
        const SizedBox(height: 20),
        BeritaSection(
          instagramPosts: _instagramPosts,
          kabarWargaPosts: _kabarWarga,
          MadiunTodayPosts: _MadiunTodayPosts,
          onSeeAll: () => setState(() => _selectedIndex = 2),
        ),
      ],
    );
  }

  Widget _buildSemuaBeritaContent() {
    return SemuaBeritaPage(
      instagramPosts: _instagramPosts,
      kabarWargaPosts: _kabarWarga,
      MadiunTodayPosts: _MadiunTodayPosts,
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return PlaylistPage();
      case 2:
        return _buildSemuaBeritaContent();
      default:
        return _buildHomeContent();
    }
  }
}
