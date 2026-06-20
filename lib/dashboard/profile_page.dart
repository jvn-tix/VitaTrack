import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vita_track_2/dashboard/reminder_page.dart';
import 'package:vita_track_2/frame/login_page.dart';
import 'package:vita_track_2/services/api_service.dart';

class ProfilePage extends StatefulWidget {

  final int targetCalories;
  final int targetSteps;
  final int targetSleep;

  final Map<String, dynamic> userProfileData;
  final ValueChanged<Map<String, dynamic>> onProfileChanged;

  final Function(int, int, int) onTargetChanged;

  const ProfilePage({
    super.key,
    required this.userProfileData,  // Sesuaikan nama parameter
    required this.onProfileChanged,
    required this.targetCalories,
    required this.targetSteps,
    required this.targetSleep,
    required this.onTargetChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  late Map<String, dynamic> _localUserData;

  @override
  void initState() {
    super.initState();
    _localUserData = widget.userProfileData; // Inisialisasi data lokal dengan data dari widget
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data dari HomePage berubah setelah selesai ditarik dari API DB
    if (widget.userProfileData != oldWidget.userProfileData) {
      setState(() {
        _localUserData = widget.userProfileData;
      });
    }
  }

  Future<void> _loadProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _handleLogout() async {
    await ApiService.logout(); // Hapus token di shared preferences
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              key: const ValueKey('content'),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF3FF),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(400, 50),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.black,
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_outline, size: 80, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _localUserData['name'] ?? _localUserData['name'] ?? 'No Name',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _localUserData['email'] ?? 'No Email',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profil Saya',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                      label: const Text('Edit', style: TextStyle(color: Color(0xFF3B82F6))),
                      style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Nama', _localUserData['name'] ?? _localUserData['name'] ?? '-'),
                const Divider(color: Color(0xFFE5E7EB), height: 24, thickness: 1),
                _buildInfoRow('Usia', _localUserData['age'] != null ? '${_localUserData['age']} Tahun' : '-'),
                const Divider(color: Color(0xFFE5E7EB), height: 24, thickness: 1),
                _buildInfoRow('Email', _localUserData['email'] ?? _localUserData['email'] ?? '-'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Target Harian',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _showEditTargetDialog,
                      icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                      tooltip: 'Edit target harian',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTargetItem('Kalori', '${widget.targetCalories} kcal'),
                const Divider(color: Color(0xFFE5E7EB)),
                _buildTargetItem('Langkah kaki', '${widget.targetSteps} langkah'),
                const Divider(color: Color(0xFFE5E7EB)),
                _buildTargetItem('Durasi tidur', '${widget.targetSleep} jam'),
                const Divider(color: Color(0xFFE5E7EB)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 30),
          //   child: OutlinedButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const ReminderPage()),
          //       );
          //     },
          //     style: OutlinedButton.styleFrom(
          //       side: const BorderSide(color: Color(0xFF3B82F6)),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          //       minimumSize: const Size(double.infinity, 45),
          //     ),
          //     child: const Text('Reminder', style: TextStyle(color: Color(0xFF3B82F6))),
          //   ),
          // ),
          // const SizedBox(height: 30),

          Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout, // Memanggil fungsi logout
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Keluar / Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTargetDialog() async {
    final caloriesController = TextEditingController(text: (widget.targetCalories).toString());
    final stepsController = TextEditingController(text: (widget.targetSteps).toString());
    final sleepController = TextEditingController(text: (widget.targetSleep).toString());

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Target Harian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Kalori',
                    suffixText: 'kcal',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stepsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Langkah kaki',
                    suffixText: 'langkah',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: sleepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Durasi tidur',
                    suffixText: 'jam',
                  ),
                ),
              ],
            ),
          ),
          
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                int newCal = int.tryParse(caloriesController.text) ?? widget.targetCalories;
                int newSteps = int.tryParse(stepsController.text) ?? widget.targetSteps;
                int newSleep = int.tryParse(sleepController.text) ?? widget.targetSleep;
                
                widget.onTargetChanged(newCal, newSteps, newSleep);

                final updatedMap = {
                  ..._localUserData,
                  'targetCalories': newCal,
                  'targetSteps': newSteps,
                  'targetSleep': newSleep,
                };

                widget.onProfileChanged(updatedMap);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _localUserData['name'] ?? 'No Name');
    final ageController = TextEditingController(text: (_localUserData['age'] ?? '').toString());
    final emailController = TextEditingController(text: _localUserData['email'] ?? 'No Email');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil Saya'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Usia'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedInfo = {
                  ..._localUserData,
                  'name': nameController.text.isNotEmpty ? nameController.text : _localUserData['name'],
                  'age': ageController.text.isNotEmpty ? int.tryParse(ageController.text) ?? _localUserData['age'] : _localUserData['age'],
                  'email': emailController.text.isNotEmpty ? emailController.text : _localUserData['email'],
                };
                widget.onProfileChanged(updatedInfo);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTargetItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}