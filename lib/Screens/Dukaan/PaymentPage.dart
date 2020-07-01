import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ocd/Models/CartItem.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Constants.dart';
import '../NavigationPage.dart';


class PaymentPage extends StatefulWidget {
  String mobile, email, username;
  FirebaseUser user;
  Map<String, dynamic> userMap;
  List<CartItem> cartItemList = new List();

  PaymentPage({
    this.cartItemList,
    this.user,
    this.username,
    this.userMap,
    this.mobile,
    this.email,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String address_line_1, address_line_2, city, state, country, pin;

  Razorpay _razorpay;

  int total_amount;

  @override
  void initState() {
    address_line_1 = "";
    address_line_2 = "";
    city = "";
    state = "";
    country = "";
    pin = "";

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Constants().dukaanBackgroundColor,
          title: Text("Delivery Address"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Address Line 1',
                    ),
                    onChanged: (input){
                      setState(() {
                        address_line_1 = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Address Line 2',
                    ),
                    onChanged: (input){
                      setState(() {
                        address_line_2 = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'City',
                    ),
                    onChanged: (input){
                      setState(() {
                        city = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'State',
                    ),
                    onChanged: (input){
                      setState(() {
                        state = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Country',
                    ),
                    onChanged: (input){
                      setState(() {
                        country = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20, left: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'PIN Code',
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        pin = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: RaisedGradientButton(
                    child: Text("Proceed",style: TextStyle(color: Colors.white),),
                    width: screenWidth,
                    height: 50,
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: <Color>[Constants().blueFontColor, Color(0xFF5445ae)],
                    ),
                    onPressed: () async {
                      // save into database firebase

                      // todo: save into excel sheet online

                      if(address_line_1.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Address Line 1!')));
                      }else if(city.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter City!')));
                      }else if(state.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter State!')));
                      }else if(country.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Country!')));
                      }else if(pin.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter PIN!')));
                      }else{

                        openCheckout();

//                      SponsorshipForEventsForm feedbackForm = SponsorshipForEventsForm(
//                          company_name,
//                          company_link,
//                          phone_number,
//                          email_id
//                      );
//
//                      SponsorshipForEventsFormController formController = SponsorshipForEventsFormController((String response) {
//                        print("Response: $response");
//                        if (response == SponsorshipForEventsFormController.STATUS_SUCCESS) {
//                          // Feedback is saved succesfully in Google Sheets.
//                          setState(() {
//                            isLoading = false;
//                          });
//                          _showSnackbar("Feedback Submitted");
//                        } else {
//                          // Error Occurred while saving data in Google Sheets.
//                          setState(() {
//                            isLoading = false;
//                          });
//                          _showSnackbar("Error Occurred!");
//                        }
//                      }
//                      );
//
//                      _showSnackbar("Submitting Feedback");
//
//                      // Submit 'feedbackForm' and save it in Google Sheets.
//                      formController.submitForm(feedbackForm);

                      }

                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    total_amount = 0;
    widget.cartItemList.forEach((element) {
      total_amount= total_amount+ int.parse(element.total_amount);
    });

    var options = {
      'key': 'rzp_live_OgcfnwYLl8OImU',
      'amount': total_amount*100,
      'name': widget.username,
      'description': "",
      'prefill': {'contact': widget.mobile, 'email': widget.email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);

      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
        return PaymentStatusPage(
          isStatusSuccess: false,
        );
      }));


    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // add order details and payment details to database

    Map<String, dynamic> ordersMap = new Map();
    ordersMap.putIfAbsent("total_amount", () => total_amount.toString());
    ordersMap.putIfAbsent("items", () => CartItem.encodeCartItems(widget.cartItemList));
    ordersMap.putIfAbsent("date", () => DateTime.now());

    Map<String, dynamic> addressMap = new Map();
    addressMap.putIfAbsent("address1", () => address_line_1);
    addressMap.putIfAbsent("address2", () => address_line_2);
    addressMap.putIfAbsent("city", () => city);
    addressMap.putIfAbsent("state", () => state);
    addressMap.putIfAbsent("country", () => country);
    addressMap.putIfAbsent("pin", () => pin);

    ordersMap.putIfAbsent("delivery_address", () => addressMap.toString());
    ordersMap.putIfAbsent("order_by", () => widget.user.uid);

    Firestore.instance.collection("Orders").add(ordersMap).then((value) async {
      String order_id = value.documentID;
      String trans_id = response.paymentId;
      Map<String, dynamic> transactionsMap = new Map();
      transactionsMap.putIfAbsent("total_amount", () => total_amount.toString());
      transactionsMap.putIfAbsent("order_id", () => order_id);
      transactionsMap.putIfAbsent("trans_id", () => trans_id);
      transactionsMap.putIfAbsent("date", () => DateTime.now());
      transactionsMap.putIfAbsent("order_by", () => widget.user.uid);

      await Firestore.instance.collection("Transactions").add(transactionsMap).whenComplete(() async {

        // clear cart items
        setState(() {
          widget.cartItemList.clear();
        });
        String encodedCartItems = CartItem.encodeCartItems(widget.cartItemList);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("cart_items", encodedCartItems);

        // send email to vendor
        var res = await http.post(
            'https://us-central1-ocd-delhi.cloudfunctions.net/sendMailToVendor?'
                'email='+widget.email+
                '&orderId='+order_id+
                '&transId='+trans_id+
                '&userId='+widget.user.uid+
                '&name='+widget.username+
                '&mobile='+widget.mobile+
                '&delivery_address='+addressMap.toString()+
                '&items='+CartItem.encodeCartItems(widget.cartItemList)+
                '&total_amount='+total_amount.toString()
        );
        print('send email to vendor [res]: '+res.body);

        // send email to user
        var resUser = await http.post(
            'https://us-central1-ocd-delhi.cloudfunctions.net/sendMailToUser?'
                'email='+widget.email+
                '&orderId='+order_id+
                '&transId='+trans_id+
                '&userId='+widget.user.uid+
                '&name='+widget.username+
                '&mobile='+widget.mobile+
                '&delivery_address='+addressMap.toString()+
                '&items='+CartItem.encodeCartItems(widget.cartItemList)+
                '&total_amount='+total_amount.toString()
        );
        print('send email to user [resUser]: '+resUser.body);


        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
          return PaymentStatusPage(
            isStatusSuccess: true,
            orderId: order_id,
            transId: trans_id,
            totalAmount: total_amount.toString(),
          );
        }));

      }).catchError((onError){
        print('onError2: '+onError.toString());

        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
          return PaymentStatusPage(
            isStatusSuccess: false,
          );
        }));

      });

    }).catchError((onError){
      print('onError1: '+onError.toString());

      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
        return PaymentStatusPage(
          isStatusSuccess: false,
        );
      }));

    });

    Fluttertoast.showToast(
        msg: "SUCCESS", timeInSecForIosWeb: 4);

  }

  void _handlePaymentError(PaymentFailureResponse response) {
//    Fluttertoast.showToast(
//        msg: "ERROR: " + response.code.toString() + " - " + response.message,
//        timeInSecForIosWeb: 4);

    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
      return PaymentStatusPage(
        isStatusSuccess: false,
      );
    }));

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
//    Fluttertoast.showToast(
//        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIosWeb: 4);

    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context){
      return PaymentStatusPage(
        isStatusSuccess: false,
      );
    }));

  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}


class PaymentStatusPage extends StatefulWidget {
  String orderId, transId, totalAmount;
  bool isStatusSuccess;

  PaymentStatusPage({this.orderId, this.totalAmount, this.transId, this.isStatusSuccess});

  @override
  _PaymentStatusPageState createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 36,
                  backgroundColor: widget.isStatusSuccess? Colors.green: Colors.red,
                  child: Icon(widget.isStatusSuccess? Icons.check: Icons.close, size: 36, color: Colors.white,),
                ),
                Container(
                  padding: EdgeInsets.only(top: 50.0, bottom: 20.0, right: 20.0, left: 20.0),
                  child: Text(
                      widget.isStatusSuccess?
                      "Order has been successfully placed." :
                      "Order failed.",
                       style: TextStyle(fontSize: 16),
                  ),
                ),
                widget.isStatusSuccess? Container(
                  padding: EdgeInsets.only(top: 55.0),
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Order Id: "+widget.orderId,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Transaction Id: "+widget.transId,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Total Amount: "+widget.totalAmount,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),

                    ],
                  ),
                ): Container(),
                SizedBox(
                  height: 70,
                ),
                RaisedGradientButton(
                  onPressed: (){
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context)=> NavigationPage()
                    ));
                  },
                  child: Text('Go to Home', style: TextStyle(color: Colors.white),),
                  width: 100,
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}



class RaisedGradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double width;
  final double height;
  final Function onPressed;

  const RaisedGradientButton({
    Key key,
    @required this.child,
    this.gradient,
    this.width = double.infinity,
    this.height = 50.0,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40.0,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500],
              offset: Offset(0.0, 1.5),
              blurRadius: 1.5,
            ),
          ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            child: Center(
              child: child,
            )),
      ),
    );
  }
}
