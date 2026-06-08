import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyFranceDiariesApp());
}

class MyFranceDiariesApp extends StatelessWidget {
  const MyFranceDiariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My France Diaries',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'Roboto'),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DiaryPost {
  final String title;
  final String username;
  final String date;
  final String body;
  final double imageHeight;
  final int number;

  const DiaryPost({
    required this.title,
    required this.username,
    required this.date,
    required this.body,
    required this.imageHeight,
    required this.number,
  });
}

const String _loremBody =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim '
    'veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea '
    'commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit '
    'esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat '
    'non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

const String _loremBody2 =
    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium '
    'doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore '
    'veritatis et quasi architecto beatae vitae dicta sunt explicabo.';

List<DiaryPost> _leftPosts = [];
List<DiaryPost> _rightPosts = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // UI State
  int _selectedIndex = 0;
  DiaryPost? _selectedPost;
  bool _showSignInForm = false;
  bool _isLoading = true;
  String _errorMessage = '';

//  Authentication
  bool isSigned = false;
  String _username = '';
  String _authToken = '';
  String _emailError = '';
  String _passwordError = '';
  bool _obscurePassword = true;

//  Favorites
  Set<String> _favoriteIds = {};
  int _favoriteCount = 0;

//  Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

//  Plugins
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadDiariesFromJson();
  }

  bool _isFavorited(DiaryPost post) {
    return _favoriteIds.contains(post.number.toString());
  }

  Future<void> _toggleFavorite(DiaryPost post) async {
    if (!isSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text("Please sign in to add favorites")),
        ),
      );
      return;
    }

    if (_isFavorited(post)) {
      setState(() {
        _favoriteIds.remove(post.number.toString());
        _favoriteCount--;
      });
      await _saveFavoritesToDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text("Removed from favorites"))),
      );
    } else {
      setState(() {
        _favoriteIds.add(post.number.toString());
        _favoriteCount++;
      });
      await _saveFavoritesToDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text("Added to favorites!"))),
      );
    }
  }
  Future<void> _loadDiariesFromJson() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load Json 
      final String jsonString = await rootBundle.loadString('assets/diaries.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> diaries = jsonData['diaries'];

      List<DiaryPost> left = [];
      List<DiaryPost> right = [];

      for (var item in diaries) {
        DiaryPost post = DiaryPost(
          title: item['title'],
          username: item['username'],
          date: item['date'],
          body: item['body'],
          imageHeight: item['imageHeight'].toDouble(),
          number: item['number'],
        );

        if (item['column'] == 'left') {
          left.add(post);
        } else {
          right.add(post);
        }
      }

      setState(() {
        _leftPosts = left;
        _rightPosts = right;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load diaries: $e';
        _isLoading = false;
      });
      print('Error loading diaries: $e');
    }
  }
  Future<void> _loadFavorites() async {
    await _loadFavoritesFromDevice();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _notifications.initialize(settings);
    _loadSavedData();
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'login_channel',
      'Login Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _notifications.show(0, title, body, details);
  }

  void _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token') ?? '';
      if (_authToken.isNotEmpty) {
        isSigned = true;

      }
    });
    if (_authToken.isNotEmpty) {
      await _loadFavoritesFromDevice();
    }
  }
// Save favorites to device
  Future<void> _saveFavoritesToDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds.toList());
  }

// Load favorites from device
  Future<void> _loadFavoritesFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('favorites');
    setState(() {
      if (saved != null) {
        _favoriteIds = saved.toSet();
      } else {
        _favoriteIds = {};
      }
      _favoriteCount = _favoriteIds.length;
    });
  }
  void _showUserAgreement() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("User Agreement"),
            Icon(Icons.description, color: Colors.blue),
          ],
        ),
        content: Container(
          width: 450,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection("1. Terms of Use", "By using 'My France Diaries', you agree to these terms and conditions."),
                const SizedBox(height: 16),
                _buildSection("2. Privacy Policy", "Your privacy is important to us. We collect and process your personal data in accordance with applicable laws."),
                const SizedBox(height: 16),
                _buildSection("3. Data Collection", "We collect email address and usage data to personalize your experience."),
                const SizedBox(height: 16),
                _buildSection("4. Cookies", "This app uses local storage to remember your preferences."),
                const SizedBox(height: 16),
                _buildSection("5. Changes to Agreement", "We may update this agreement at any time. Continued use constitutes acceptance."),
                const SizedBox(height: 16),
                _buildSection("6. Contact", "Email: support@myfrance.com"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("I Agree", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }

  void showSignInForm() {
    setState(() {
      _selectedIndex = 2;
      _showSignInForm = true;
    });
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailError = '';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Invalid Email';
      } else {
        _emailError = '';
      }
    });
  }

  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordError = '';
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$').hasMatch(password)) {
        _passwordError = 'Invalid Password (6+ chars with letters and numbers)';
      } else {
        _passwordError = '';
      }
    });
  }

  void _selectPost(DiaryPost post) {
    setState(() => _selectedPost = post);
  }

  void _closePost() {
    setState(() => _selectedPost = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Left nav bar
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
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'My\nFrance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                _buildNavItem(Icons.home_outlined, 'Home', 0),
                const SizedBox(height: 20),
                _buildNavItem(Icons.map_outlined, 'Travel', 1),
                const SizedBox(height: 20),
                _buildNavItem(Icons.person_outline, 'Account', 2),
                const Spacer(),
              ],
            ),
          ),

          // Middle panel
          Container(
            width: 400,
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(24, 50, 24, 24)),
                Expanded(child: _getmid()),
              ],
            ),
          ),

          // Right panel
          Expanded(child: _buildRightPanelContent()),
        ],
      ),
    );
  }

  Widget _buildRightPanelContent() {
    if (_selectedPost != null) {
      return _DetailPanel(
        post: _selectedPost!,
        onClose: _closePost,
        isFavorited: _isFavorited(_selectedPost!),
        onFavoriteToggle: () => _toggleFavorite(_selectedPost!),
      );
    }
    if (_selectedIndex == 2 && !isSigned && _showSignInForm) {
      return _buildSignInForm();
    }
    if (_selectedIndex == 2 && !isSigned && !_showSignInForm) {
      return const _MyAccount();
    }
    if (_selectedIndex == 2 && isSigned) {
      return _buildFavoritesList();
    }
    return const _WelcomePanel();
  }

  Widget _buildFavoritesList() {
    final favoritePosts = [..._leftPosts, ..._rightPosts]
        .where((post) => _favoriteIds.contains(post.number.toString()))
        .toList()
        .reversed
        .toList();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "My Favorites ($_favoriteCount)",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: favoritePosts.isEmpty
                ? const Center(
              child: Text(
                "No favorites yet.\nTap the star on any diary to add!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: favoritePosts.length,
              itemBuilder: (context, index) {
                final post = favoritePosts[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  post.username,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              post.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text(
                            'IMAGE\nPLACEHOLDER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Sign in/up",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "to discover more sights of France",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Your Email Address",
                  hintText: "example@example.eu",
                  errorText: _emailError.isEmpty ? null : _emailError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Your Password",
                  hintText: "......",
                  errorText: _passwordError.isEmpty ? null : _passwordError,
                  border: const OutlineInputBorder(),
                  suffixIcon: GestureDetector(
                    onLongPress: () => setState(() => _obscurePassword = false),
                    onLongPressUp: () =>
                        setState(() => _obscurePassword = true),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                  ),
                ),
                onChanged: _validatePassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_emailError.isNotEmpty || _passwordError.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Please fix errors first"),
                          ),
                        ),
                      );
                      return;
                    }
                    if (_emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Please enter email and password"),
                          ),
                        ),
                      );
                      return;
                    }
                    await _signInWithApi();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Sign in/up",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showUserAgreement(),
                child: const Text(
                  "READ USER AGREEMENT",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithApi() async {
    String email = _emailController.text;
    String username = email.split('@')[0];

    setState(() {
      isSigned = true;
      _username = username;
      _showSignInForm = false;
    });

    await _loadFavorites();

    try {
      await _audioPlayer.play(AssetSource('audio/sign_in_success.mp3'));
    } catch (e) {
      print("Sound file not found");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text("Welcome $username!"))),
    );
  }

  void _showLoginError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Center(child: Text(message))));
    _showNotification("Login Failed", message);
  }

  Widget _buildNavItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _selectedPost = null;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.black : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredGrid() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading diaries...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadDiariesFromJson(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: _leftPosts
                .map((p) => _buildCard(p, isSelected: _selectedPost == p))
                .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 40),
              ..._rightPosts
                  .map((p) => _buildCard(p, isSelected: _selectedPost == p))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(DiaryPost post, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _selectPost(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.red.shade400, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: post.imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'IMAGE\nPLACEHOLDER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.username,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getmid() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 24, bottom: 24),
              child: Text(
                'Diaries',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(child: _buildStaggeredGrid()),
            ),
          ],
        );
      case 1:
        return const _MyTravel();
      case 2:
        return isSigned ? _buildAccountSignedInMiddle() : const _MyAccount();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountSignedInMiddle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.black87),
          const SizedBox(height: 16),
          Text(
            _username.isEmpty ? "User" : _username,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              await prefs.remove('favorites');
              setState(() {
                isSigned = false;
                _username = '';
                _authToken = '';
                _showSignInForm = false;
                _favoriteIds.clear();
                _favoriteCount = 0;
                _emailController.clear();
                _passwordController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Sign out",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "to change the other account",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_favoriteCount",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Favorites",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Detail panel
class _DetailPanel extends StatelessWidget {
  final DiaryPost post;
  final VoidCallback onClose;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;

  const _DetailPanel({
    required this.post,
    required this.onClose,
    required this.isFavorited,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, size: 22),
                ),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorited ? Icons.star : Icons.star_border,
                    size: 22,
                    color: isFavorited ? Colors.amber : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('IMAGE PLACEHOLDER',textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    ),

                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: post.title));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Center(
                                child: Text("Title copied to clipboard!"),
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${post.username}   ${post.date}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    post.body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('IMAGE PLACEHOLDER',textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontStyle: FontStyle.italic,

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

// Welcome panel
class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/france.jpg', fit: BoxFit.cover),
            ),
          ),
          const Text(
            'Welcome to France',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Travel page
class _MyTravel extends StatelessWidget {
  const _MyTravel();

  final List<Map<String, String>> _locations = const [
    {
      'name': 'Paris',
      'place': 'Eiffel Tower',
      'description':
      'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France.',
    },
    {
      'name': 'Lyon',
      'place': 'Notre-Dame de Fourvière',
      'description':
      'The Basilica of Notre-Dame de Fourvière is a minor basilica in Lyon, France.',
    },
    {
      'name': 'Marseille',
      'place': 'Old Port of Marseille',
      'description':
      'The Old Port of Marseille is located at the end of the Canebière.',
    },
    {
      'name': 'Toulouse',
      'place': 'Cité de l\'Espace',
      'description':
      'The Cité de l\'Espace is a theme park focused on space and astronautics.',
    },
    {
      'name': 'Saudi Arabia',
      'place': 'AlUla',
      'description':
      'AlUla is a city in north-western Saudi Arabia known for its rich history.',
    },
  ];

  void _showLocationDialog(BuildContext context, Map<String, String> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            height: 550,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  location['place']!,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  location['name']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          location['description']!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('IMAGE PLACEHOLDER'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('MAP IMAGE PLACEHOLDER'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog
                    Navigator.pop(context);

                    // Get location name for search
                    String locationName = location['place'] ?? location['name'] ?? 'France';
                    String query = Uri.encodeComponent(locationName);

                    // Open Google Maps
                    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to Apple Maps
                      final Uri appleUrl = Uri.parse('http://maps.apple.com/?q=$query');
                      if (await canLaunchUrl(appleUrl)) {
                        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Could not open maps")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go Now!', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
            child: Text(
              "Popular Locations",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.orange,
                    size: 30,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () => _showLocationDialog(context, _locations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// mid ( not Signed in)
class _MyAccount extends StatelessWidget {
  const _MyAccount();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 100,
            color: Colors.black87,
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () {
              final homeState = context
                  .findAncestorStateOfType<_HomePageState>();
              homeState?.showSignInForm();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Join us now",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "to discover more sights of France",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}