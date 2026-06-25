import 'package:flutter/material.dart';
import 'SkillsPage.dart';
import 'PhotosPage.dart';
import 'videosPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _buildNavItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.black : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.black : Colors.grey,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  final List<String> bannerImages = [
    'assets/images/boat.jpg.jpg',
    'assets/images/nature.jpg.jpg',
    'assets/images/mountain.jpg.jpg',
  ];
  int _currentBannerIndex = 0;
  late PageController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        int nextIndex = (_currentBannerIndex + 1) % bannerImages.length;
        if (_bannerController.hasClients) {
          _bannerController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
        _startBannerAutoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 160,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavItem(Icons.home, 'Home', 0),
                const SizedBox(height: 20),
                _buildNavItem(Icons.precision_manufacturing, 'Skills', 1),
                const SizedBox(height: 20),
                _buildNavItem(Icons.photo, 'Photos', 2),
                const SizedBox(height: 20),
                _buildNavItem(Icons.video_library, 'Videos', 3),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  color: Colors.grey,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    _selectedIndex == 0
                        ? 'Home'
                        : _selectedIndex == 1
                        ? 'Skills List'
                        : _selectedIndex == 2
                        ? 'Photos'
                        : 'Videos',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade400,
                    child: _selectedIndex == 0
                        ? _buildHomePage()
                        : _selectedIndex == 1
                        ? const SkillsPage()
                        : _selectedIndex == 2
                        ? const PhotosPage()
                        : const VideosPage(),
                    padding: const EdgeInsets.all(24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _bannerController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
                  },
                  itemCount: bannerImages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              IgnorePointer(
                child: Center(
                  child: Text(
                    'Banner',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
                (index) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == index
                    ? Colors.blue
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build, size: 40, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: 40, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 40, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}