import 'package:flutter/material.dart';
import 'package:vita_track_2/services/api_service.dart';

class FoodLogManualPage extends StatefulWidget {
  final ValueChanged<int>? onTotalCaloriesChanged;
  const FoodLogManualPage({super.key, this.onTotalCaloriesChanged});

  @override
  State<FoodLogManualPage> createState() => _FoodLogManualPageState();
}

class _FoodLogManualPageState extends State<FoodLogManualPage> {
  final Color primaryColor = const Color(0xFF1E88E5);
  int _currentNavIndex = 1; 
  bool isManual = true;
  int _waterAmount = 0;

  List<Map<String, dynamic>> addedFoods = [];
  List<dynamic> masterFoodsFromDB = [];
  List<dynamic> searchResults = [];
  List<dynamic> scannedResults = []; 

  bool _isScanning = false;
  bool _isLoadingMaster = true;

  @override
  void initState() {
    super.initState();
    _loadFoodDataFromBackend();
  }

  void _notifyCaloriesChanged() {
    widget.onTotalCaloriesChanged?.call(_calculateTotalKcal());
  }

  void _removeFood(int index) {
    String foodName = addedFoods[index]["title"];
    setState(() {
      addedFoods.removeAt(index);
    });
    _notifyCaloriesChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$foodName dihapus"), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _loadFoodDataFromBackend() async {
    setState(() => _isLoadingMaster = true);
    
    List<dynamic> masterList = await ApiService.getFoodMasterList();
    List<dynamic> logsList = await ApiService.getFoodLogs();
    
    setState(() {
      masterFoodsFromDB = masterList;
      
      // UBAH BAGIAN INI: Agar saat pertama kali load, list hasil pencarian langsung berisi SEMUA makanan
      searchResults = masterList; 
      
      addedFoods = List<Map<String, dynamic>>.from(logsList.map((item) => {
        "title": item["title"],
        "kcal": (item["kcal"] as num).toInt(),
        "time": item["time"],
        "tag": item["tag"],
      }));
      _isLoadingMaster = false;
    });
  }


  int _calculateTotalKcal() {
    int total = 0;
    for (var food in addedFoods) {
      total += (food["kcal"] as num).toInt(); 
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: IndexedStack(
        index: _currentNavIndex,
        children: [
          const Center(child: Text("Halaman Home")),
          _buildFoodContent(),
          const Center(child: Text("Halaman Tracker")),
          const Center(child: Text("Halaman Advice")),
          const Center(child: Text("Halaman Profile")),
        ],
      ),
    );
  }

  void _addNewFoodLog(String title, int kcal, String time, String tag) async {
    // 1. Kirim ke backend terlebih dahulu
    bool isSaved = await ApiService.sendFoodLog(title, kcal, time, tag);
    
    if (isSaved) {
      // 2. Jika sukses tersimpan di MySQL, update UI lokal Flutter
      setState(() {
        addedFoods.add({
          "title": title,
          "kcal": kcal,
          "time": time,
          "tag": tag,
        });
      });
      _notifyCaloriesChanged();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil mencatat makanan $title ke database!")),
      );
    }
  }

  // TAMBAHKAN KODE BARU INI TEPAT DI BAWAH _loadFoodDataFromBackend
  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = masterFoodsFromDB;
      });
      return;
    }

    setState(() {
      searchResults = masterFoodsFromDB
          .where((food) => food["title"]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _simulateImageScan() async {
    setState(() {
      _isScanning = true;
      scannedResults.clear();
    });

    // Simulasi loading AI membaca gambar selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // AI mendeteksi komponen makanan: "Nasi", "Ayam", "Kangkung", "Sambal"
      // Kita filter dari masterFoodsFromDB yang namanya mengandung kata tersebut
      scannedResults = masterFoodsFromDB.where((food) {
        String title = food["title"].toString().toLowerCase();
        return title.contains("nasi") || 
               title.contains("ayam") || 
               title.contains("gandum") || // opsional sesuai dummy data DB-mu
               title.contains("salad");
      }).toList();

      _isScanning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Scan selesai! Menu berhasil terdeteksi.")),
    );
  }

  Widget _buildFoodContent() {
    return Column(
      children: [
        Container(
          color: primaryColor,
          child: Row(
            children: [
              _buildTabHeader("Manual", isActive: isManual, onTap: () => setState(() => isManual = true)),
              _buildTabHeader("Scan Foto", isActive: !isManual, onTap: () => setState(() => isManual = false)),
            ],
          ),
        ),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Kalori Hari Ini", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("${_calculateTotalKcal()} kcal", style: TextStyle(color: primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.analytics_rounded, color: primaryColor, size: 40),
                onPressed: () => _showNutrientSummary(context), // Ini akan memanggil pop-up
              ),
            ],
          ),
        ),

        Expanded(
          child: isManual ? _buildManualTab() : _buildScanTab(),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 25),
        const Text('HASIL PENCARIAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),

        _isLoadingMaster 
            ? const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            : searchResults.isEmpty 
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Makanan tidak ditemukan", style: TextStyle(color: Colors.grey)),
                  )
                : Column(
                    children: searchResults.map((food) {
                      return _buildSearchItem(
                        food["title"], 
                        (food["kcal"] as num).toInt()
                      );
                    }).toList(),
                  ),

        const SizedBox(height: 25),          
        const Text('DITAMBAHKAN HARI INI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        
        ...addedFoods.asMap().entries.map((entry) {
          int idx = entry.key;
          var food = entry.value;
          return _buildAddedRow(idx, food["title"], "${food["time"]} - ${food["kcal"]} kcal", food["tag"]);
        }).toList(),
        
        const SizedBox(height: 30),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildAddedRow(int index, String title, String sub, String tag) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Text(tag, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
            onPressed: () => _removeFood(index), // Memanggil fungsi hapus
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem(String title, int kcal) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("$kcal kcal"),
      trailing: IconButton(
        icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
        onPressed: () => _addNewFoodLog(title, kcal, "Baru saja", "Normal"),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: TextField(onChanged: _filterSearchResults,decoration: InputDecoration(hintText: 'Cari makanan', prefixIcon: Icon(Icons.search), border: InputBorder.none)),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log makanan tersimpan')),
          );
        }, 
        child: const Text('Simpan Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildScanTab() {
  return ListView(
    padding: const EdgeInsets.all(20),
    children: [
      GestureDetector(
          onTap: _isScanning ? null : _simulateImageScan,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isScanning ? Icons.sync_rounded : Icons.cloud_upload_outlined, 
                  size: 45, 
                  color: primaryColor
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? "sedang memindai gambar..." : "unggah gambar untuk scan", 
                  style: TextStyle(color: primaryColor, decoration: TextDecoration.underline, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text('Menu yang terdeteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        
        // MENAMPILKAN HASIL SCAN DINAMIS DARI DATABASE MASTER
        _isScanning 
            ? const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))
            : scannedResults.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("Belum ada gambar yang di-scan atau menu tidak dikenali", style: TextStyle(color: Colors.grey))),
                  )
                : Column(
                    children: scannedResults.map((food) {
                      return _buildScanResultItem(
                        food["title"], 
                        "1 porsi", 
                        (food["kcal"] as num).toInt(), 
                        food["tag"], 
                        Colors.green
                      );
                    }).toList(),
                  ),
        
        const SizedBox(height: 30),
        _buildSaveButton(),
      ],
    );
}

Widget _buildScanResultItem(String title, String porsi, int kcal, String tag, Color color) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$porsi - $kcal kcal"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Text(tag, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle, color: primaryColor, size: 28),
              onPressed: () => _addNewFoodLog(title, kcal, "Baru saja", tag), // Fungsi tambah yang sama dengan manual
            ),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

  void _showNutrientSummary(BuildContext context) {
  const int targetKcal = 2000;
    int consumedKcal = _calculateTotalKcal();
    int remainingKcal = targetKcal - consumedKcal;
    if (remainingKcal < 0) remainingKcal = 0; 

    double progressValue = consumedKcal / targetKcal;
    if (progressValue > 1.0) progressValue = 1.0;

    double karboGram = (consumedKcal * 0.50) / 4; 
    double proteinGram = (consumedKcal * 0.30) / 4; 
    double lemakGram = (consumedKcal * 0.20) / 9; 

    double karboProgress = karboGram / 250; 
    double proteinProgress = proteinGram / 100; 
    double lemakProgress = lemakGram / 65; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Ringkasan gizi",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180, height: 180,
                          child: CircularProgressIndicator(
                            value: progressValue, 
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("$consumedKcal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                            Text("/ $targetKcal kcal", style: const TextStyle(color: Colors.grey, fontSize: 14)), 
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // ====== 📦 BAGIAN BARU: CARD INFORMASI RINGKASAN KALORI ======
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCalorieStat("Terpakai", "$consumedKcal", primaryColor),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildCalorieStat("Sisa", "$remainingKcal", Colors.blue.shade300),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        _buildCalorieStat("Terbakar", "420", Colors.green.shade600),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Text("MAKRONUTRIEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                  const SizedBox(height: 15),
                  
                  _buildMacroBar("Karbohidrat", karboProgress.clamp(0.0, 1.0), "${karboGram.toStringAsFixed(1)}g", primaryColor),
                  _buildMacroBar("Protein", proteinProgress.clamp(0.0, 1.0), "${proteinGram.toStringAsFixed(1)}g", Colors.greenAccent),
                  _buildMacroBar("Lemak", lemakProgress.clamp(0.0, 1.0), "${lemakGram.toStringAsFixed(1)}g", Colors.orangeAccent),
                  
                  const SizedBox(height: 25),
                  _buildBottomCard("Serat", "${(consumedKcal * 0.015).toStringAsFixed(1)}g", Colors.black87),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setModalState) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Air", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text("${(_waterAmount / 1000).toStringAsFixed(1)}L", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: primaryColor, size: 30),
                                  onPressed: () {
                                    // Mengupdate state utama halaman dan state modal sekaligus
                                    setState(() { _waterAmount += 250; });
                                    setModalState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi baru untuk menampilkan data teks di dalam Card secara horizontal
  Widget _buildCalorieStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text("$value kcal", style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double val, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(amount, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: val,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard(String label, String value, Color vColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: vColor)),
        ],
      ),
    );
  }

  Widget _buildTabHeader(String title, {required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: isActive ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)) : null,
          ),
          child: Text(title, textAlign: TextAlign.center, style: TextStyle(color: isActive ? primaryColor : Colors.white70, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

}