import 'dart:async';
import 'package:canteen_app/pages/bottomnav.dart';
import 'package:canteen_app/pages/orderhistory.dart';
import 'package:canteen_app/service/database.dart';
import 'package:canteen_app/service/shared_pref.dart';
import 'package:canteen_app/widget/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet;
  int total = 0, amount2 = 0;
  Stream<QuerySnapshot>? foodStream;

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Future<void> getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    setState(() {});
  }

  Future<void> ontheload() async {
    await getthesharedpref();
    if (id != null) {
      setState(() {
        foodStream = DatabaseMethods().getFoodCart(id!);
      });
    }
  }

  Widget foodCart() {
    return StreamBuilder(
      stream: foodStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;
        int newTotal = docs.fold(0, (sum, ds) => sum + int.parse(ds["Total"]));

        // Update total only when needed
        if (total != newTotal) {
          Future.microtask(() {
            if (mounted) {
              setState(() {
                total = newTotal;
                amount2 = newTotal;
              });
            }
          });
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        height: 90,
                        width: 40,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text(ds["Quantity"])),
                      ),
                      SizedBox(width: 20.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          ds["Image"],
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20.0),
                      Column(
                        children: [
                          Text(
                            ds["Name"],
                            style: AppWidget.semiBoldTextFeildStyle(),
                          ),
                          Text(
                            "\$${ds["Total"]}",
                            style: AppWidget.semiBoldTextFeildStyle(),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void placeOrder() async {
    if (id == null || wallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: User ID or Wallet not found.")),
      );
      return;
    }

    int walletBalance = int.parse(wallet!);
    if (walletBalance < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insufficient balance!")),
      );
      return;
    }

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .get();

    if (cartSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cart is empty!")),
      );
      return;
    }

    // Ask for Table Number
    String? tableNumber = await showTableNumberDialog(context);
    if (tableNumber == null || tableNumber.isEmpty) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    List<Map<String, dynamic>> cartItems = cartSnapshot.docs.map((doc) {
      return {
        "Name": doc["Name"],
        "Quantity": doc["Quantity"],
        "Total": doc["Total"]
      };
    }).toList();

    int newWalletBalance = walletBalance - total;

    await DatabaseMethods().placeOrder(id!, cartItems, total, tableNumber);
    await DatabaseMethods().UpdateUserwallet(id!, newWalletBalance.toString());
    await SharedPreferenceHelper().saveUserWallet(newWalletBalance.toString());

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    // Close loading indicator
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );

    if (mounted) {
      setState(() {
        total = 0;
        foodStream = DatabaseMethods().getFoodCart(id!);
      });

      // Instead of Navigator.pop(context), navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    }
  }

// Function to show Table Number Input Dialog
  Future<String?> showTableNumberDialog(BuildContext context) async {
    TextEditingController tableController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Table Number"),
          content: TextField(
            controller: tableController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Table Number"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, tableController.text.trim());
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Cart"),
        actions: [
          IconButton(
            icon: Icon(Icons.history), // History icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistory()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: foodCart()), // Display cart items
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Price", style: AppWidget.boldTextFeildStyle()),
                  Text("\$${total.toString()}",
                      style: AppWidget.semiBoldTextFeildStyle()),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: placeOrder,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Center(
                  child: Text(
                    "CheckOut",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
