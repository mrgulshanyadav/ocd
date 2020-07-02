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
