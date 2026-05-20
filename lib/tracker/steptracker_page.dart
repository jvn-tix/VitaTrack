import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerDetail extends StatefulWidget {
  const StepTrackerDetail({super.key});

  @override
  State<StepTrackerDetail> createState() => _StepTrackerDetailState();
}

class _StepTrackerDetailState extends State<StepTrackerDetail> {
  late Stream<StepCount> _stepCountStream;
  
  int _currentSteps = 0; 
  int _targetSteps = 10000; 

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _currentSteps = event.steps > 0 ? event.steps : 6240; 
    });
  }

  void _onStepCountError(error) {
    print("Gagal mengakses sensor pedometer: $error");
    setState(() {
      _currentSteps = 6240; 
    });
  }

  double _calculateDistance(int steps) {
    return steps * 0.00075;
  }

  int _calculateCalories(int steps) {
    return (steps * 0.04).round();
  }

  @override
  Widget build(BuildContext context) {
    double distance = _calculateDistance(_currentSteps);
    int calories = _calculateCalories(_currentSteps);
    double progressPercent = (_currentSteps / _targetSteps).clamp(0.0, 1.0);

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
                "$_currentSteps",
                style: const TextStyle(
                  fontSize: 56, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF1E88E5),
                  letterSpacing: -1
                ),
              ),
              Text(
                "dari target $_targetSteps langkah",
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
          "LANGKAH PER JAM",
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
              _buildBarGraph("06:00", 0.2),
              _buildBarGraph("09:00", 0.5),
              _buildBarGraph("12:00", 0.8),
              _buildBarGraph("15:00", 0.4),
              _buildBarGraph("18:00", 0.6),
              _buildBarGraph("21:00", 0.1),
            ],
          ),
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