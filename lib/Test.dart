import 'package:flutter/material.dart';

void main() {
  runApp(const MyFranceDiariesApp());
}

class MyFranceDiariesApp extends StatelessWidget {
  const MyFranceDiariesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My France Diaries',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
      ),
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

final List<DiaryPost> _leftPosts = [
  DiaryPost(title: 'Nice trip in Paris', username: 'Publish Username', date: 'Aug 24, 2024 12:05 AM', body: _loremBody, imageHeight: 110, number: 1),
  DiaryPost(title: 'Nice trip in Lyon',  username: 'Publish Username', date: 'Aug 20, 2024 09:30 AM', body: _loremBody, imageHeight: 140, number: 2),
  DiaryPost(title: 'Nice trip in Lyon',  username: 'Publish Username', date: 'Aug 18, 2024 03:15 PM', body: _loremBody, imageHeight: 110, number: 3),
];

final List<DiaryPost> _rightPosts = [
  DiaryPost(title: 'Nice trip in Lyon',  username: 'Publish Username', date: 'Aug 17, 2024 11:00 AM', body: _loremBody, imageHeight: 80,  number: 4),
  DiaryPost(title: 'Nice trip in Paris', username: 'Publish Username', date: 'Aug 15, 2024 08:45 AM', body: _loremBody, imageHeight: 90,  number: 5),
  DiaryPost(title: 'Nice trip in Paris', username: 'Publish Username', date: 'Aug 12, 2024 05:20 PM', body: _loremBody, imageHeight: 70,  number: 6),
  DiaryPost(title: 'Nice trip in Paris', username: 'Publish Username', date: 'Aug 10, 2024 02:10 PM', body: _loremBody, imageHeight: 60,  number: 7),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DiaryPost? _selectedPost;
  bool isSigned = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          // ── Left nav bar ──────────────────────────────────────────
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
                        child: const Icon(Icons.public, size: 20, color: Colors.grey),
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
                const SizedBox(height: 32),
                _buildNavItem(Icons.home_outlined, 'Home', 0),
                _buildNavItem(Icons.map_outlined, 'Travel', 1),
                _buildNavItem(Icons.person_outline, 'Account', 2),
                const Spacer(),
              ],
            ),
          ),

          // ── Middle panel ──────────────────────────────────────────
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

          // ── Right panel ───────────────────────────────────────────
          Expanded(child: _buildRightPanelContent()),
        ],
      ),
    );
  }

  // ── Right panel router ───────────────────────────────────────────
  Widget _buildRightPanelContent() {
    if (_selectedPost != null) {
      return _DetailPanel(post: _selectedPost!, onClose: _closePost);
    }
    if (_selectedIndex == 2 && !isSigned) {
      return _buildSignInForm();
    }
    if (_selectedIndex == 2 && isSigned) {
      return _buildFavoritesList();
    }
    return _WelcomePanel();
  }

  // ── My Favorites list (right panel after sign-in) ────────────────
  Widget _buildFavoritesList() {
    final allPosts = [..._leftPosts, ..._rightPosts];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: const Text(
              "My Favorites",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(post.username,
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey.shade500)),
                                const SizedBox(width: 8),
                                Text(post.date,
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey.shade500)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              post.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Thumbnail
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
                                fontWeight: FontWeight.w500),
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

  // ── Sign-in form (right panel before sign-in) ────────────────────
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
              const Text("Sign in/up",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("to discover more sights of France",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Your Email Address",
                  hintText: "example@example.eu",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Your Password",
                  hintText: "......",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_emailController.text == "Ruwwadrrd@gmail.com" &&
                        _passwordController.text == "Rawad5221") {
                      setState(() => isSigned = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar( content:Center(child:Text("Welcome to your favorite list")) )
                      );
                    } else {
                      // Optional: show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content:Center(child:Text("Invalid email or password")) ),
                      );
                    }
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
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("User Agreement"),
                  content: const Text(
                    "By using this app, you agree to our terms and conditions. "
                        "Your data will be used to personalize your experience.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("I Agree"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("READ USER AGREEMENT",
                style: TextStyle(fontSize: 12, color: Colors.blue)),
          ),

            ],
          ),
        ),
      ),
    );
  }

  // ── Nav item ─────────────────────────────────────────────────────
  Widget _buildNavItem(IconData icon, String title, int index) {
    final bool selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected ? Colors.black : Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Staggered grid (Home) ────────────────────────────────────────
  Widget _buildStaggeredGrid() {
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
                  Text(post.title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(post.username,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Middle panel router ──────────────────────────────────────────
  Widget _getmid() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 1, 220, 24),
              child: Text('Diaries',
                  style: TextStyle(
                      fontSize: 50, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStaggeredGrid(),
              ),
            ),
          ],
        );
      case 1:
        return const _MyTravel();
      case 2:
        return isSigned
            ? _buildAccountSignedInMiddle()
            : const _MyAccount();
      default:
        return const SizedBox();
    }
  }

  // ── Middle panel — signed-in account view ────────────────────────
  Widget _buildAccountSignedInMiddle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.black87),
          const SizedBox(height: 16),
          const Text(
            "Username",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              setState(() {
                isSigned = false;
                _emailController.clear();
                _passwordController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Sign out",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("10",
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                Text("Favorites",
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // ← end of _HomePageState

// ── Detail panel ─────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final DiaryPost post;
  final VoidCallback onClose;

  const _DetailPanel({required this.post, required this.onClose});

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
                const Icon(Icons.star_border, size: 22),
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
                    child: const Center(
                      child: Text('IMAGE PLACEHOLDER',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(post.title,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.copy, size: 20, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${post.username}   ${post.date}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  Text(post.body,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('IMAGE PLACEHOLDER',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(post.body,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  Text(_loremBody2,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Welcome panel ─────────────────────────────────────────────────────
class _WelcomePanel extends StatelessWidget {
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
          const Text('Welcome to France',
              style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Travel page ───────────────────────────────────────────────────────
class _MyTravel extends StatelessWidget {
  const _MyTravel({super.key});

  final List<Map<String, String>> _locations = const [
    {
      'name': 'Paris',
      'place': 'Eiffel Tower',
      'description':
      'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris, France. It is named after the engineer Gustave Eiffel, whose company designed and built the tower from 1887 to 1889. Locally nicknamed "La dame de fer" (French for "Iron Lady"), it was constructed as the centerpiece of the 1889 World\'s Fair, and to crown the centennial anniversary of the French Revolution. Although initially criticised by some of France\'s leading artists and intellectuals for its design, it has since become a global cultural icon of France and one of the most recognisable structures in the world.',
    },
    {
      'name': 'Lyon',
      'place': 'Notre-Dame de Fourvière',
      'description':
      'The Basilica of Notre-Dame de Fourvière is a minor basilica in Lyon, France. It was built with private funds between 1872 and 1884 in a dominant position overlooking the city. The site it occupies was the former Roman forum of Trajan, the forum vetus (old forum), thus its name. The basilica has become a symbol of the city and offers stunning views of Lyon.',
    },
    {
      'name': 'Marseille',
      'place': 'Old Port of Marseille',
      'description':
      'The Old Port of Marseille is located at the end of the Canebière. Since antiquity, it has been the natural harbour of the city. Today, it is the main marina of the city and a popular tourist destination with many restaurants, cafes, and shops. The port is guarded by the forts of Saint-Nicolas and Saint-Jean.',
    },
    {
      'name': 'Toulouse',
      'place': 'Cité de l\'Espace',
      'description':
      'The Cité de l\'Espace is a theme park focused on space and astronautics. It includes full-scale models of the Ariane 5 rocket, Mir space station, and a planetarium. It is located on the eastern outskirts of Toulouse, a major European centre of space technology.',
    },
    {
      'name': 'Saudi Arabia',
      'place': 'AlUla',
      'description':
      'AlUla is a city in north-western Saudi Arabia known for its rich history and stunning landscapes. It is home to the ancient Nabatean archaeological site of Hegra (Madain Saleh), Saudi Arabia\'s first UNESCO World Heritage Site. The area features dramatic rock formations, ancient tombs, and lush oasis valleys.',
    },
  ];

  void _showLocationDialog(
      BuildContext context, Map<String, String> location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            height: 550,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  location['place']!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(location['name']!,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(location['description']!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.5)),
                        const SizedBox(height: 16),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('IMAGE PLACEHOLDER',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
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
                            child: Text('MAP IMAGE PLACEHOLDER',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go Now!',
                      style: TextStyle(fontSize: 16)),
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
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(1, 20, 70, 50),
            child: Text(
              "Popular Locations",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: const Icon(Icons.location_on,
                      color: Colors.orange, size: 30),
                  title: Text(_locations[index]['place']!),
                  subtitle: Text(_locations[index]['name']!),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () =>
                      _showLocationDialog(context, _locations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account middle panel (not signed in) ─────────────────────────────
class _MyAccount extends StatelessWidget {
  const _MyAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 1),
          SizedBox(height: 1),
          const Icon(Icons.account_circle_outlined, size: 100, color: Colors.black87),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Join us now",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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