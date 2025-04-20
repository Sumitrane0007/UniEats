import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class AdminDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const AdminDetailsPage({super.key, required this.order});

  Future<DocumentSnapshot?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      return userDoc.exists ? userDoc : null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // 🖨️ Function to Generate & Save PDF
  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    var userData = await getUserInfo(order["UserId"] ?? "");

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("🧾 Canteen Order Bill",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("☎ User Details",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text("Name: ${userData?["Name"] ?? 'N/A'}"),
                pw.Text("Email: ${userData?["Email"] ?? 'N/A'}"),
                pw.Text("Phone: ${userData?["Phone"] ?? 'N/A'}"),
                pw.SizedBox(height: 10),
                pw.Text("📍 Table Number: ${order["TableNumber"] ?? 'N/A'}"),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("📦 Order Details",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text("Total Price: \$${order["Total"]}"),
                pw.Text("Status: ${order["Status"]}"),
                pw.SizedBox(height: 10),
                pw.Text("🍽 Items Ordered:",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: (order["Items"] as List)
                      .map((item) =>
                          pw.Text("- ${item['Name']} x${item['Quantity']}"))
                      .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Center(
                  child: pw.Text("Thank you for ordering! 🎉",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                )
              ],
            ),
          );
        },
      ),
    );

    // Save PDF to Downloads folder
    Directory directory = Directory("/storage/emulated/0/Download");
    final file = File("${directory.path}/Order_Bill_${order.id}.pdf");

    await file.writeAsBytes(await pdf.save());
    print("PDF saved at: ${file.path}"); // ✅ Log file path in console

    OpenFilex.open(file.path); // ✅ Open the file automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Details")),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<DocumentSnapshot?>(
              future: getUserInfo(order["UserId"] ?? ""),
              builder: (context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text("User details not found."));
                }

                var userData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 User Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Name: ${userData['Name'] ?? 'N/A'}"),
                      Text("Email: ${userData['Email'] ?? 'N/A'}"),
                      Text("Phone: ${userData['Phone'] ?? 'N/A'}"),
                      SizedBox(height: 20),
                      Text("📍 Table Number: ${order["TableNumber"] ?? 'N/A'}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text("📦 Order Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Total: \$${order["Total"]}"),
                      Text("Status: ${order["Status"]}"),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (order["Items"] as List)
                            .map((item) =>
                                Text("${item['Name']} x${item['Quantity']}"))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // 🖨️ DOWNLOAD BUTTON AT THE BOTTOM
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => generatePDF(context),
              icon: Icon(Icons.download, color: Colors.white),
              label: Text("Download Bill",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
