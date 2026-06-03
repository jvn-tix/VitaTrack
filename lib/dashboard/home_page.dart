import 'package:flutter/material.dart';
import 'package:vita_track_2/dashboard/advice_page.dart';
import 'package:vita_track_2/dashboard/foodtracker_page.dart';
import 'package:vita_track_2/dashboard/profile_page.dart';
import 'package:vita_track_2/tracker/tracker_page.dart';
import 'package:vita_track_2/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _totalFoodCalories = 0;
  int _currentSteps = 0;
  int _currentBPM = 72;
  int _currentSleep = 0;

  Map<String, dynamic>? _userProfileData;
  bool _isLoadingProfile = true;

  int _targetCalories = 1500;
  int _targetSteps = 8000;
  int _targetSleep = 8;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final data = await ApiService.getProfile();
      
      // KODE DEBUG: Untuk melihat di Debug Console data aslinya seperti apa
      print("DATA DARI API BACKEND: $data");

      if (data != null) {
        setState(() {
          // Solusi Aman: Gabungkan target harian dengan data dari DB
          _userProfileData = {
            'targetCalories': _targetCalories,
            'targetSteps': _targetSteps,
            'targetSleep': _targetSleep,
          };

          // Beberapa backend membungkus datanya di dalam object 'user' atau 'data'
          // Kita cek semua kemungkinan strukturnya di sini:
          if (data is Map<String, dynamic>) {
            if (data.containsKey('user')) {
              _userProfileData!.addAll(data['user']);
            } else if (data.containsKey('data')) {
              _userProfileData!.addAll(data['data']);
            } else {
              _userProfileData!.addAll(data);
            }
          }
          
          _isLoadingProfile = false;
        });
        print("HASIL AKHIR VARIABEL _userProfileData: $_userProfileData");
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
        print("Data dari API bernilai null!");
      }
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      print("Error fetching profile on home: $e");
    }
    
  }

  void _updateTotalCalories(int calories) {
    setState(() {
      _totalFoodCalories = calories;
    });
  }

  void _updateSteps(int steps) {
    setState(() {
      _currentSteps = steps;
    });
  }

  void _updateBPM(int bpm) {
    setState(() {
      _currentBPM = bpm;
    });
  }

  void _updateSleep(int hours) {
    setState(() {
      _currentSleep = hours;
    });
  }

  List<Widget> get _pages => [
        _buildDashboard(), 
        FoodLogManualPage(onTotalCaloriesChanged: _updateTotalCalories),
        TrackerPage(currentSteps: _currentSteps, targetSteps: _targetSteps, currentBPM: _currentBPM, currentSleep: _currentSleep, onStepsChanged: _updateSteps, onBPMChanged: _updateBPM, onSleepChanged: _updateSleep),
        const AdvicePage(),
        ProfilePage(
              userProfileData: _userProfileData ?? {},
              targetCalories: _targetCalories,
              targetSteps: _targetSteps,
              targetSleep: _targetSleep,
              onProfileChanged: (updatedProfile) {
                setState(() {
                  _userProfileData = updatedProfile;
                });
              },
              onTargetChanged: (cal, steps, sleep) {
                setState(() {
                  _targetCalories = cal;
                  _targetSteps = steps;
                  _targetSleep = sleep;
                });
              },
            ),
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
    final healthScore = _computeHealthScore();
    final healthMsg = _healthMessage();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER: SALAM & PROFIL DINA MIS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${_userProfileData?['name'] ?? _userProfileData?['username'] ?? 'User'}! 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Yuk, pantau kesehatanmu hari ini!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF1E88E5), size: 30),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // ================= RINGKASAN SKOR KESEHATAN (MODERN) =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Visual Progress Melingkar untuk Skor
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: healthScore / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      '$healthScore',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                // Informasi & Pesan Motivasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Health Score Kamu',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        healthMsg,
                        style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // ================= JUDUL BAGIAN AKTIVITAS =================
          const Text(
            'Aktivitas Hari Ini',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
          ),
          const SizedBox(height: 15),

          // ================= GRID METRIK DUA KOLOM (TIDAK MEMBOSANKAN) =================
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildMetricCard(
                title: 'Kalori Makanan',
                value: '$_totalFoodCalories',
                target: '$_targetCalories kcal',
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                progress: _targetCalories > 0 ? _totalFoodCalories / _targetCalories : 0,
              ),
              _buildMetricCard(
                title: 'Langkah Kaki',
                value: '$_currentSteps',
                target: '$_targetSteps langkah',
                icon: Icons.directions_walk,
                iconColor: Colors.blue,
                progress: _targetSteps > 0 ? _currentSteps / _targetSteps : 0,
              ),
              _buildMetricCard(
                title: 'Durasi Tidur',
                value: '$_currentSleep',
                target: '$_targetSleep jam',
                icon: Icons.bedtime,
                iconColor: Colors.purple,
                progress: _targetSleep > 0 ? _currentSleep / _targetSleep : 0,
              ),
              _buildMetricCard(
                title: 'Detak Jantung',
                value: '$_currentBPM',
                target: 'Normal (60-100)',
                icon: Icons.favorite,
                iconColor: Colors.red,
                progress: _currentBPM >= 60 && _currentBPM <= 100 ? 0.85 : 0.4, // Visualisasi statis detak jantung sehat
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget baru untuk membuat Card Grid yang Estetik
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String target,
    required IconData icon,
    required Color iconColor,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: clampedProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target: $target',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
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

double _computeHealthScore() {
  // Jika data belum siap, berikan skor default 0
  if (_userProfileData == null) return 0.0;

  // 1. Hitung kontribusi kalori makanan (Makin mendekati target, makin bagus. Maksimal poin 35)
  double calorieScore = 0;
  if (_targetCalories > 0 && _totalFoodCalories > 0) {
    double ratio = _totalFoodCalories / _targetCalories;
    if (ratio <= 1.0) {
      calorieScore = ratio * 35; // Poin naik seiring makanan yang dicatat
    } else {
      // Jika kalori surplus/kelebihan, kurangi poinnya pelan-pelan
      calorieScore = (2.0 - ratio).clamp(0.0, 1.0) * 35;
    }
  }

  // 2. Hitung kontribusi langkah kaki (Maksimal poin 35)
  double stepProgress = _targetSteps > 0 ? (_currentSteps / _targetSteps) : 0;
  double stepScore = stepProgress.clamp(0.0, 1.0) * 35;

  // 3. Hitung kontribusi durasi tidur (Maksimal poin 30)
  double sleepProgress = _targetSleep > 0 ? (_currentSleep / _targetSleep) : 0;
  double sleepScore = sleepProgress.clamp(0.0, 1.0) * 30;

  // Total skor maksimal adalah 35 + 35 + 30 = 100
  double totalScore = calorieScore + stepScore + sleepScore;
  
  // Kembalikan hasil dalam bentuk double satu angka di belakang koma (misal: 65.5)
  return double.parse(totalScore.toStringAsFixed(1));
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