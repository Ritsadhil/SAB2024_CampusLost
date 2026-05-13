import 'package:flutter/material.dart';
import 'beranda.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _screens = [
    const BerandaScreen(),
    const Center(child: Text('Halaman Search (Belum Dibuat)')), // Placeholder untuk Search
    const MyReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Menampilkan halaman sesuai index
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1D54D4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah halaman saat ditab
          });
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home'
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search'
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 2 ? const Color(0xFFEAF0FF) : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.inventory_2_outlined),
            ),
            label: 'My Reports',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 3 ? const Color(0xFFEAF0FF) : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}