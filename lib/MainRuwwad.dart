import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newproject/LoginPage.dart';
import 'package:provider/provider.dart';
import 'LoginPage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ============================================================
// THEME PROVIDER
// ============================================================
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// ============================================================
// MESSAGE PROVIDER
// ============================================================
class MessageProvider extends ChangeNotifier {
  String _currentMessage = "type something";
  final List<String> _favorites = [];
  String _username = "";
  int _userAge = 0;

  String get currentMessage => _currentMessage;
  List<String> get favorites => _favorites;
  String get username => _username;
  int get userAge => _userAge;
  int get favoriteCount => _favorites.length;

  bool isFavorite(String message) => _favorites.contains(message);

  void updateMessage(String message) {
    _currentMessage = message;
    notifyListeners();
  }

  void addToFavorites(String message) {
    if (!_favorites.contains(message) && message != "type something") {
      _favorites.add(message);
      notifyListeners();
    }
  }

  void removeFromFavorites(String message) {
    _favorites.remove(message);
    notifyListeners();
  }

  void clearAllFavorites() {
    _favorites.clear();
    notifyListeners();
  }

  void setUserInfo(String name, int age) {
    _username = name;
    _userAge = age;
    notifyListeners();
  }
}

// ============================================================
// MAIN APP WIDGET
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "Welcome to my Forth task",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

// ============================================================
// ALBUM MODEL
// ============================================================
class Album {
  final int userId;
  final int id;
  final String title;

  const Album({required this.userId, required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

// ============================================================
// RESPONSIVE HELPER
// ============================================================
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1000;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1000;
}

// ============================================================
// SILVER EXAMPLE 1: Custom Scroll View with Silver App Bar
// This creates a beautiful scrolling header that expands/collapses
// ============================================================
class SilverRuwwad extends StatelessWidget {
  const SilverRuwwad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: Colors.purple,
            foregroundColor: Colors.blueGrey.shade100,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Ruwwad list',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple.shade200, Colors.blue.shade400],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.eighteen_mp,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          // Add some content to scroll
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Text('$index'),
                ),
                title: Text('Item number $index'),
                subtitle: const Text('Scroll to see the silver effect!'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
class SilverScrollExample extends StatelessWidget {
  const SilverScrollExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Silver App Bar with flexible space for parallax effect
          SliverAppBar(
            expandedHeight: 200, // Height when fully expanded
            floating: true, // Won't float when scrolling up
            pinned: true, // Stays at top when scrolled
            snap: false, // No snapping behavior
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,

            // Flexible space that creates the parallax scrolling effect
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Silver Scroll Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.deepPurple.shade800,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Silver list for smooth scrolling content
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Text('${index + 1}'),
                ),
                title: Text('Item number ${index + 1}'),
                subtitle: Text('This content scrolls beautifully with silver effects'),
                trailing: const Icon(Icons.chevron_right),
              ),
              childCount: 50, // 50 scrollable items
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SILVER EXAMPLE 2: Grid with Parallax Header
// This creates a grid layout with a parallax scrolling header
// ============================================================
class SilverGridExample extends StatelessWidget {
  const SilverGridExample({super.key});

  // Sample data for the grid items
  final List<Map<String, dynamic>> gridItems = const [
    {'title': 'Mountain View', 'icon': Icons.landscape, 'color': 0xFF9CCC65},
    {'title': 'Ocean Waves', 'icon': Icons.waves, 'color': 0xFF42A5F5},
    {'title': 'Forest Trail', 'icon': Icons.park, 'color': 0xFF66BB6A},
    {'title': 'Desert Sand', 'icon': Icons.terrain, 'color': 0xFFFFB74D},
    {'title': 'City Lights', 'icon': Icons.location_city, 'color': 0xFFEF5350},
    {'title': 'Snow Peak', 'icon': Icons.ac_unit, 'color': 0xFF80DEEA},
    {'title': 'Valley View', 'icon': Icons.photo, 'color': 0xFFFFD54F},
    {'title': 'River Flow', 'icon': Icons.water, 'color': 0xFF4FC3F7},
    {'title': 'Sunset', 'icon': Icons.wb_auto_outlined, 'color': 0xFFFF8A65},
    {'title': 'Starry Night', 'icon': Icons.nightlight_round, 'color': 0xFF7986CB},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Silver App Bar with parallax background image effect
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            floating:true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Silver Grid Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black38,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Parallax background image (colorful gradient that moves with scroll)
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          Colors.purple.shade400,
                          Colors.deepPurple.shade900,
                        ],
                      ),
                    ),
                  ),
                  // Animated pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Icons.grid_on,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.grid_view),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Silver grid for displaying content in a grid pattern
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = gridItems[index % gridItems.length];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(item['color']),
                          Color(item['color']).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(item['color']).withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child:Text('Selected: ${item['title']}')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              size: 48,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 30, // 30 grid items total
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0, // Square tiles
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAIN HOME PAGE
// ============================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String mes = "";
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        mes = _textController.text;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ============================================================
  // FETCH ALBUM
  // ============================================================
  Future<void> fetchAlbum() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text("🌐 Fetching album..."))),
    );

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/albums/2'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        Album album = Album.fromJson(jsonData);
        provider.updateMessage(album.title);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${album.title}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error fetching album")),
      );
    }
  }

  // ============================================================
  // FETCH POST
  // ============================================================
  Future<void> fetchPost() async {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Center(child: Text("🌐 Fetching post..."))),
    );

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/2'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        provider.updateMessage(jsonData['title']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Post loaded")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error fetching post")),
      );
    }
  }

  // ============================================================
  // SUBMIT MESSAGE
  // ============================================================
  void submitMessage() {
    final provider = Provider.of<MessageProvider>(context, listen: false);

    if (mes.trim().isNotEmpty) {
      provider.updateMessage(mes);
      _textController.clear();
      mes = "";
      _focusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text("Message submitted"))),
      );
    }
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================
  void toggleFavorite() {
    final provider = Provider.of<MessageProvider>(context, listen: false);
    final currentMessage = provider.currentMessage;
    final isFav = provider.isFavorite(currentMessage);

    if (!isFav && currentMessage != "type something") {
     provider.addToFavorites(currentMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to favorites!")),
      );
    } else if (isFav) {
      provider.removeFromFavorites(currentMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from favorites")),
      );
    }
  }

  // ============================================================
  // SHOW SILVER EXAMPLES
  // ============================================================
  void showSilverExamples() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Silver List Scroll'),
                  Tab(text: 'Silver Grid Gallery'),
                  Tab(text: 'Ruwwad list'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const SilverScrollExample(),
                    const SilverGridExample(),
                    const SilverRuwwad(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to my forth task"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.purple.shade800 : Colors.purple,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        actions: [
          if (provider.username.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Age: ${provider.userAge}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            padding: const EdgeInsets.all(25.0),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return _buildHorizontalLayout();
          } else {
            return _buildVerticalLayout();
          }
        },
      ),
    );
  }

  // ============================================================
  // VERTICAL LAYOUT
  // ============================================================
  Widget _buildVerticalLayout() {
    final provider = Provider.of<MessageProvider>(context);
    final display = provider.currentMessage;
    final isFav = provider.isFavorite(display);
    final favorites = provider.favorites;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // ✅ FIXED: theme-aware message box
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: display.length > 30 ? 85 : 80,
            decoration: BoxDecoration(
              color: isFav
                  ? Colors.purple.withOpacity(0.3)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(5),
            child: Center(
              child: Text(
                display,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 30),

          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Enter your message',
              hintText: 'Type Anything...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              suffixIcon: mes.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _textController.clear();
                    mes = '';
                  });
                },
              )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: mes.isEmpty ? null : submitMessage,
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 30),

          Column(
            children: [
              GestureDetector(
                onTap: toggleFavorite,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: isFav ? 1.2 : 1.0,
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.purple : Colors.grey,
                    size: 100,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFav ? 'Added to favorites!' : 'Tap heart to save',
                style: TextStyle(
                  color: isFav ? Colors.purple : Colors.grey,
                  fontWeight: isFav ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: fetchAlbum,
            icon: const Icon(Icons.album),
            label: const Text('📀 Fetch Album'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: fetchPost,
            icon: const Icon(Icons.description),
            label: const Text('📝 Fetch Post'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(
                    name: 'Rawzy',
                    age: 21,
                  ),
                ),
              );
            },
            child: const Text('Go to Login Screen'),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {
              provider.clearAllFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All favorites cleared")),
              );
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear All Favorites'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // NEW BUTTON: View Silver Scroll Examples
          ElevatedButton.icon(
            onPressed: showSilverExamples,
            icon: const Icon(Icons.animation),
            label: const Text('✨ View Silver Scroll Examples'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),
          Text(
            'Saved Messages:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: favorites.isEmpty
                ? const Center(child: Text('No favorites yet. Add some!'))
                : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.purple),
                    title: Text(favorite),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeFromFavorites(favorite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Removed from favorites")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HORIZONTAL LAYOUT
  // ============================================================
  Widget _buildHorizontalLayout() {
    final provider = Provider.of<MessageProvider>(context);
    final display = provider.currentMessage;
    final isFav = provider.isFavorite(display);
    final favorites = provider.favorites;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ FIXED: theme-aware message box
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: display.length > 30 ? 85 : 80,
                    decoration: BoxDecoration(
                      color: isFav
                          ? Colors.purple.withOpacity(0.3)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        display,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      hintText: 'Type Anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      suffixIcon: mes.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _textController.clear();
                            mes = '';
                          });
                        },
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: mes.isEmpty ? null : submitMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Column(
                    children: [
                      GestureDetector(
                        onTap: toggleFavorite,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: isFav ? 1.6 : 1.0,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.purple : Colors.grey,
                            size: 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isFav ? 'Added to favorites!' : 'Tap heart to save',
                        style: TextStyle(
                          color: isFav ? Colors.purple : Colors.grey,
                          fontWeight: isFav ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: fetchAlbum,
                    icon: const Icon(Icons.album),
                    label: const Text('📀 Fetch Album'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: fetchPost,
                    icon: const Icon(Icons.description),
                    label: const Text('📝 Fetch Post'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(
                            name: 'Rawzy',
                            age: 21,
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Login Screen'),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () {
                      provider.clearAllFavorites();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("All favorites cleared")),
                      );
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All Favorites'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // NEW BUTTON: View Silver Scroll Examples
                  ElevatedButton.icon(
                    onPressed: showSilverExamples,
                    icon: const Icon(Icons.animation),
                    label: const Text('✨ View Silver Scroll Examples'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ✅ FIXED: theme-aware favorites panel
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Messages:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: favorites.isEmpty
                        ? const Center(child: Text('No favorites yet. Add some!'))
                        : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.favorite, color: Colors.purple),
                            title: Text(favorite),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                provider.removeFromFavorites(favorite);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Removed from favorites")),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}