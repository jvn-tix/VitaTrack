import 'package:flutter/material.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 16.0,
                bottom: 4.0,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E88E5),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Kembali",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1E88E5),
                    width: 2.0,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Reminder",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 2,
                      color: Color(0xFF1E88E5),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        4,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                const Color(0xFF1E88E5)
                                    .withOpacity(0.1),
                            child: const Icon(
                              Icons.alarm_on_rounded,
                              color: Color(0xFF1E88E5),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Jadwal Pengingat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Jangan lewatkan aktivitas sehatmu hari ini",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildReminderCard(
                            time: "07:00 WIB",
                            title: "Minum Air Pagi",
                            description:
                                "Awali harimu dengan 500ml air putih untuk menghidrasi tubuh setelah tidur malam.",
                            accentColor: Colors.blue,
                            isCompleted: true,
                          ),
                          _buildReminderCard(
                            time: "10:30 WIB",
                            title: "Peregangan Singkat",
                            description:
                                "Sudah duduk terlalu lama. Berdiri dan lakukan peregangan ringan selama 5 menit.",
                            accentColor: Colors.green,
                            isCompleted: true,
                          ),
                          _buildReminderCard(
                            time: "13:00 WIB",
                            title: "Minum Air Siang",
                            description:
                                "Waktunya isi ulang hidrasimu. Minum 400ml air setelah makan siang.",
                            accentColor: Colors.blue,
                            isCompleted: false,
                          ),
                          _buildReminderCard(
                            time: "17:00 WIB",
                            title: "Target Langkah Kaki",
                            description:
                                "Jalan santai sore yuk! Selesaikan sisa target langkah kakimu hari ini.",
                            accentColor: Colors.green,
                            isCompleted: false,
                          ),
                          _buildReminderCard(
                            time: "22:00 WIB",
                            title: "Persiapan Tidur",
                            description:
                                "Matikan gadget dan kurangi pencahayaan kamar untuk kualitas tidur yang lebih baik.",
                            accentColor: Colors.indigo,
                            isCompleted: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
                top: 4.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterPill(
                      label: "Semua",
                      bgColor: const Color(0xFFE3F2FD),
                      textColor: Colors.blue,
                    ),
                    _buildFilterPill(
                      label: "Air Minum",
                      bgColor: const Color(0xFFE0F7FA),
                      textColor: Colors.cyan,
                    ),
                    _buildFilterPill(
                      label: "Olahraga",
                      bgColor: const Color(0xFFE8F5E9),
                      textColor: Colors.green,
                    ),
                    _buildFilterPill(
                      label: "Istirahat",
                      bgColor: const Color(0xFFE8EAF6),
                      textColor: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String time,
    required String title,
    required String description,
    required Color accentColor,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isCompleted
                ? accentColor
                : Colors.grey[400],
            size: 22,
          ),
        ],
      ),
    );
  }


  Widget _buildFilterPill({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}