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
import 'PaymentPage.dart';


class CartPage extends StatefulWidget {
  String amount;
  String title, description;

  CartPage({this.amount, this.title, this.description});
  
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const platform = const MethodChannel("razorpay_flutter");
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  String mobile, email, username, amount="0", description="..";
  FirebaseUser user;
  Map<String, dynamic> userMap;

  List<CartItem> _cartItemList = new List();

  int total_amount;

  @override
  void initState() {
    super.initState();
    getUserDetailsFromDatabase().then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        _cartItemList = CartItem.decodeCartItems(prefs.getString("cart_items"));
      }catch(e){
        _cartItemList = [];
      }
      setState(() {
        mobile=value['mobile'];
        username=value['name'];
        email=value['email'];
      });
    });
    print("amount: "+amount);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Constants().dukaanBackgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Constants().dukaanBackgroundColor,
          title: Text("Cart"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(bottom: 25),
            child: Column(
              children: <Widget>[
                FutureBuilder(
                  future: getUserDetailsFromDatabase(),
                  builder: (context, res){
                    if(!res.hasData){
                      return Expanded(child: Center(child: CircularProgressIndicator(),));
                    }else{

                      return _cartItemList.length!=0?
                      Expanded(
                        child: ListView.builder(
                          itemCount: _cartItemList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index){

                            return Container(
                              width: screenWidth,
                              height: 120,
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    height: 120,
                                    width: 120,
                                    child: Image.network(_cartItemList[index].image, fit: BoxFit.cover,),
                                  ),
                                  Container(
                                    width: (screenWidth/3)+50,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Flexible(child: Text(_cartItemList[index].title, style: TextStyle(color: Constants().dukaanFontColor, fontSize: 18), softWrap: true,),),
                                        SizedBox(height: 10,),
                                        Flexible(child: Text("Rs."+_cartItemList[index].price+" x "+_cartItemList[index].quantity, style: TextStyle(color: Constants().dukaanFontColor), softWrap: true,)),
                                        SizedBox(height: 10,),
                                        Flexible(child: Text(_cartItemList[index].total_amount, style: TextStyle(color: Constants().dukaanFontColor), softWrap: true,))
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      // remove item from list and update sharedpreferences

                                      setState(() {
                                        _cartItemList.removeAt(index);
                                      });

                                      String encodedCartItems = CartItem.encodeCartItems(_cartItemList);

                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString("cart_items", encodedCartItems);

//                                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item Removed from Cart!"),));

                                    },
                                    child: Icon(Icons.close, color: Colors.grey,),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ): Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("Cart is Empty", style: TextStyle(color: Constants().dukaanFontColor, fontSize: 26),),
                          )
                      );

                    }
                  },
                ),
                Center(
                    child: RaisedGradientButton(
                      onPressed: (){
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context)=> PaymentPage(
                              cartItemList: _cartItemList,
                              user: user,
                              userMap: userMap,
                              username: username,
                              mobile: mobile,
                              email: email,
                            )
                        ));
                      },
                      child: Text('Checkout', style: TextStyle(color: Colors.white),),
                      width: 100,
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getUserDetailsFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("Users").document(user.uid).get();

    userMap = documentSnapshot.data;

    return userMap;
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
