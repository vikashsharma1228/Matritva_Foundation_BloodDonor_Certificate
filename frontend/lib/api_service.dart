import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class ApiService {
  // Agar Android Emulator use kar rahe ho toh '10.0.2.2' use karo
  // Agar Real Device/Web hai toh apne Laptop ka IP address
  static const String baseUrl = "http://localhost:8080/api/donors";

  static Future<bool> registerDonor(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      dev.log("Error fetching data", error: e);
      return false;
    }
  }
}