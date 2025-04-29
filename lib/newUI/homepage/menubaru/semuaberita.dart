import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SemuaBeritaPage extends StatefulWidget {
  final List<Map<String, dynamic>> instagramPosts;
  final List<Map<String, dynamic>> kabarWargaPosts;
  final List<Map<String, dynamic>> MadiunTodayPosts;

  const SemuaBeritaPage({
    Key? key,
    required this.instagramPosts,
    required this.kabarWargaPosts,
    required this.MadiunTodayPosts,
  }) : super(key: key);

  @override
  _SemuaBeritaPageState createState() => _SemuaBeritaPageState();
}

class _SemuaBeritaPageState extends State<SemuaBeritaPage>
    with TickerProviderStateMixin {
  final int _itemsPerPage = 7;

  int _currentPageInstagram = 1;
  int _currentPageKabarWarga = 1;
  int _currentPageMadiunToday = 1;

  int getTotalPages(int itemCount) {
    return (itemCount / _itemsPerPage).ceil();
  }

  List<Map<String, dynamic>> getPaginatedPosts(
      List<Map<String, dynamic>> posts, int currentPage) {
    final start = (currentPage - 1) * _itemsPerPage;
    final end = (currentPage) * _itemsPerPage;
    return posts.sublist(
      start,
      end > posts.length ? posts.length : end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 33, 72, 122),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(186, 141, 86, 15),
                  blurRadius: 4,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Color.fromARGB(15, 226, 156, 50).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              indicatorSize: TabBarIndicatorSize.tab, // agar selebar tab
              indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6), // tambah lebar & tinggi
              dividerColor: Colors.white.withOpacity(0.0),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Kabar Warga'),
                Tab(text: 'Instagram'),
                Tab(text: 'MadiunToday'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBeritaList(widget.kabarWargaPosts, 'Kabar Warga',
                    _currentPageKabarWarga, onPageChanged: (page) {
                  setState(() {
                    _currentPageKabarWarga = page;
                  });
                }),
                _buildBeritaList(
                    widget.instagramPosts, 'Instagram', _currentPageInstagram,
                    onPageChanged: (page) {
                  setState(() {
                    _currentPageInstagram = page;
                  });
                }),
                _buildBeritaList(widget.MadiunTodayPosts, 'madiuntoday.id',
                    _currentPageMadiunToday, onPageChanged: (page) {
                  setState(() {
                    _currentPageMadiunToday = page;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaList(
      List<Map<String, dynamic>> allPosts, String label, int currentPage,
      {required Function(int) onPageChanged}) {
    if (allPosts.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada berita dari $label.',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    final paginatedPosts = getPaginatedPosts(allPosts, currentPage);
    final totalPages = getTotalPages(allPosts.length);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: paginatedPosts.length,
            itemBuilder: (context, index) {
              final post = paginatedPosts[index];
              return Card(
                color: Colors.white.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: post['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 40),
                  title: Text(
                    post['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(label),
                  onTap: () async {
                    final url = post['url'];
                    if (url != null && url.toString().isNotEmpty) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(currentPage, totalPages, onPageChanged),
      ],
    );
  }

  Widget _buildPaginationControls(
      int currentPage, int totalPages, Function(int) onPageChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 6,
        children: List.generate(totalPages, (index) {
          final page = index + 1;
          return GestureDetector(
            onTap: () => onPageChanged(page),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: currentPage == page ? Colors.white : Colors.white54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  color: currentPage == page
                      ? Colors.black
                      : Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
