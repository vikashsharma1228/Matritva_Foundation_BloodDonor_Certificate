import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // jsonEncode ke liye zaroori hai
import 'package:http/http.dart' as http;
import 'package:blood_donation_app/pdf_service.dart'; // http getter ke liye zaroori hai

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: BloodApp()),
);

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}

class BloodApp extends StatefulWidget {
  const BloodApp({super.key});
  @override
  State<BloodApp> createState() => _BloodAppState();
}

class _BloodAppState extends State<BloodApp> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  final fatherCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final donationDateCtrl = TextEditingController();
  final donationCountCtrl = TextEditingController();
  String? gender;
  String? bGroup;
  bool isLoading = false;

  Uint8List? fbBytes,
      instaBytes,
      phoneBytes,
      logoBytes,
      sidebarBytes,
      fontData,
      iconFontData,
      notoBytes,
      notoBoldBytes,
      notoItalicBytes;
  bool isAssetsLoaded = false;

  @override
  void initState() {
    super.initState();
    preloadAssets(); // App start hote hi load karo
  }

  Future<void> preloadAssets() async {
    // Saare assets ko ek saath load karein
    try {
      final results = await Future.wait([
        rootBundle.load('assets/facebook.png'),
        rootBundle.load('assets/insta.png'),
        rootBundle.load('assets/phone.jpg'),
        rootBundle.load('assets/logo.jpg'),
        rootBundle.load('assets/redcross.png'),
        rootBundle.load('assets/fonts/GreatVibes-Regular.ttf'),
        rootBundle.load('assets/fonts/MaterialIcons-Regular.ttf'),
        rootBundle.load('assets/fonts/NotoSerif-Regular.ttf'),
        rootBundle.load('assets/fonts/NotoSerif-Bold.ttf'),
        rootBundle.load('assets/fonts/NotoSerif-Italic.ttf'),
      ]);

      setState(() {
        fbBytes = results[0].buffer.asUint8List();
        instaBytes = results[1].buffer.asUint8List();
        phoneBytes = results[2].buffer.asUint8List();
        logoBytes = results[3].buffer.asUint8List();
        sidebarBytes = results[4].buffer.asUint8List();
        fontData = results[5].buffer.asUint8List();
        iconFontData = results[6].buffer.asUint8List();
        notoBytes = results[7].buffer.asUint8List();
        notoBoldBytes = results[8].buffer.asUint8List();
        notoItalicBytes = results[9].buffer.asUint8List();
        isAssetsLoaded = true;
      });
    } catch (e) {
      debugPrint("Asset loading error: $e");
    }
  }

  Future<Uint8List> generateCertificate(Map<String, dynamic> data) async {
    // Agar assets load nahi huye toh loading dikhayein ya wait karein
    if (!isAssetsLoaded) await preloadAssets();

    final baseFont = pw.Font.ttf(notoBytes!.buffer.asByteData());
    final boldFont = pw.Font.ttf(notoBoldBytes!.buffer.asByteData());
    final italicFont = pw.Font.ttf(notoItalicBytes!.buffer.asByteData());
    final fancyFont = pw.Font.ttf(fontData!.buffer.asByteData());
    final iconFont = pw.Font.ttf(iconFontData!.buffer.asByteData());
    final adarshSign = pw.MemoryImage(
      (await rootBundle.load('assets/adarsh_sig.png')).buffer.asUint8List(),
    );
    final vikashSign = pw.MemoryImage(
      (await rootBundle.load('assets/vikash_sig.png')).buffer.asUint8List(),
    );

    final pdf = pw.Document(
      compress: true,
      // Theme mein base font set karne se Times/Helvetica wali error band ho jayegi
      theme: pw.ThemeData.withFont(
        base: baseFont,

        bold: boldFont, // <--- Ab ye variable "Use" ho gaya
        italic: italicFont, // Aap NotoSerif-Bold bhi load kar sakte hain
      ),
    );

    final fbIcon = pw.MemoryImage(fbBytes!);
    final instaIcon = pw.MemoryImage(instaBytes!);
    final phoneIcon = pw.MemoryImage(phoneBytes!);
    final logoImage = pw.MemoryImage(logoBytes!);
    final yourSidebarImage = pw.MemoryImage(sidebarBytes!);

    final String uniqueCertId =
        "MF-BD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    // Data map mein ID add kar dein taaki sidebar aur QR mein use ho sake
    data['certId'] = uniqueCertId;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          final String rawGender = (data['gender'] ?? "Male")
              .toString()
              .toLowerCase();
          //final String fullName = data['fullName'] ?? "Valued Donor";
          String salutation = "Mr.";

          if (rawGender == "female") {
            salutation = "Ms.";
          } else if (rawGender == "other") {
            salutation = "Mx.";
          }
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                // 1. Premium Background Color (Ivory/Off-White)
                pw.Container(color: PdfColor.fromHex('FFFDF9')),

                // 2. Subtle Watermark Logo
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.04,
                    child: pw.Image(logoImage, width: 450),
                  ),
                ),

                // 3. Double Border Design
                pw.Container(
                  margin: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColor.fromHex('D4AF37'),
                      width: 2.5,
                    ),
                  ),
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromHex('800000'),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // 4. Elegant Corner Accents
                pw.Positioned(
                  top: 0,
                  left: 0,

                  child: pw.Container(
                    width: 140,
                    height: 140,
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xff800000),
                      borderRadius: pw.BorderRadius.only(
                        bottomRight: pw.Radius.circular(140),
                      ),
                    ),
                  ),
                ),

                // 5. Layout Content
                pw.Column(
                  children: [
                    pw.SizedBox(height: 50),
                    // NGO HEADER
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 60),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            height: 85,
                            width: 85,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              border: pw.Border.all(
                                color: PdfColor.fromHex('D4AF37'),
                                width: 2,
                              ),
                              image: pw.DecorationImage(
                                image: logoImage,
                                fit: pw.BoxFit.contain,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 25),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                "MATRITVA FOUNDATION",
                                style: pw.TextStyle(
                                  fontSize: 51,
                                  fontWeight: pw.FontWeight.bold,
                                  
                                  color: PdfColor.fromHex('800000'),
                                  font: baseFont,
                                ),
                              ),
                              pw.Text(
                                " Head Office: Radha Krishna Nagar Gali No.1, Nizamuddinpur, Jehanabad, Bihar - 804417",
                                style: pw.TextStyle(
                                  fontSize: 12.5,
                                  font: baseFont,
                                  color: PdfColors.green800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              pw.Container(
                                height: 1.5,
                                width: 628,
                                color: PdfColor.fromHex('D4AF37'),
                                margin: const pw.EdgeInsets.only(top: 6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width:
                                160, // Fixed width taaki main body disturb na ho
                            margin: const pw.EdgeInsets.only(
                              left: 45,
                              top: 50,
                            ), // Top margin adjust karein design ke hisaab se
                            child: pw.Column(
                              mainAxisSize: pw.MainAxisSize.min,
                              crossAxisAlignment: pw
                                  .CrossAxisAlignment
                                  .center, // Logo ko box ke center mein layega
                              children: [
                                // 1. SIDEBAR IMAGE (Logo)
                                pw.Image(
                                  yourSidebarImage,
                                  width: 105,
                                  height: 105,
                                  fit: pw.BoxFit.contain,
                                ),

                                pw.SizedBox(
                                  height: 15,
                                ), // Logo aur Box ke beech gap
                                // 2. SIDEBAR DETAILS BOX
                                pw.Container(
                                  width: 160,
                                  padding: const pw.EdgeInsets.all(12),
                                  decoration: pw.BoxDecoration(
                                    borderRadius: pw.BorderRadius.circular(10),
                                    border: pw.Border.all(
                                      color: PdfColor.fromHex('D4AF37'),
                                      width: 1,
                                    ),
                                  ),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      _sidebarItem(
                                        "BLOOD GROUP",
                                        data['bloodGroup'],
                                        PdfColors.red900,
                                        const pw.IconData(0xe798),
                                        iconFont,
                                      ),
                                      _sidebarItem(
                                        "DONATION DATE",
                                        data['date'],
                                        PdfColors.black,
                                        const pw.IconData(0xe916),
                                        iconFont,
                                      ),
                                      _sidebarItem(
                                        "VENUE",
                                        data['location'],
                                        PdfColors.black,
                                        const pw.IconData(0xe0c8),
                                        iconFont,
                                      ),
                                      _sidebarItem(
                                        "TOTAL DONATIONS", // Label
                                        "${data['donationCount'] ?? '1'}",
                                        // Agar ye donor ki pehli baar hai toh 1 dikhayega
                                        PdfColors
                                            .blueGrey900, // Thoda alag color taaki highlight ho
                                        const pw.IconData(
                                          0xe87d,
                                        ), // Heart ya count wala icon
                                        iconFont,
                                      ),
                                      _sidebarItem(
                                        "CERTIFICATE ID",
                                        data['certId'],
                                        PdfColors.blueGrey800,
                                        const pw.IconData(0xe86c),
                                        iconFont,
                                        isLast: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // MAIN CERTIFICATE BODY (Right)
                          pw.Expanded(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                right: 45,
                                top: 20,
                              ),
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    "BLOOD DONOR CERTIFICATE",
                                    style: pw.TextStyle(
                                      fontSize: 30,
                                      letterSpacing: 4.5,
                                      color: PdfColor.fromHex('001F3F'),
                                      font: baseFont,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    "CERTIFICATE OF APPRECIATION",
                                    style: pw.TextStyle(
                                      fontSize: 20,
                                      fontWeight: pw.FontWeight.bold,
                                      font: baseFont,
                                      color: PdfColor.fromHex('800000'),
                                    ),
                                  ),

                                  pw.SizedBox(height: 10),
                                  pw.Text(
                                    "This Certificate is proudly presented to",
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: italicFont,
                                      fontStyle: pw.FontStyle.italic,
                                    ),
                                  ),
                                  pw.SizedBox(height: 8),

                                  //jiske naam se certifacte rhega
                                  pw.RichText(
                                    text: pw.TextSpan(
                                      children: [
                                        // Salutation (Mr./Ms.) in Base Font
                                        pw.TextSpan(
                                          text: "$salutation ",
                                          style: pw.TextStyle(
                                            fontSize:
                                                24, // Fancy font ke mukable thoda chota
                                            font:
                                                baseFont, // Aapka normal professional font
                                            color: PdfColor.fromHex('1A237E'),
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        // Name in Fancy Font with Golden Underline
                                        pw.TextSpan(
                                          text: toTitleCase(
                                            data['fullName'] ?? 'Valued Donor',
                                          ),
                                          style: pw.TextStyle(
                                            fontSize:
                                                45, // Name ko dominate karne ke liye bada size
                                            font: fancyFont,
                                            color: PdfColor.fromHex('1A237E'),
                                            fontWeight: pw.FontWeight.bold,
                                            decoration:
                                                pw.TextDecoration.underline,
                                            decorationColor: PdfColor.fromInt(
                                              0xFFD4AF37,
                                            ), // Gold Color
                                            decorationThickness: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 40,
                                    ),
                                    child: pw.Text(
                                      "In heartfelt appreciation of your noble act of donating blood. Your selfless contribution has helped save lives and spread hope to those in need. You are a true hero whose kindness and generosity inspire others to serve humanity.",
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        lineSpacing: 1.5,
                                        color: PdfColors.black,
                                        font: italicFont,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                  ),

                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      "Every drop of blood is a gift of life",
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        fontSize: 18,
                                        lineSpacing: 1.0,
                                        color: PdfColor.fromHex('800000'),
                                        font: italicFont,
                                        fontStyle: pw.FontStyle.italic,
                                      ),
                                    ),
                                  ),

                                  pw.Spacer(),

                                  // FOOTER SECTION
                                  pw.Container(
                                    width: double.infinity,
                                    padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: pw.Column(
                                      mainAxisSize: pw.MainAxisSize.min,
                                      children: [
                                        pw.Center(
                                          child: pw.Text(
                                            "ORGANISED BY - RED CROSS SOCIETY, JEHANABAD", // Organiser ka naam
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 11.5,
                                              letterSpacing: 1.4,
                                              font: italicFont,
                                              fontStyle: pw.FontStyle.italic,
                                              color: PdfColor.fromHex(
                                                '800000',
                                              ), // Dark Red, design match karne ke liye
                                            ),
                                          ),
                                        ),
                                        pw.SizedBox(height: 8),
                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.end,
                                          children: [
                                            _signature(
                                              "Adarsh Bhardwaj",
                                              "Founder",
                                              italicFont,
                                              adarshSign,
                                            ),
                                            _qrSection(
                                              data,
                                            ), // QR Section center mein aayega
                                            _signature(
                                              "Vikash Sharma",
                                              "Director",
                                              italicFont,
                                              vikashSign,
                                            ),
                                          ],
                                        ),
                                        pw.SizedBox(height: 1.7),
                                        pw.Container(
                                          width: 400,
                                          height: 0.5,
                                          color: PdfColors.grey400,
                                        ),
                                        pw.SizedBox(height: 2),

                                        pw.Row(
                                          mainAxisAlignment:
                                              pw.MainAxisAlignment.center,
                                          children: [
                                            // 1. WhatsApp/Call Symbol
                                            pw.Image(
                                              phoneIcon,
                                              width: 12,
                                              height: 12,
                                            ),
                                            pw.SizedBox(width: 4),
                                            pw.Text(
                                              "+91 9471438309",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),

                                            pw.SizedBox(width: 20),
                                            pw.Container(
                                              width: 1,
                                              height: 10,
                                              color: PdfColors.grey400,
                                            ),
                                            pw.SizedBox(width: 20),

                                            // 2. Instagram Symbol
                                            pw.Image(
                                              instaIcon,
                                              width: 12,
                                              height: 12,
                                            ),
                                            pw.SizedBox(width: 4),
                                            pw.Text(
                                              "@matritva_foundation",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),

                                            pw.SizedBox(width: 20),
                                            pw.Container(
                                              width: 1,
                                              height: 10,
                                              color: PdfColors.grey400,
                                            ),
                                            pw.SizedBox(width: 20),

                                            // 3. Facebook Symbol
                                            pw.Image(
                                              fbIcon,
                                              width: 12,
                                              height: 12,
                                            ),
                                            pw.SizedBox(width: 4),
                                            pw.Text(
                                              "matritvafoundation.org",
                                              style: pw.TextStyle(
                                                fontSize: 10,
                                                fontWeight: pw.FontWeight.bold,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(height: 45),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    final Uint8List pdfBytes = await pdf
        .save(); // <--- Ye line sahi jagah par hai

    return pdfBytes;
  }

  pw.Widget _sidebarItem(
    String label,
    String value,
    PdfColor color,
    pw.IconData iconData,
    pw.Font fontData, {
    bool isLast = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // 1. FULL COLORED CIRCLE WITH WHITE ICON
            pw.Container(
              width: 24,
              height: 24,
              decoration: pw.BoxDecoration(
                color: color, // Red, Black, ya Grey circle
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  String.fromCharCode(iconData.codePoint),
                  style: pw.TextStyle(
                    font: fontData, // Yahan load kiya hua icon font use hoga
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            // 2. TEXT CONTENT
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColors.grey700,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.SizedBox(
                  width: 115, // Isse text container ke andar hi wrap hoga
                  child: pw.Text(
                    value,
                    style: pw.TextStyle(
                      fontSize: label == "CERTIFICATE ID"
                          ? 9
                          : 11, // ID chhoti rahegi
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isLast)
          pw.Container(
            margin: const pw.EdgeInsets.only(left: 36, top: 6, bottom: 6),
            height: 0.5,
            child: pw.Divider(
              color: PdfColor.fromHex('D4AF37'),
              thickness: 0.5,
              borderStyle: pw.BorderStyle.dashed,
            ),
          ),
      ],
    );
  }

  pw.Widget _signature(
    String name,
    String role,
    pw.Font font,
    pw.MemoryImage signImg,
  ) {
    return pw.Column(
      children: [
        pw.Image(signImg, height: 25),
        pw.SizedBox(height: 2),
        pw.Container(
          height: 1.2,
          width: 90,
          color: PdfColor.fromHex('D4AF37'),
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
        ),
        pw.SizedBox(height: 0.2),
        pw.Text(
          name,
          style: pw.TextStyle(
            fontSize: 11.5,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),

        pw.Text(
          role,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  pw.Widget _qrSection(Map<String, dynamic> data) {
    final String qrData =
        "BLOOD DONOR CERTIFICATE\nISSUE BY MATRITVA FOUNDATION\n"
        "ID: ${data['certId'] ?? data['certificateId'] ?? 'N/A'}\n"
        "Name: ${data['fullName'] ?? 'N/A'}";

    return pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: qrData,
            width: 55,
            height: 55,
            color: PdfColors.black,
            drawText: false,
          ),
        ),
      ],
    );
  }

  Future<void> saveAndPrint() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Variables ko pehle hi nikal lein taaki dot notation ka koi chance na rahe
      final String donorName = nameCtrl.text;
      final String currentEmail = emailCtrl.text;
      final String uniqueId = "MF-BD-${DateTime.now().millisecondsSinceEpoch}";
      final String displayDate = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now());

      Map<String, dynamic> donorData = {
        "fullName": donorName,
        "fatherName": fatherCtrl.text,
        "gender": gender,
        "dob": dobCtrl.text,
        "email": currentEmail,
        "mobile": mobileCtrl.text,
        "bloodGroup": bGroup,
        "location": locCtrl.text,
        "donationCount": int.tryParse(donationCountCtrl.text) ?? 1,
        "donationDate": donationDateCtrl.text.isEmpty
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : donationDateCtrl.text,
        "certificateId": uniqueId,
      };

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/api/donors/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(donorData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint("Data Saved");

          // Data update karein PDF ke liye
          donorData['date'] = displayDate;

          // STEP 3: Certificate Bytes lijiye
          final Uint8List pdfBytes = await generateCertificate(donorData);

          // STEP 4: Print Layout (Simple name use karein variable avoid karne ke liye)
          await Printing.layoutPdf(
            onLayout: (format) => pdfBytes,
            name:
                'Certificate_$donorName.pdf', // Direct variable use karein, map nahi
          );

          // STEP 5: Backend Mail
          try {
            await sendCertificateToBackend(pdfBytes, donorData);
          } catch (mailError) {
            debugPrint("Mail sending failed: $mailError");
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Success! Saved and Printed."),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception("Server returned ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Catch Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 41, 40, 40),
      appBar: AppBar(
        title: const Text("MATRITVA FOUNDATION"),
        backgroundColor: const Color.fromARGB(255, 239, 176, 176),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black..withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 40,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Matritva Foundation",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Official Blood Donation Certificate",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // 1. Donor Full Name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Donor Full Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  // 2. Father's Name
                  TextFormField(
                    controller: fatherCtrl,
                    decoration: const InputDecoration(
                      labelText: "Father's Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  // 3. Gender Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: ["Male", "Female", "Other"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => gender = v,
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  // 4. Blood Group
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Blood Group",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bloodtype_outlined),
                    ),
                    items: ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => bGroup = v,
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  // 5. Date of Birth (DOB)
                  TextFormField(
                    controller: dobCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        dobCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
                      }
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  // 6. Mobile Number
                  TextFormField(
                    controller: mobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_android),
                    ),
                    validator: (v) =>
                        v!.length < 10 ? "Enter valid number" : null,
                  ),
                  const SizedBox(height: 15),

                  // 7. Email Address
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: donationCountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Donation Count",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),
                  // 9. Donation Date (Default Today)
                  TextFormField(
                    controller: donationDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Donation Date",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                          2026,
                        ), // Purani dates allow karne ke liye
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        // Backend (YYYY-MM-DD) aur Display (dd-MM-yyyy) dono ke liye format set karein
                        donationDateCtrl.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                      }
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 15),

                  // 10. Donation Venue
                  TextFormField(
                    controller: locCtrl,
                    decoration: const InputDecoration(
                      labelText: "Donation Venue / Location",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double
                        .infinity, // Button ki width full screen karne ke liye
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .red
                            .shade900, // Matritva Foundation theme (Dark Red)
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Validate form first
                        if (_formKey.currentState!.validate()) {
                          // Form data save karne aur print karne ka function call karein
                          saveAndPrint();
                        }
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ), // Niche thodi extra jagah scroll ke liye
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
