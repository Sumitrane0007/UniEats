import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';

class DatabaseMethods {
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  UpdateUserwallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  Stream<QuerySnapshot> getFoodItems(String collectionName) {
    return FirebaseFirestore.instance.collection(collectionName).snapshots();
  }

  Stream<List<DocumentSnapshot>> getAllFoodItems() {
    List<String> foodCategories = [
      "Burger",
      "Pizza",
      "Ice-cream",
      "Salad",
    ]; // Add more categories

    List<Stream<List<DocumentSnapshot>>> streams =
        foodCategories.map((category) {
      return FirebaseFirestore.instance
          .collection(category)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }).toList();

    return StreamZip(streams)
        .map((listOfLists) => listOfLists.expand((x) => x).toList());
  }

  // Stream<List<DocumentSnapshot>> getAllFoodItems() {
  //   // Start by fetching data from just one category
  //   return FirebaseFirestore.instance
  //       .collection("Burger")
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs);
  // }

  Future addFoodToCart(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }

  Stream<QuerySnapshot> getFoodCart(String id) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .snapshots();
  }

  // Update Food Item
  Future<void> updateFoodItem(
      String docId, String category, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance
        .collection(category)
        .doc(docId)
        .update(newData);
  }

  // Delete Food Item
  Future<void> deleteFoodItem(String docId, String category) async {
    await FirebaseFirestore.instance.collection(category).doc(docId).delete();
  }

  Future<void> placeOrder(String userId, List<Map<String, dynamic>> items,
      int total, String tableNumber) async {
    await FirebaseFirestore.instance.collection("Orders").add({
      "UserId": userId,
      "Items": items,
      "Total": total,
      "TableNumber": tableNumber,
      "Status": "Pending",
      "Timestamp": FieldValue.serverTimestamp(),
    });
  }
}
