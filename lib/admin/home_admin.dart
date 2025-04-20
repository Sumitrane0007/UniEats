import 'AdminOrdersPage.dart';
import 'package:canteen_app/service/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_food.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  Stream<List<DocumentSnapshot>>? foodItemsStream;

  @override
  void initState() {
    super.initState();
    foodItemsStream = DatabaseMethods().getAllFoodItems();
  }

  // Function to Show Edit Dialog
  void showEditDialog(DocumentSnapshot foodItem) {
    TextEditingController nameController =
        TextEditingController(text: foodItem["Name"]);
    TextEditingController priceController =
        TextEditingController(text: foodItem["Price"].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Food Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Food Name"),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              DatabaseMethods().updateFoodItem(
                  foodItem.reference.id, foodItem.reference.parent.id, {
                "Name": nameController.text,
                "Price": double.tryParse(priceController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget showAllFoodItems() {
    return StreamBuilder(
      stream: foodItemsStream,
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(
              child: Text("No food items available",
                  style: TextStyle(fontSize: 18)));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data![index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: ds["Image"] != null
                    ? Image.network(ds["Image"],
                        height: 50, width: 50, fit: BoxFit.cover)
                    : Icon(Icons.fastfood, size: 50),
                title: Text(ds["Name"],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("\$${ds["Price"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showEditDialog(ds),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        DatabaseMethods().deleteFoodItem(
                            ds.reference.id, ds.reference.parent.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddFood()));
                    },
                    child: Material(
                      elevation: 10.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Image.asset("images/food.jpg",
                                    height: 100, width: 100, fit: BoxFit.cover),
                              ),
                              SizedBox(width: 20.0),
                              Text(
                                "Add Food Items",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Available Food Items",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  showAllFoodItems(),
                ],
              ),
            ),
          ),

          // 🚀 BUTTON AT THE BOTTOM
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminOrdersPage()));
                },
                child: Text("View Orders",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------------------------------------------------------------
// import 'AdminOrdersPage.dart';
// import 'package:canteen_app/service/database.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'add_food.dart';

// class HomeAdmin extends StatefulWidget {
//   const HomeAdmin({super.key});

//   @override
//   _HomeAdminState createState() => _HomeAdminState();
// }

// class _HomeAdminState extends State<HomeAdmin> {
//   Stream<List<DocumentSnapshot>>? foodItemsStream;

//   @override
//   void initState() {
//     super.initState();
//     foodItemsStream = DatabaseMethods().getAllFoodItems();
//   }

//   // Function to Show Edit Dialog
//   void showEditDialog(DocumentSnapshot foodItem) {
//     TextEditingController nameController =
//         TextEditingController(text: foodItem["Name"]);
//     TextEditingController priceController =
//         TextEditingController(text: foodItem["Price"].toString());

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Edit Food Item"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: "Food Name"),
//             ),
//             TextField(
//               controller: priceController,
//               decoration: InputDecoration(labelText: "Price"),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               DatabaseMethods().updateFoodItem(
//                   foodItem.reference.id, foodItem.reference.parent.id, {
//                 "Name": nameController.text,
//                 "Price": double.tryParse(priceController.text) ?? 0,
//               });
//               Navigator.pop(context);
//             },
//             child: Text("Update"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget showAllFoodItems() {
//     return StreamBuilder(
//       stream: foodItemsStream,
//       builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.data!.isEmpty) {
//           return Center(
//               child: Text("No food items available",
//                   style: TextStyle(fontSize: 18)));
//         }
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             DocumentSnapshot ds = snapshot.data![index];
//             return Card(
//               elevation: 5,
//               margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: ListTile(
//                 leading: ds["Image"] != null
//                     ? Image.network(ds["Image"],
//                         height: 50, width: 50, fit: BoxFit.cover)
//                     : Icon(Icons.fastfood, size: 50),
//                 title: Text(ds["Name"],
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text("\$${ds["Price"]}"),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => showEditDialog(ds),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         DatabaseMethods().deleteFoodItem(
//                             ds.reference.id, ds.reference.parent.id);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Admin Home"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: 20.0),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => AddFood())).then((_) {
//                         // After adding a food item, refresh the stream
//                         setState(() {
//                           foodItemsStream = DatabaseMethods().getAllFoodItems();
//                         });
//                       });
//                     },
//                     child: Material(
//                       elevation: 10.0,
//                       borderRadius: BorderRadius.circular(10),
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.all(6.0),
//                                 child: Image.asset("images/food.jpg",
//                                     height: 100, width: 100, fit: BoxFit.cover),
//                               ),
//                               SizedBox(width: 20.0),
//                               Text(
//                                 "Add Food Items",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20.0,
//                                     fontWeight: FontWeight.bold),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20.0),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Available Food Items",
//                         style: TextStyle(
//                             fontSize: 22, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10.0),
//                   showAllFoodItems(),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => AdminOrdersPage()));
//                 },
//                 child: Text("View Orders",
//                     style: TextStyle(fontSize: 18, color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//-----------------------------------------------------------------------------------------
// import 'AdminOrdersPage.dart';
// import 'package:canteen_app/service/database.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'add_food.dart';

// class HomeAdmin extends StatefulWidget {
//   const HomeAdmin({super.key});

//   @override
//   _HomeAdminState createState() => _HomeAdminState();
// }

// class _HomeAdminState extends State<HomeAdmin> {
//   Stream<List<DocumentSnapshot>>? foodItemsStream;

//   @override
//   void initState() {
//     super.initState();
//     foodItemsStream = DatabaseMethods().getAllFoodItems();
//   }

//   // Function to Show Edit Dialog
//   void showEditDialog(DocumentSnapshot foodItem) {
//     TextEditingController nameController =
//         TextEditingController(text: foodItem["Name"]);
//     TextEditingController priceController =
//         TextEditingController(text: foodItem["Price"].toString());

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Edit Food Item"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: "Food Name"),
//             ),
//             TextField(
//               controller: priceController,
//               decoration: InputDecoration(labelText: "Price"),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // DatabaseMethods().updateFoodItem(
//               //     foodItem.reference.id, foodItem.reference.parent.id, {
//               //   "Name": nameController.text,
//               //   "Price": double.tryParse(priceController.text) ?? 0,
//               // });
//               //Navigator.pop(context);
//             },
//             child: Text("Update"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget showAllFoodItems() {
//     return StreamBuilder(
//       stream: foodItemsStream,
//       builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.data!.isEmpty) {
//           return Center(
//               child: Text("No food items available",
//                   style: TextStyle(fontSize: 18)));
//         }
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data!.length,
//           itemBuilder: (context, index) {
//             DocumentSnapshot ds = snapshot.data![index];
//             return Card(
//               elevation: 5,
//               margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: ListTile(
//                 leading: ds["Image"] != null
//                     ? Image.network(ds["Image"],
//                         height: 50, width: 50, fit: BoxFit.cover)
//                     : Icon(Icons.fastfood, size: 50),
//                 title: Text(ds["Name"],
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text("\$${ds["Price"]}"),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => showEditDialog(ds),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         // DatabaseMethods().deleteFoodItem(
//                         //     ds.reference.id, ds.reference.parent.id);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Admin Home"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: 20.0),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => AddFood())).then((_) {
//                         // After adding a food item, refresh the stream
//                         setState(() {
//                           foodItemsStream = DatabaseMethods().getAllFoodItems();
//                         });
//                       });
//                     },
//                     child: Material(
//                       elevation: 10.0,
//                       borderRadius: BorderRadius.circular(10),
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.all(6.0),
//                                 child: Image.asset("images/food.jpg",
//                                     height: 100, width: 100, fit: BoxFit.cover),
//                               ),
//                               SizedBox(width: 20.0),
//                               Text(
//                                 "Add Food Items",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20.0,
//                                     fontWeight: FontWeight.bold),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20.0),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Available Food Items",
//                         style: TextStyle(
//                             fontSize: 22, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10.0),
//                   showAllFoodItems(),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => HomeAdmin()));
//                 },
//                 child: Text("View Orders",
//                     style: TextStyle(fontSize: 18, color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
