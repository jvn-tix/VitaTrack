import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vita_track_2/dashboard/reminder_page.dart';

class ProfileInfo {
  final String name;
  final String age;
  final String email;
  final int targetCalories;
  final int targetSteps;
  final int targetSleep;

  const ProfileInfo({
    required this.name,
    required this.age,
    required this.email,
    required this.targetCalories,
    required this.targetSteps,
    required this.targetSleep,
  });

  ProfileInfo copyWith({
    String? name,
    String? age,
    String? email,
    int? targetCalories,
    int? targetSteps,
    int? targetSleep,
  }) {
    return ProfileInfo(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      targetCalories: targetCalories ?? this.targetCalories,
      targetSteps: targetSteps ?? this.targetSteps,
      targetSleep: targetSleep ?? this.targetSleep,
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.profileInfo,
    required this.onProfileChanged,
  });

  final ProfileInfo profileInfo;
  final ValueChanged<ProfileInfo> onProfileChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
                      widget.profileInfo.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.profileInfo.email,
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
                _buildInfoRow('Nama', widget.profileInfo.name),
                const Divider(color: Color(0xFFE5E7EB), height: 24, thickness: 1),
                _buildInfoRow('Usia', widget.profileInfo.age),
                const Divider(color: Color(0xFFE5E7EB), height: 24, thickness: 1),
                _buildInfoRow('Email', widget.profileInfo.email),
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
                _buildTargetItem('Kalori', '${widget.profileInfo.targetCalories} kcal'),
                const Divider(color: Color(0xFFE5E7EB)),
                _buildTargetItem('Langkah kaki', '${widget.profileInfo.targetSteps} langkah'),
                const Divider(color: Color(0xFFE5E7EB)),
                _buildTargetItem('Durasi tidur', '${widget.profileInfo.targetSleep} jam'),
                const Divider(color: Color(0xFFE5E7EB)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Reminder', style: TextStyle(color: Color(0xFF3B82F6))),
            ),
          ),
          const SizedBox(height: 30),
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
    final caloriesController = TextEditingController(text: widget.profileInfo.targetCalories.toString());
    final stepsController = TextEditingController(text: widget.profileInfo.targetSteps.toString());
    final sleepController = TextEditingController(text: widget.profileInfo.targetSleep.toString());

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
                final updatedInfo = widget.profileInfo.copyWith(
                  targetCalories: int.tryParse(caloriesController.text) ?? widget.profileInfo.targetCalories,
                  targetSteps: int.tryParse(stepsController.text) ?? widget.profileInfo.targetSteps,
                  targetSleep: int.tryParse(sleepController.text) ?? widget.profileInfo.targetSleep,
                );
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

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: widget.profileInfo.name);
    final ageController = TextEditingController(text: widget.profileInfo.age);
    final emailController = TextEditingController(text: widget.profileInfo.email);

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
                final updatedInfo = widget.profileInfo.copyWith(
                  name: nameController.text.isNotEmpty ? nameController.text : widget.profileInfo.name,
                  age: ageController.text.isNotEmpty ? ageController.text : widget.profileInfo.age,
                  email: emailController.text.isNotEmpty ? emailController.text : widget.profileInfo.email,
                );
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