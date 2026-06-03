import 'package:flutter/material.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  // Tag aktif saat ini untuk filtering
  String _selectedTag = 'Semua';

  // Daftar data tips terstruktur dengan tag
  final List<Map<String, dynamic>> _allAdviceList = [
    {
      'title': 'Gizi Seimbang',
      'desc': 'Penuhi kebutuhan karbohidrat kompleks, protein, dan serat dalam porsi seimbang setiap makan.',
      'icon': Icons.local_dining,
      'color': Colors.orange,
      'tag': 'Nutrisi',
    },
    {
      'title': 'Kurangi Gula Berlebih',
      'desc': 'Batasi konsumsi makanan manis atau minuman kemasan untuk menjaga kestabilan energi harian.',
      'icon': Icons.cake,
      'color': Colors.orange,
      'tag': 'Nutrisi',
    },
    {
      'title': 'Target Jalan Kaki',
      'desc': 'Usahakan untuk mencapai minimal 8.000 langkah sehari guna menjaga sirkulasi darah tetap lancar.',
      'icon': Icons.directions_walk,
      'color': Colors.blue,
      'tag': 'Workout',
    },
    {
      'title': 'Peregangan Ringan',
      'desc': 'Lakukan peregangan otot selama 5 menit setelah duduk bekerja terlalu lama (setiap 2 jam).',
      'icon': Icons.accessibility_new,
      'color': Colors.blue,
      'tag': 'Workout',
    },
    {
      'title': 'Jadwal Tidur Konsisten',
      'desc': 'Usahakan tidur dan bangun di jam yang sama setiap hari untuk menjaga ritme sirkadian tubuh.',
      'icon': Icons.schedule,
      'color': Colors.purple,
      'tag': 'Sleep',
    },
    {
      'title': 'Batasi Layar Gawai',
      'desc': 'Matikan HP atau laptop minimal 30 menit sebelum tidur agar otak lebih mudah rileks.',
      'icon': Icons.phonelink_off,
      'color': Colors.purple,
      'tag': 'Sleep',
    },
    {
      'title': 'Aturan 8 Gelas',
      'desc': 'Minum air putih minimal 2 liter sehari untuk memastikan tubuh terhidrasi sepanjang aktivitas.',
      'icon': Icons.local_drink,
      'color': Colors.teal,
      'tag': 'Hidrasi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Memfilter tips berdasarkan tag yang sedang dipilih oleh user
    final filteredAdvice = _selectedTag == 'Semua'
        ? _allAdviceList
        : _allAdviceList.where((item) => item['tag'] == _selectedTag).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER TITLE =================
              const Text(
                "Health Advice",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tips sehat praktis pilihan untuk Anda.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ================= 1. TIPS UTAMA (ATAS) =================
              Container(
                width: double.infinity,
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 26),
                        SizedBox(width: 8),
                        Text(
                          "Prinsip Utama Hari Ini",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "• Konsistensi jauh lebih penting daripada intensitas sesaat.\n• Jaga jarak makan malam minimal 2 jam sebelum tidur.\n• Imbangi kalori masuk dengan aktivitas fisik aktif.",
                      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ================= 2. HORIZONTAL FILTER TAGS =================
              const Text(
                "Pilih Kategori Tips",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('Semua'),
                    _buildFilterChip('Nutrisi'),
                    _buildFilterChip('Workout'),
                    _buildFilterChip('Sleep'),
                    _buildFilterChip('Hidrasi'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ================= 3. LIST DATA TIPS PERPOINT (DI-FILTER) =================
              filteredAdvice.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Tidak ada tips untuk kategori ini."),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredAdvice.length,
                      itemBuilder: (context, index) {
                        final item = filteredAdvice[index];
                        return _buildRowAdvicePoint(
                          title: item['title'],
                          desc: item['desc'],
                          icon: item['icon'],
                          themeColor: item['color'],
                          tagName: item['tag'],
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pembentuk Tombol Tag Filter
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedTag == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Card Item Perpoint Ringkas (Menggunakan Row & Badge Tag Kecil)
  Widget _buildRowAdvicePoint({
    required String title,
    required String desc,
    required IconData icon,
    required Color themeColor,
    required String tagName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Bullet Berwarna
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: themeColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Isi Teks & Tag Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2E)),
                    ),
                    // Badge Label kecil di ujung kanan card tips
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tagName,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}