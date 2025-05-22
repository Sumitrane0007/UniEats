import 'package:canteen_app/pages/bottomnav.dart';
import 'package:canteen_app/pages/login.dart';
import 'package:canteen_app/service/database.dart';
import 'package:canteen_app/service/shared_pref.dart';
import 'package:canteen_app/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "", phone = "";

  final _formkey = GlobalKey<FormState>();
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController mailcontroller = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content:
            Text("Registered Successfully", style: TextStyle(fontSize: 20)),
      ));

      String id = randomAlphaNumeric(10);

      Map<String, dynamic> addUserInfo = {
        "Name": namecontroller.text,
        "Email": mailcontroller.text,
        "Phone": phonecontroller.text,
        "Wallet": "0",
        "Id": id,
      };

      await DatabaseMethods().addUserDetail(addUserInfo, id);
      await SharedPreferenceHelper().saveUserName(namecontroller.text);
      await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedPreferenceHelper().saveUserWallet('0');
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserPhone(phonecontroller.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";
      if (e.code == 'weak-password') {
        message = "Password provided is too weak";
      } else if (e.code == "email-already-in-use") {
        message = "Account already exists";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(message, style: TextStyle(fontSize: 18)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height / 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Column(
                        children: [
                          Center(
                            child: Image.asset(
                              "images/logo3.png",
                              width: MediaQuery.of(context).size.width / 1.5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 30),
                          Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 30),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Form(
                                key: _formkey,
                                child: Column(
                                  children: [
                                    Text("Sign Up",
                                        style:
                                            AppWidget.HeadlineTextFeildStyle()),
                                    SizedBox(height: 30),
                                    TextFormField(
                                      controller: namecontroller,
                                      validator: (value) => value!.isEmpty
                                          ? 'Please Enter Name'
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: 'Name',
                                        hintStyle:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        prefixIcon: Icon(Icons.person_outlined),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      controller: mailcontroller,
                                      validator: (value) => value!.isEmpty
                                          ? 'Please Enter Email'
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        hintStyle:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      controller: phonecontroller,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Phone Number';
                                        }
                                        if (value.length < 10) {
                                          return 'Enter a valid phone number';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Phone',
                                        hintStyle:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    TextFormField(
                                      controller: passwordcontroller,
                                      obscureText: true,
                                      validator: (value) => value!.isEmpty
                                          ? 'Please Enter Password'
                                          : null,
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle:
                                            AppWidget.semiBoldTextFeildStyle(),
                                        prefixIcon:
                                            Icon(Icons.password_outlined),
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_formkey.currentState!.validate()) {
                                          setState(() {
                                            email = mailcontroller.text;
                                            name = namecontroller.text;
                                            password = passwordcontroller.text;
                                            phone = phonecontroller.text;
                                          });
                                          registration();
                                        }
                                      },
                                      child: Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Color(0Xffff5722),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "SIGN UP",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontFamily: 'Poppins1',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LogIn()));
                            },
                            child: Text("Already have an account? Login",
                                style: AppWidget.semiBoldTextFeildStyle()),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
