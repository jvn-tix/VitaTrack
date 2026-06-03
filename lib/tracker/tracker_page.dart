import 'package:flutter/material.dart';
import 'heartrate_page.dart';
import 'sleeptracker_page.dart';
import 'steptracker_page.dart';


enum TrackerView { menuUtama, langkahDetail, jantungDetail, tidurDetail }

class TrackerPage extends StatefulWidget {
  final int currentSteps;                                
  final int targetSteps;
  final int currentBPM;
  final int currentSleep;
  final ValueChanged<int> onStepsChanged;
  final ValueChanged<int> onBPMChanged;             
  final ValueChanged<int> onSleepChanged;
  const TrackerPage({super.key, required this.currentSteps, required this.targetSteps, required this.currentBPM, required this.currentSleep ,required this.onStepsChanged, required this.onBPMChanged, required this.onSleepChanged}); 

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final Color primaryColor = const Color(0xFF1E88E5);
  TrackerView _currentView = TrackerView.menuUtama;


  @override
  Widget build(BuildContext context) {

    bool isMenuUtama = _currentView == TrackerView.menuUtama;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      
      appBar: isMenuUtama
          ? null 
          : AppBar(
              backgroundColor: primaryColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _currentView = TrackerView.menuUtama;
                  });
                },
              ),
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
      
      body: _buildCurrentBody(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case TrackerView.langkahDetail:
        return "Langkah Kaki";
      case TrackerView.jantungDetail:
        return "Detak Jantung";
      case TrackerView.tidurDetail:
        return "Tidur Malam";
      case TrackerView.menuUtama:
      default:
        return "Pilih Tracker";
    }
  }

  Widget _buildCurrentBody() {
    switch (_currentView) {
      case TrackerView.langkahDetail:
        return _buildStepDetailContent();
      case TrackerView.jantungDetail:
        return _buildHeartDetailContent();
      case TrackerView.tidurDetail:
        return _buildSleepDetailContent();
      case TrackerView.menuUtama:
      default:
        return _buildMainMenuContent();
    }
  }

  Widget _buildMainMenuContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      children: [
        Text(
          "Ringkasan Aktivitas",
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey[400],
            letterSpacing: 0.5
          ),
        ),
        const SizedBox(height: 12),

        _buildModernRowCard(
          title: "Step Tracker",
          subtitle: "Aktivitas Hari Ini",
          valueText: "${widget.currentSteps}",
          unitText: " langkah",
          icon: Icons.directions_walk_rounded,
          baseColor: Colors.orange,
          onTap: () {
            setState(() {
              _currentView = TrackerView.langkahDetail;
            });
          },
        ),
        const SizedBox(height: 18),

        _buildModernRowCard(
          title: "Heart Rate Tracker",
          subtitle: "Detak Jantung",
          valueText: "${widget.currentBPM}",
          unitText: " bpm",
          icon: Icons.favorite_rounded,
          baseColor: Colors.redAccent,
          onTap: () {
            setState(() {
              _currentView = TrackerView.jantungDetail;
            });
          },
        ),
        const SizedBox(height: 18),

        _buildModernRowCard(
          title: "Sleep Tracker",
          subtitle: "Durasi Istirahat",
          valueText: "${widget.currentSleep}",
          unitText: "",
          icon: Icons.nights_stay_rounded,
          baseColor: Colors.indigo,
          onTap: () {
            setState(() {
              _currentView = TrackerView.tidurDetail;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModernRowCard({
    required String title,
    required String subtitle,
    required String valueText,
    required String unitText,
    required IconData icon,
    required Color baseColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.06), 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: baseColor.withOpacity(0.1),
          highlightColor: baseColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: baseColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800]),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        textBaseline: TextBaseline.alphabetic,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: [
                          Text(
                            valueText,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: baseColor),
                          ),
                          Text(
                            unitText,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: baseColor.withOpacity(0.5),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDetailContent() {
    return StepTrackerDetail(currentSteps: widget.currentSteps, targetSteps: widget.targetSteps, onStepsChanged: widget.onStepsChanged,);
  }

  Widget _buildHeartDetailContent() {
    return HeartRateDetail(currentBPM: widget.currentBPM, onBPMChanged: widget.onBPMChanged);
  }

  Widget _buildSleepDetailContent() {
    return SleepTrackerDetail(currentSleep: widget.currentSleep,onSleepChanged: widget.onSleepChanged,);
  }
}