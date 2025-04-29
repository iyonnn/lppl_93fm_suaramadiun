import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:lppl_93fm_suara_madiun/newUI/radioscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
     RadioScreen(),
    const PodcastScreen(),
    const HomeScreen(), // Pindah Home ke tengah sesuai ikon navbar
    const NewsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4462),
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 37, 113, 172),
        buttonBackgroundColor: Colors.orange,
        height: 60,
        index: _currentIndex,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          Icon(Icons.radio, color: Colors.white),
          Icon(Icons.podcasts, color: Colors.white),
          Icon(Icons.chat_outlined, color: Colors.white, size: 30),
          Icon(Icons.article, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Youtube Stream")),
      body: const Center(
        child: Text(
          "Youtube Stream Page",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Podcast")),
      body: const Center(
        child: Text(
          "Podcast Page",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("News")),
      body: const Center(
        child: Text(
          "News Page",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(
        child: Text(
          "Profile Page",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
