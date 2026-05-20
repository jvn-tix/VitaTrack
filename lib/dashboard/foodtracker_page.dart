import 'package:flutter/material.dart';

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

  List<Map<String, dynamic>> addedFoods = [
    {"title": "Oatmeal + susu", "kcal": 320, "time": "Pagi", "tag": "Sehat"},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTotalCaloriesChanged?.call(_calculateTotalKcal());
    });
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

  void _addFood(String title, int kcal) {
    setState(() {
      addedFoods.add({
        "title": title,
        "kcal": kcal,
        "time": "Baru saja",
        "tag": "Normal",
      });
    });
    _notifyCaloriesChanged();
  }

  int _calculateTotalKcal() {
    return addedFoods.fold(0, (sum, item) => sum + (item["kcal"] as int));
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
        _buildSearchItem("Nasi Putih", 130),
        _buildSearchItem("Ayam Goreng", 246),
        _buildSearchItem("Cempedak", 125),
        
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
        onPressed: () => _addFood(title, kcal),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: const TextField(decoration: InputDecoration(hintText: 'Cari makanan', prefixIcon: Icon(Icons.search), border: InputBorder.none)),
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
      Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 45, color: primaryColor),
            const SizedBox(height: 8),
            Text("unggah gambar", style: TextStyle(color: primaryColor, decoration: TextDecoration.underline, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      const SizedBox(height: 25),
      const Text('Menu yang terdeteksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 10),
      
      _buildScanResultItem("Nasi Putih", "1 porsi (100g)", 130, "Sehat", Colors.green),
      _buildScanResultItem("Ayam Bakar Dada", "1 potong", 165, "Sehat", Colors.green),
      _buildScanResultItem("Tumis Kangkung", "1 porsi", 45, "Sehat", Colors.green),
      _buildScanResultItem("Sambal Terasi", "1 sdm", 25, "Normal", Colors.orange), // Tambahan dari gambar adf1d7
      
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
              onPressed: () => _addFood(title, kcal), // Fungsi tambah yang sama dengan manual
            ),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

  void _showNutrientSummary(BuildContext context) {
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
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
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
                          value: 0.7,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${_calculateTotalKcal()}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                          const Text("kcal", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                
                _buildLegendRow(primaryColor, "Terpakai ${_calculateTotalKcal()}"),
                _buildLegendRow(Colors.blue.shade100, "Sisa 360 kcal"),
                _buildLegendRow(Colors.greenAccent, "Terbakar 420"),
                
                const SizedBox(height: 35),
                Text("MAKRONUTRIEN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                const SizedBox(height: 15),
                
                _buildMacroBar("Karbohidrat", 0.65, "216g", primaryColor),
                _buildMacroBar("Protein", 0.45, "82g", Colors.greenAccent),
                _buildMacroBar("Lemak", 0.35, "45g", Colors.orangeAccent),
                
                const SizedBox(height: 25),
                _buildBottomCard("Serat", "18g", Colors.black87),
                const SizedBox(height: 12),
                _buildBottomCard("Air", "1.8L", primaryColor),
              ],
            ),
          ),
        ],
      ),
    ),
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