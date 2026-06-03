import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vita_track_2/services/api_service.dart';

class HeartRateDetail extends StatefulWidget {
  final int currentBPM; // <--- TAMBAHKAN BARIS INI
  final ValueChanged<int> onBPMChanged; // <--- TAMBAHKAN BARIS INI

  const HeartRateDetail({
    super.key,
    required this.currentBPM, // <--- TAMBAHKAN BARIS INI
    required this.onBPMChanged, // <--- TAMBAHKAN BARIS INI
  });

  @override
  State<HeartRateDetail> createState() => _HeartRateDetailState();
}

class _HeartRateDetailState extends State<HeartRateDetail> {
  final List<int> _bpmHistory = [68, 72, 75, 70, 69, 71];
  
  bool _isConnected = false;
  bool _isScanning = false;
  bool _isLiveTracking = false;
  String _connectedDeviceName = "";
  Timer? _liveDataTimer;

  int _lowestBPM = 65;
  int _highestBPM = 110;
  int _averageBPM = 72;

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
                              Navigator.pop(context); 
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

  void _connectToDeviceMock(String deviceName) {
    setState(() {
      _isConnected = true;
      _connectedDeviceName = deviceName;
      _isLiveTracking = true;
    });

    _liveDataTimer?.cancel();
    _liveDataTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) return;
      final random = Random();
      
      // LOGIKA VARIASI DATA UNTUK TRIK DEMO SEPERTI YANG KITA BAHAS
      int simulatedLiveBPM = 72;
      if (deviceName.contains("Galaxy Watch")) {
        simulatedLiveBPM = 65 + random.nextInt(15); // Range rileks: 65 - 80 BPM
      } else if (deviceName.contains("Mi Smart Band")) {
        simulatedLiveBPM = 92 + random.nextInt(20); // Range olahraga ringan: 92 - 112 BPM
      } else {
        simulatedLiveBPM = 70 + random.nextInt(21); // Default range: 70 - 91 BPM
      }

      // 1. Kirim data ke database terlebih dahulu menggunakan variabel lokal langsung (pasti akurat)
      bool isSaved = await ApiService.sendHeartRateData(simulatedLiveBPM);
      
      if (isSaved) {
        print("Berhasil menyimpan $simulatedLiveBPM BPM ke database MySQL!");
      } else {
        print("Gagal menyimpan data ke backend. Periksa log terminal backend Anda!");
      }

      // 2. Lakukan pembaruan UI jika widget masih terpasang (mounted)
      if (mounted) {
        // Beritahu parent widget mengenai perubahan nilai detak jantung terbaru
        widget.onBPMChanged(simulatedLiveBPM);
        
        setState(() {
          // Ganti 'widget.currentBPM' dengan variabel lokal 'simulatedLiveBPM'
          _bpmHistory.add(simulatedLiveBPM); 
          
          if (_bpmHistory.length > 6) _bpmHistory.removeAt(0);
          
          _lowestBPM = _bpmHistory.reduce(min);
          _highestBPM = _bpmHistory.reduce(max);
          _averageBPM = (_bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length).round();
        });
      }
    });
  }

  void _disconnectDevice() {
    _liveDataTimer?.cancel();
    widget.onBPMChanged(72);
    setState(() {
      _isConnected = false;
      _isLiveTracking = false;
      _connectedDeviceName = "";
    });
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      children: [
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
                      _isConnected ? _connectedDeviceName : "Koneksikan jam kamu untuk data real-time",
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
                _isLiveTracking ? "Detak Jantung Live (Smartwatch)" : "Detak saat ini",
                style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                   widget.currentBPM == 0 ? "--" : "${widget.currentBPM}",
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFF1E88E5)),
                  ),
                  const Text(" bpm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
              
              if (_isLiveTracking)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Sinkronisasi lancar...",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(30)),
                  child: const Text("Hubungkan Jam untuk Mengukur", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 35),

        const Text("Riwayat hari ini", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_bpmHistory.length, (index) {
              List<String> times = ["06:00", "09:00", "12:00", "15:00", "18:00", "21:00"];
              String timeLabel = index < times.length ? times[index] : "Live";
              
              double heightPercent = _bpmHistory[index] / 110.0;
              if (heightPercent > 1.0) heightPercent = 1.0;

              return _buildSimpleBar(timeLabel, heightPercent, _bpmHistory[index]);
            }),
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
            _buildStatCard("Terendah", "$_lowestBPM bpm", Colors.blue),
            _buildStatCard("Tertinggi", "$_highestBPM bpm", Colors.red),
            _buildStatCard("Rata-rata", "$_averageBPM bpm", Colors.orange),
            _buildStatCard("HRV", "46ms", Colors.purple),
          ],
        ),
        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Data Terintegrasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E88E5))),
              const SizedBox(height: 4),
              Text("Aplikasi otomatis membaca statistik detak jantung dari sensor optik smartwatch Anda.", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSimpleBar(String time, double heightPercent, int bpmValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("$bpmValue", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          height: 70 * heightPercent,
          width: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withOpacity(heightPercent > 0.6 ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ],
    );
  }
}