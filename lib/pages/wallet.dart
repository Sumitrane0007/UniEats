import 'dart:convert';
import 'package:canteen_app/service/database.dart';
import 'package:canteen_app/service/shared_pref.dart';
import 'package:canteen_app/widget/app_constant.dart';
import 'package:canteen_app/widget/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, id;
  int? add;
  TextEditingController amountController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  onLoad() async {
    await getSharedPref();
    setState(() {});
  }

  getSharedPref() async {
    wallet = await SharedPreferenceHelper().getUserWallet();
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: wallet == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              margin: const EdgeInsets.only(top: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    elevation: 2.0,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Center(
                        child: Text(
                          "Wallet",
                          style: AppWidget.HeadlineTextFeildStyle(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  walletCard(),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Add money",
                      style: AppWidget.semiBoldTextFeildStyle(),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  predefinedAmountButtons(),
                  const SizedBox(height: 50.0),
                  addMoneyButton(),
                ],
              ),
            ),
    );
  }

  Widget walletCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
      child: Row(
        children: [
          Image.asset("images/wallet.png",
              height: 60, width: 60, fit: BoxFit.cover),
          const SizedBox(width: 40.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your Wallet", style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 5.0),
              Text("\$${wallet ?? '0'}", style: AppWidget.boldTextFeildStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget predefinedAmountButtons() {
    List<String> amounts = ['100', '500', '1000', '2000'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: amounts.map((amount) {
        return GestureDetector(
          onTap: () => makePayment(amount),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE9E2E2)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text("\$$amount", style: AppWidget.semiBoldTextFeildStyle()),
          ),
        );
      }).toList(),
    );
  }

  Widget addMoneyButton() {
    return GestureDetector(
      onTap: () => openEdit(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: const Color(0xFF008080),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "Add Money",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Adnan',
        ),
      );

      displayPaymentSheet(amount);
    } catch (e, s) {
      print('Exception: $e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        add = int.parse(wallet ?? "0") + int.parse(amount);
        await SharedPreferenceHelper().saveUserWallet(add.toString());
        await DatabaseMethods().UpdateUserwallet(id!, add.toString());
        await getSharedPref();

        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                Text(" Payment Successful"),
              ],
            ),
          ),
        );

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error: $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(content: Text("Cancelled")),
      );
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    return (int.parse(amount) * 100).toString();
  }

  Future openEdit() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.cancel),
                  ),
                  const SizedBox(width: 60.0),
                  const Text(
                    "Add Money",
                    style: TextStyle(
                      color: Color(0xFF008080),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              const Text("Amount"),
              const SizedBox(height: 10.0),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Amount',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  makePayment(amountController.text);
                },
                child: const Text("Pay"),
              ),
            ],
          ),
        ),
      );
}
