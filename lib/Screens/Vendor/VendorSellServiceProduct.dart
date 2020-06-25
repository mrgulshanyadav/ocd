import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocd/Screens/Vendor/Model/SellServiceProductForm.dart';
import 'package:ocd/Screens/Vendor/Controller/SellServiceProductFormController.dart';

import '../../Constants.dart';

class VendorSellServiceProduct extends StatefulWidget {
  @override
  _VendorSellServiceProductState createState() => _VendorSellServiceProductState();
}

class _VendorSellServiceProductState extends State<VendorSellServiceProduct> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  String company_name, company_link, product_service_name, cost, phone_number, email_id;

  bool isLoading;


  @override
  void initState() {
    company_name = '';
    company_link = '';
    product_service_name = '';
    cost = '';
    phone_number = '';
    email_id = '';

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Sell Service/Product"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/5.jpg"),
                  fit: BoxFit.fill,
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Company Name',
//                        labelText: 'Company Name',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        company_name = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Company Link',
//                        labelText: 'Company Link',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        company_link = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Product or Service Name',
//                      labelText: 'Product or Service Name',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
                    ),
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        product_service_name = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Cost',
//                      labelText: 'Cost',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        cost = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
//                      labelText: 'Phone Number',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        phone_number = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email ID',
//                      labelText: 'Email ID',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        email_id = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: !isLoading? RaisedGradientButton(
                    child: Text("Submit",style: TextStyle(color: Colors.white),),
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

                      if(company_name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Company Name!')));
                      }else if(company_link.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Company Link!')));
                      }else if(product_service_name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Product or Service Name!')));
                      }else if(cost.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Cost!')));
                      }else if(phone_number.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Phone Number!')));
                      }else if(email_id.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Email ID!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        SellServiceProductForm feedbackForm = SellServiceProductForm(
                            company_name,
                            company_link,
                            product_service_name,
                            cost,
                            phone_number,
                            email_id
                        );

                        SellServiceProductFormController formController = SellServiceProductFormController((String response) {
                          print("Response: $response");
                          if (response == SellServiceProductFormController.STATUS_SUCCESS) {
                            // Feedback is saved succesfully in Google Sheets.
                            setState(() {
                              isLoading = false;
                            });
                            _showSnackbar("Feedback Submitted");
                          } else {
                            // Error Occurred while saving data in Google Sheets.
                            setState(() {
                              isLoading = false;
                            });
                            _showSnackbar("Error Occurred!");
                          }
                        }
                        );

                        _showSnackbar("Submitting Feedback");

                        // Submit 'feedbackForm' and save it in Google Sheets.
                        formController.submitForm(feedbackForm);

                      }

                    },
                  ) : CircularProgressIndicator(),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
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
      height: height,
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
