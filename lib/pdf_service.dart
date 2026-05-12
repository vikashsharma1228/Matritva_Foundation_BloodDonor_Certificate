import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Update: Ab ye Donor object ya saare fields lega
Future<void> sendCertificateToBackend(Uint8List pdfBytes, var donor) async {
  var url = Uri.parse('http://localhost:8080/api/donors/send-certificate');

  try {
    var request = http.MultipartRequest('POST', url);

    // --- YE SAARE FIELDS BACKEND KE @RequestParam SE MATCH HONA ZAROORI HAI ---
    // pdf_service.dart mein replace karein
    request.fields['email'] =
        donor['email'] ?? ""; // donor.email ki jagah donor['email']
    request.fields['name'] = donor['fullName'] ?? "";
    request.fields['location'] = donor['location'] ?? "";
    request.fields['donationDate'] = donor['donationDate'] ?? "";
    request.fields['donationCount'] = (donor['donationCount'] ?? 0).toString();
    // PDF file bytes
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: 'Certificate_${donor['fullName']?.replaceAll(' ', '_') ?? 'Donor'}.pdf',
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      debugPrint("Zabardast! Mail successfully chala gaya.");
    } else {
      // Isse aapko exact error pata chalega ki backend kya bol raha hai
      final respStr = await response.stream.bytesToString();
      debugPrint("Oops! Status: ${response.statusCode}, Error: $respStr");
    }
  } catch (e) {
    debugPrint("Error connecting to server: $e");
  }
}
