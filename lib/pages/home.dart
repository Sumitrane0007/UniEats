import 'package:canteen_app/service/database.dart';
import 'package:canteen_app/widget/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:canteen_app/pages/details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool icecream = false, pizza = true, salad = false, burger = false;

  Stream? fooditemStream;

  ontheload() async {
    fooditemStream = await DatabaseMethods().getFoodItem("Pizza");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Widget allItems() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String price = ds["Price"].toString();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            detail: ds["Detail"],
                            name: ds["Name"],
                            price: price,
                            image: ds["Image"],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  ds["Image"],
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(ds["Name"],
                                  style: AppWidget.semiBoldTextFeildStyle()),
                              Text("Fresh and Healthy",
                                  style: AppWidget.LightTextFeildStyle()),
                              SizedBox(height: 5.0),
                              Text("₹$price",
                                  style: AppWidget.semiBoldTextFeildStyle()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String price = ds["Price"].toString();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            detail: ds["Detail"],
                            name: ds["Name"],
                            price: price,
                            image: ds["Image"],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  ds["Image"],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ds["Name"],
                                      style:
                                          AppWidget.semiBoldTextFeildStyle()),
                                  SizedBox(height: 5.0),
                                  Text("Fresh and Healthy",
                                      style: AppWidget.LightTextFeildStyle()),
                                  SizedBox(height: 5.0),
                                  Text("₹$price",
                                      style:
                                          AppWidget.semiBoldTextFeildStyle()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        categoryTile("Ice-cream", "images/ice-cream.png", icecream),
        categoryTile("Pizza", "images/pizza.png", pizza),
        categoryTile("Burger", "images/burger.png", burger),
        categoryTile("Salad", "images/salad.png", salad),
      ],
    );
  }

  Widget categoryTile(String category, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () async {
        icecream = category == "Ice-cream";
        pizza = category == "Pizza";
        salad = category == "Salad";
        burger = category == "Burger";
        fooditemStream = await DatabaseMethods().getFoodItem(category);
        setState(() {});
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Hello Sumit", style: AppWidget.boldTextFeildStyle()),
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shopping_cart, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          Text("Delicious Food", style: AppWidget.HeadlineTextFeildStyle()),
          Text("Discover and Get Great Food",
              style: AppWidget.LightTextFeildStyle()),
          SizedBox(height: 20.0),
          showItem(),
          SizedBox(height: 30.0),
          SizedBox(height: 270, child: allItems()),
          SizedBox(height: 30.0),
          allItemsVertically(),
        ],
      ),
    );
  }
}
