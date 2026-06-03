import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vita_track_2/services/api_service.dart';

class SleepTrackerDetail extends StatefulWidget {
  final int currentSleep;                       
  final ValueChanged<int> onSleepChanged;

  const SleepTrackerDetail({super.key, required this.currentSleep, required this.onSleepChanged});

  @override
  State<SleepTrackerDetail> createState() => _SleepTrackerDetailState();
}

class _SleepTrackerDetailState extends State<SleepTrackerDetail> {
  String _sleepDuration = "--";
  int _sleepScore = 0;
  String _sleepQuality = "-";
  
  bool _isConnected = false;
  bool _isScanning = false;
  String _connectedDeviceName = "";

  String _deepSleepTime = "0j 00m";
  String _lightSleepTime = "0j 00m";
  String _remSleepTime = "0j 00m";
  String _awakeCount = "0 kali";

  final List<Map<String, String>> _dummyDevices = [
    {"name": "Galaxy Watch 6 Mini", "mac": "7A:9B:C1:23:D4:E5"},
    {"name": "Mi Smart Band 8", "mac": "94:E6:B6:88:DF:11"},
    {"name": "Apple Watch Series 9", "mac": "AC:22:03:77:FF:AA"},
    {"name": "Garmin Forerunner 55", "mac": "3C:D9:2B:11:88:BC"},
  ];

  void _showDeviceScanDialog() {
    setState(() => _isScanning = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Loading spinner tiruan selama 2.5 detik
            if (_isScanning) {
              Timer(const Duration(milliseconds: 2500), () {
                if (mounted) {
                  setDialogState(() => _isScanning = false);
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(_isScanning ? Icons.bluetooth_searching_rounded : Icons.bluetooth_connected_rounded, color: const Color(0xFF1E88E5)),
                  const SizedBox(width: 10),
                  Text(_isScanning ? "Mencari Perangkat..." : "Perangkat Ditemukan"),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 200,
                child: _isScanning
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(strokeWidth: 3),
                            SizedBox(height: 15),
                            Text("Pastikan Bluetooth Smartwatch aktif", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _dummyDevices.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.watch_rounded, color: Colors.black87),
                            title: Text(_dummyDevices[index]["name"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(_dummyDevices[index]["mac"]!, style: const TextStyle(fontSize: 11)),
                            trailing: const Text("Hubungkan", style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold, fontSize: 12)),
                            onTap: () {
                              Navigator.pop(context); // Tutup dialog
                              _connectToDeviceMock(_dummyDevices[index]["name"]!);
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _isScanning = false);
                  },
                  child: const Text("Batal", style: TextStyle(color: Colors.redAccent)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _connectToDeviceMock(String deviceName) async{
    // 1. Deklarasikan variabel penampung data simulasi
    double simulatedHours;
    String dbQuality;
    
    String durationText;
    int score;
    String qualityText;
    String deepText;
    String lightText;
    String remText;
    String awakeText;

    // 2. Percabangan Kondisi Perangkat untuk Demo
    if (deviceName == "Galaxy Watch 6 Mini" || deviceName == "Apple Watch Series 9") {
      // KONDISI A: TIDUR CUKUP (Memenuhi Target harian 8 Jam)
      simulatedHours = 7.75; // 7 jam 45 menit (Dibulatkan .round() jadi 8 di HomePage)
      dbQuality = "Good";
      
      durationText = "7j 45m";
      score = 88;
      qualityText = "Sangat Baik";
      deepText = "2j 15m";
      lightText = "4j 30m";
      remText = "1j 00m";
      awakeText = "0 kali";
    } else {
      // KONDISI B: KURANG TIDUR (Di bawah Target - Contoh: Mi Band atau Garmin)
      simulatedHours = 4.5; // 4 jam 30 menit (Dibulatkan .round() jadi 5 di HomePage)
      dbQuality = "Poor";
      
      durationText = "4j 30m";
      score = 45;
      qualityText = "Kurang Istirahat";
      deepText = "0j 45m";
      lightText = "3j 15m";
      remText = "0j 30m";
      awakeText = "3 kali";
    }

    setState(() {
      _isConnected = true;
      _connectedDeviceName = deviceName;
      
      _sleepDuration = durationText;
      _sleepScore = score;
      _sleepQuality = qualityText;
      
      _deepSleepTime = deepText;
      _lightSleepTime = lightText;
      _remSleepTime = remText;
      _awakeCount = awakeText;
    });

    bool isSaved = await ApiService.sendSleepData(simulatedHours, dbQuality);
    if (isSaved) {
      print("Berhasil menyimpan data tidur ke MySQL.");
    }

    widget.onSleepChanged(simulatedHours.round());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              simulatedHours >= 7 ? Icons.check_circle : Icons.warning_amber_rounded, 
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text("Data sinkron dari $deviceName! (${simulatedHours >= 7 ? 'Tidur Cukup' : 'Kurang Tidur'})"),
            ),
          ],
        ),
        backgroundColor: simulatedHours >= 7 ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _disconnectDevice() {
    setState(() {
      _isConnected = false;
      _connectedDeviceName = "";
      
      _sleepDuration = "0j 00m";
      _sleepScore = 0;
      _sleepQuality = "-";
      
      _deepSleepTime = "0j 00m";
      _lightSleepTime = "0j 00m";
      _remSleepTime = "0j 00m";
      _awakeCount = "0 kali";
    });

    widget.onSleepChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      children: [
        // AREA STATUS KONEKSI SMARTWATCH (Sama Persis dengan Desain Heart Rate)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isConnected ? Colors.green.withOpacity(0.06) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                _isConnected ? Icons.watch_rounded : Icons.watch_off_rounded,
                color: _isConnected ? Colors.green : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isConnected ? "Smartwatch Terhubung" : "Smartwatch Terputus",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      _isConnected ? _connectedDeviceName : "Koneksikan jam kamu untuk sinkronisasi tidur",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isConnected ? _disconnectDevice : _showDeviceScanDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.redAccent : const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(_isConnected ? "Putus" : "Scan Jam", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Center(
          child: Column(
            children: [
              Text(
                _isConnected ? "Data Sinkron ($_connectedDeviceName)" : "Durasi Tidur Semalam",
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Text(
                _sleepDuration,
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF1E88E5)),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Skor Tidur: $_sleepScore/100 ($_sleepQuality)",
                  style: const TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),

        const Text(
          "FASE TIDUR JANGKA PANJANG",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87, letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSleepBar("Sen", 0.3, 0.5, 0.15),
                  _buildSleepBar("Sel", 0.25, 0.55, 0.1),
                  _buildSleepBar("Rab", 0.35, 0.45, 0.15),
                  _buildSleepBar("Kam", 0.2, 0.6, 0.1),
                  _buildSleepBar("Jum", 0.3, 0.5, 0.15),
                  _buildSleepBar("Sab", 0.15, 0.5, 0.25),
                  _buildSleepBar("Min", _isConnected ? 0.32 : 0.27, _isConnected ? 0.61 : 0.59, _isConnected ? 0.15 : 0.14), 
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendCircle(Colors.indigo, "Deep"),
                  const SizedBox(width: 15),
                  _buildLegendCircle(Colors.blue, "Light"),
                  const SizedBox(width: 15),
                  _buildLegendCircle(Colors.purpleAccent, "REM"),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 25),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.1,
          children: [
            _buildSleepStatCard("Deep Sleep", _deepSleepTime, Colors.indigo),
            _buildSleepStatCard("Light Sleep", _lightSleepTime, Colors.blue),
            _buildSleepStatCard("REM Sleep", _remSleepTime, Colors.purpleAccent),
            _buildSleepStatCard("Terbangun", _awakeCount, Colors.orange),
          ],
        ),
        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Warna background container berubah agak orange jika skor tidur rendah
            color: _isConnected 
                ? (_sleepScore >= 70 ? Colors.indigo.withOpacity(0.04) : Colors.orange.withOpacity(0.05))
                : Colors.indigo.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rekomendasi Istirahat",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13, 
                  // Judul teks berubah orange jika kurang tidur
                  color: _isConnected && _sleepScore < 70 ? Colors.orange[800] : Colors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isConnected 
                    ? (_sleepScore >= 70 
                        ? "Tidurmu sangat berkualitas menggunakan $_connectedDeviceName. Pertahankan ritme tidur ini." 
                        : "Durasi tidurmu kurang dari target harian. Kurangi begadang dan cobalah untuk tidur lebih awal malam ini.")
                    : "Jadwal tidur kamu sudah konsisten. Pertahankan jam tidur yang sama malam ini untuk menjaga kebugaran tubuh.",
                style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepStatCard(String label, String value, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.005), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor)),
        ],
      ),
    );
  }

  Widget _buildSleepBar(String day, double deep, double light, double rem) {
  double maxHeight = 80.0;
  
  double total = deep + light + rem;
  double normalizedDeep = deep / total;
  double normalizedLight = light / total;
  double normalizedRem = rem / total;

  return Column(
    children: [
      Container(
        width: 14,
        height: maxHeight,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: maxHeight * normalizedRem, 
              width: 14, 
              decoration: const BoxDecoration(
                color: Colors.purpleAccent, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(8))
              )
            ),
            Container(
              height: maxHeight * normalizedLight, 
              width: 14, 
              color: Colors.blue
            ),
            Container(
              height: maxHeight * normalizedDeep, 
              width: 14, 
              decoration: const BoxDecoration(
                color: Colors.indigo, 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))
              )
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(day, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
    ],
  );
}

  Widget _buildLegendCircle(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
      ],
    );
  }
}