import 'package:flutter/material.dart';

class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF1E88E5), width: 2),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Advice",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1E88E5)),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                                radius: 25,
                                child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF1E88E5), size: 30),
                              ),
                              const SizedBox(width: 15),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("VitaTrack AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("Berdasarkan data kamu hari ini", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildAdviceCard(
                            title: "Kurang minum air",
                            desc: "Asupan airmu baru 1.2L, masih kurang dari target 2.5L. Minum segelas air sekarang untuk menjaga metabolisme.",
                            color: Colors.blue,
                          ),
                          _buildAdviceCard(
                            title: "Langkah kaki hampir tercapai",
                            desc: "Tinggal 3.760 langkah lagi menuju target 10.000! Jalan kaki santai 15 menit sore ini bisa membantu.",
                            color: Colors.green,
                          ),
                          _buildAdviceCard(
                            title: "Tidur lebih awal malam ini",
                            desc: "Data menunjukkan kualitas tidurmu menurun jika tidur lewat jam 23:00. Atur pengingat istirahat sekarang.",
                            color: Colors.orange,
                          ),
                          _buildAdviceCard(
                            title: "Butuh lebih banyak Protein",
                            desc: "Berdasarkan log makananmu, asupan protein hari ini baru 40%. Coba tambahkan telur atau tempe di makan malam.",
                            color: Colors.purple,
                          ),
                          _buildAdviceCard(
                            title: "Detak jantung saat istirahat tinggi",
                            desc: "Rata-rata detak jantungmu saat diam sedikit meningkat (85 bpm). Pastikan kamu cukup istirahat dan kurangi kafein.",
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildPillTab("Hidrasi", Colors.blue[100]!, Colors.blue),
                    _buildPillTab("Aktivitas", Colors.green[100]!, Colors.green),
                    _buildPillTab("Tidur", Colors.orange[100]!, Colors.orange),
                    _buildPillTab("Nutrisi", Colors.purple[100]!, Colors.purple),
                    _buildPillTab("Jantung", Colors.red[100]!, Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard({required String title, required String desc, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            style: TextStyle(color: Colors.grey[800], fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab(String label, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}