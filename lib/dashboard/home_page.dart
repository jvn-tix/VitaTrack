import 'package:flutter/material.dart';
import 'package:vita_track_2/dashboard/advice_page.dart';
import 'package:vita_track_2/dashboard/foodtracker_page.dart';
import 'package:vita_track_2/dashboard/profile_page.dart';
import 'package:vita_track_2/tracker/tracker_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _totalFoodCalories = 0;
  int _currentSteps = 6240;
  int _currentSleep = 7;
  ProfileInfo _profileInfo = const ProfileInfo(
    name: 'Dane',
    age: '25',
    email: 'dane@example.com',
    targetCalories: 1500,
    targetSteps: 8000,
    targetSleep: 8,
  );

  void _updateTotalCalories(int calories) {
    setState(() {
      _totalFoodCalories = calories;
    });
  }

  void _updateProfileInfo(ProfileInfo updatedInfo) {
    setState(() {
      _profileInfo = updatedInfo;
    });
  }

  List<Widget> get _pages => [
        _buildDashboard(), 
        FoodLogManualPage(onTotalCaloriesChanged: _updateTotalCalories),
        const TrackerPage(),
        const AdvicePage(),
        ProfilePage(profileInfo: _profileInfo, onProfileChanged: _updateProfileInfo),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5), 
        elevation: 0,
        title: const Text(
          "VitaTrack",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                "assets/images/vitatrack_logo-removebg.png",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF1E88E5),
          borderRadius: BorderRadius.only(
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Home"),
            _buildNavItem(1, Icons.fastfood_rounded, "Food"),
            _buildNavItem(2, Icons.track_changes_rounded, "Tracker"),
            _buildNavItem(3, Icons.menu_book_rounded, "Advice"),
            _buildNavItem(4, Icons.person_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
  return SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 100), 
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Skor kesehatan hari ini", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                "${_computeHealthScore()} /100",
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                _healthMessage(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Target Harian Anda",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 15),
              _buildTargetRow(
                "Kalori",
                "${_totalFoodCalories.toString()} / ${_profileInfo.targetCalories.toString()} kcal",
              ),
              const Divider(color: Color(0xFFE5E7EB)),
              _buildTargetRow(
                "Langkah",
                "${_currentSteps.toString()} / ${_profileInfo.targetSteps.toString()} langkah",
              ),
              const Divider(color: Color(0xFFE5E7EB)),
              _buildTargetRow(
                "Tidur",
                "${_currentSleep.toString()} / ${_profileInfo.targetSleep.toString()} jam",
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTargetRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    ),
  );
}

int _computeHealthScore() {
  int score = 60;
  if (_profileInfo.targetCalories > 0) score += 10;
  if (_profileInfo.targetSteps > 0) score += 10;
  if (_profileInfo.targetSleep > 0) score += 10;
  if (_totalFoodCalories > 0) score += 10;
  if (score > 100) score = 100;
  return score;
}

String _healthMessage() {
  final score = _computeHealthScore();
  if (score >= 80) {
    return 'Bagus! Target harian dan aktivitas kamu sudah baik.';
  }
  if (score >= 65) {
    return 'Cukup baik, yuk tingkatkan sedikit lagi.';
  }
  return 'Ayo capai target hari ini untuk skor lebih baik.';
}

Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E88E5) : Colors.white70,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E88E5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}