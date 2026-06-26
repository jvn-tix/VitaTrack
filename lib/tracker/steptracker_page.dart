import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:vita_track_2/services/api_service.dart';

class StepTrackerDetail extends StatefulWidget {
  final int currentSteps;
  final int targetSteps;
  final ValueChanged<int> onStepsChanged;
  const StepTrackerDetail({super.key, required this.currentSteps, required this.targetSteps, required this.onStepsChanged});

  @override
  State<StepTrackerDetail> createState() => _StepTrackerDetailState();
}

class _StepTrackerDetailState extends State<StepTrackerDetail> {
  late Stream<StepCount> _stepCountStream;
  
  int _previousSteps = 0; 

  @override
  void initState() {
    super.initState();
    _fetchLastStepFromDatabase();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  Future<void> _fetchLastStepFromDatabase() async {
    try {
      // Skenarionya: Panggil fungsi di ApiService kelompokmu
      // Misal fungsi tersebut mengembalikan data langkah terakhir dalam bentuk integer
      int lastStep = await ApiService.getLastStepData(); // <--- Sesuaikan dengan fungsi di api_service.dart
      
      setState(() {
        _previousSteps = lastStep;
      });
    } catch (e) {
      print("Gagal mengambil data langkah terakhir: $e");
      setState(() {
        _previousSteps = 6240; // Default fallback jika API belum siap / error
      });
    }
  }

  void _onStepCount(StepCount event) {
    int steps = event.steps > 0 ? event.steps : 0;
    widget.onStepsChanged(steps); // <--- KIRIM UPDATE KE HOMEPAGE
    ApiService.sendSteps(steps);
  }

  void _onStepCountError(error) {
    print("Gagal mengakses sensor pedometer: $error");
    widget.onStepsChanged(0); // Reset ke 0 jika sensor error
  }

  // FUNGSI SIMULASI JALAN KHUSUS DEMO DOSEN
  void _simulateStepWalk() {
    int newSteps = widget.currentSteps + 500; 
    widget.onStepsChanged(newSteps); 
    ApiService.sendSteps(newSteps); 
  }

  double _calculateDistance(int steps) {
    return steps * 0.00075;
  }

  int _calculateCalories(int steps) {
    return (steps * 0.04).round();
  }

  @override
  Widget build(BuildContext context) {
    double distance = _calculateDistance(widget.currentSteps);
    int calories = _calculateCalories(widget.currentSteps);
    double progressPercent = (widget.currentSteps / widget.targetSteps).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      children: [
        Center(
          child: Column(
            children: [
              Text(
                "Hari ini",
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Text(
                "${widget.currentSteps}",
                style: const TextStyle(
                  fontSize: 56, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF1E88E5),
                  letterSpacing: -1
                ),
              ),
              Text(
                "dari target ${widget.targetSteps} langkah",
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(height: 25),

                // === SELEP KODE KOTAK INI ===
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_done_rounded, color: Color(0xFF1E88E5), size: 22),
                          const SizedBox(width: 10),
                          Text(
                            "Langkah Sesi Sebelumnya :",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Text(
                        "$_previousSteps",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: _buildMetricsCard(
                label: "Jarak",
                value: "${distance.toStringAsFixed(1)} km",
                icon: Icons.map_outlined,
                iconColor: Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricsCard(
                label: "Terbakar",
                value: "$calories kcal",
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),

        const Text(
          "LANGKAH PER HARI",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87, letterSpacing: 0.5),
        ),
        const SizedBox(height: 15),
        
        Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarGraph("Senin", 0.2),
              _buildBarGraph("Selasa", 0.5),
              _buildBarGraph("Rabu", progressPercent),
              _buildBarGraph("Kamis", 0.4),
              _buildBarGraph("Jumat", 0.6),
              _buildBarGraph("Sabtu", 0.1),
              _buildBarGraph("Minggu", 0.3),
            ],
          ),
        ),
        const SizedBox(height: 25),

            // === SELEP KODE TOMBOL INI ===
            ElevatedButton.icon(
              onPressed: _simulateStepWalk,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 1,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text("Simulasi +500 Langkah (Demo)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1E88E5), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tips Hari Ini",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Berjalan kaki 10 menit setelah makan membantu mengontrol kadar gula darah kamu lho!",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            radius: 20,
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarGraph(String time, double heightPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 100 * heightPercentage, 
          width: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1E88E5).withOpacity(0.4), const Color(0xFF1E88E5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ],
    );
  }
}