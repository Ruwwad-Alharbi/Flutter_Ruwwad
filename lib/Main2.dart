import 'package:flutter/material.dart';
import 'events_tickets.dart';
import 'records_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyWs2022App());
}

class MyWs2022App extends StatelessWidget {
  const MyWs2022App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorldSkills 2022',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    EventsListPage(),
    TicketsListPage(),
    RecordsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Records'),
        ],
      ),
    );
  }
}

// ========== RECORDS PAGE (Placeholder) ==========

