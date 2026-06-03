import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan IP 10.0.2.2 untuk emulator Android, atau IP laptop jika pakai HP fisik
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static String? token;

  // ==========================================
  // ====== FUNGSI AUTHENTICATION =============
  // ==========================================

  // Fungsi Login (Diarahkan ke rute /auth/login milik server.js)
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // SINKRON: Tambah /auth
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username' : username.toLowerCase(), 
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token!);
        print("Login Berhasil, Token disimpan: $token");
        return true;
      } else {
        print("Login Gagal, Status Code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error Login: $e");
      return false;
    }
  }

  // Fungsi Register (Diarahkan ke rute /auth/register milik server.js)
  static Future<bool> register(String name, String email, String username, String password, int age) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'), // SINKRON: Tambah /auth
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email.toLowerCase(),
          'username': username.toLowerCase(),
          'password': password,
          'age': age,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Register: $e");
      return false;
    }
  }

  // Fungsi untuk mengambil data profil user yang sedang login
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString('auth_token');

      // Jika di HP tidak ada token, batalkan request ke backend
      if (savedToken == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $savedToken', // Kirim token lewat Header HTTP
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Mengembalikan object data dari backend
      }
      return null;
    } catch (e) {
      print("Error getProfile: $e");
      return null;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Hapus token dari memori HP
    token = null;
  }


  // ==========================================
  // ====== FUNGSI TRACKER (POST & GET) ======
  // ==========================================

  // --- 1. FITUR LANGKAH KAKI (STEPS) ---
  static Future<bool> sendSteps(int steps) async {
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracker/steps'), // Tetap /tracker/steps
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'steps': steps}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error sendSteps: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getSteps() async {
    if (token == null) throw Exception("Token tidak ditemukan");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/steps'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data steps");
      }
    } catch (e) {
      print("Error getSteps: $e");
      return [];
    }
  }

  static Future<int> getLastStepData() async {
    if (token == null) throw Exception("Token tidak ditemukan");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/steps'), // Mengambil daftar steps dari backend
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', //
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        
        // Jika di database sudah ada datanya, ambil data baris paling terakhir
        if (data.isNotEmpty) {
          // data.last mengambil baris terakhir, ['steps'] mengambil angka langkahnya
          return data.last['steps'] ?? 0; 
        }
        
        // Jika data di database masih kosong (user baru), kembalikan nilai 0 atau 6240 buat dummy awal
        return 0; 
      } else {
        throw Exception("Gagal mengambil data riwayat steps");
      }
    } catch (e) {
      print("Error getLastStepData: $e");
      return 6240; // Fallback jika server mati atau ada error pas demo
    }
  }

  // --- 2. FITUR DETAK JANTUNG (HEART RATE) ---
  static Future<bool> sendHeartRateData(int bpm) async {
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracker/heartrate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bpm': bpm,
        }),
      );
      
      print("Status Code Send Heart Rate: ${response.statusCode}");
      return response.statusCode == 201;
    } catch (e) {
      print("Error sendHeartRateData: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getHeartRate() async {
    if (token == null) throw Exception("Token tidak ditemukan");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/heartrate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data heart rate");
      }
    } catch (e) {
      print("Error getHeartRate: $e");
      return [];
    }
  }

  // --- 3. FITUR POLA TIDUR (SLEEP) ---
  // SINKRONISASI: Disesuaikan dengan model Sleep di schema.prisma yang meminta 'hours' dan 'quality'
  static Future<bool> sendSleepData(double hours, String quality) async {
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracker/sleep'), // Tetap /tracker/sleep
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'hours': hours,     // contoh: 7.5
          'quality': quality, // contoh: "Good", "Bad", atau "Excellent"
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error sendSleepData: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getSleepData() async {
    if (token == null) throw Exception("Token tidak ditemukan");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/sleep'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data sleep");
      }
    } catch (e) {
      print("Error getSleepData: $e");
      return [];
    }
  }

  // --- 4. FITUR LOG MAKANAN (FOOD LOG) ---
  static Future<List<dynamic>> getFoodMasterList() async {
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/food-master'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error getFoodMasterList: $e");
      return [];
    }
  }

  // Simpan riwayat makanan baru ke database
  static Future<bool> sendFoodLog(String title, int kcal, String time, String tag) async {
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tracker/food-log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'kcal': kcal,
          'time': time,
          'tag': tag,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error sendFoodLog: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getFoodLogs() async {
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tracker/food-log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Error getFoodLogs: $e");
      return [];
    }
  }
}