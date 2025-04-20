import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AdminDetailsPage.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ✅ Fetch orders from Firestore based on status
  Stream<QuerySnapshot> getOrdersStream(String status) {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", isEqualTo: status)
        .orderBy("Timestamp", descending: true)
        .snapshots();
  }

  // ✅ Update order status
  void updateOrderStatus(String orderId) {
    FirebaseFirestore.instance.collection("Orders").doc(orderId).update({
      "Status": "Completed",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Pending"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          OrdersList(
            orderStream: getOrdersStream("Pending"), // ✅ Fetch Pending Orders
            updateOrderStatus: updateOrderStatus,
          ),
          OrdersList(
            orderStream:
                getOrdersStream("Completed"), // ✅ Fetch Completed Orders
            updateOrderStatus: null, // No need to update completed orders
          ),
        ],
      ),
    );
  }
}

// ✅ Widget to Display Orders List
class OrdersList extends StatelessWidget {
  final Stream<QuerySnapshot> orderStream;
  final Function(String)? updateOrderStatus;

  const OrdersList(
      {super.key, required this.orderStream, this.updateOrderStatus});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: orderStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No orders."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var order = snapshot.data!.docs[index];

            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text("Total: \$${order["Total"]}"),
                subtitle: Text(
                  "Items: ${order["Items"].map((i) => "${i['Name']} x${i['Quantity']}").join(", ")}",
                ),
                trailing:
                    updateOrderStatus != null && order["Status"] == "Pending"
                        ? ElevatedButton(
                            onPressed: () => updateOrderStatus!(order.id),
                            child: Text("Mark Completed"),
                          )
                        : Text("✅ Completed"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminDetailsPage(order: order),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
