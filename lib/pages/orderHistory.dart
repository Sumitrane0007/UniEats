import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final User? user = FirebaseAuth.instance.currentUser; // Get logged-in user

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
    print("DEBUG: Logged-in User ID: ${user?.uid}"); // Debugging UID
  }

  void checkCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("DEBUG: Current User ID -> ${user.uid}");
      print("DEBUG: Current User Email -> ${user.email}");
    } else {
      print("DEBUG: No user is logged in!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order History")),
      body: user == null
          ? Center(child: Text("User not logged in."))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("orders")
                  .where("UserId", isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No orders found."));
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];

                    return Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          "Order #${order.id}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total: ₹${order["Total"]}"),
                            Text("📍 Table: ${order["TableNumber"]}"),
                            Text("Status: ${order["Status"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
