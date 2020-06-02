import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Controller/EnquireServiceFormController.dart';
import 'Model/EnquireServiceForm.dart';

class EnquireServicePage extends StatefulWidget {
  Map<String, dynamic> postMap;
  String id;

  EnquireServicePage({this.postMap, this.id});

  @override
  _EnquireServicePageState createState() => _EnquireServicePageState();
}

class _EnquireServicePageState extends State<EnquireServicePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  String name, email_id, phone_number, company_name;

  bool isLoading;


  @override
  void initState() {
    name = '';
    email_id = '';
    phone_number = '';
    company_name = '';

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enquire Service"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                Container(
//                  padding: EdgeInsets.all(10),
//                  child: TextField(
//                    decoration: InputDecoration(
//                        hintText: 'Name',
//                        labelText: 'Name',
//                        border: OutlineInputBorder(
//                          borderRadius: BorderRadius.all(Radius.circular(10)),
//                        )
//                    ),
//                    onChanged: (input){
//                      setState(() {
//                        name = input;
//                      });
//                    },
//                  ),
//                ),
//                Container(
//                  padding: EdgeInsets.all(10),
//                  child: TextFormField(
//                    decoration: InputDecoration(
//                      hintText: 'Email ID',
//                      labelText: 'Email ID',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
//                    ),
//                    keyboardType: TextInputType.emailAddress,
//                    maxLines: 1,
//                    onChanged: (input){
//                      setState(() {
//                        email_id = input;
//                      });
//                    },
//                  ),
//                ),
//                Container(
//                  padding: EdgeInsets.all(10),
//                  child: TextFormField(
//                    decoration: InputDecoration(
//                      hintText: 'Phone Number',
//                      labelText: 'Phone Number',
//                      border: OutlineInputBorder(
//                        borderRadius: BorderRadius.all(Radius.circular(10)),
//                      ),
//                    ),
//                    keyboardType: TextInputType.number,
//                    maxLines: 1,
//                    onChanged: (input){
//                      setState(() {
//                        phone_number = input;
//                      });
//                    },
//                  ),
//                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Company Name',
                        labelText: 'Company Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
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
                  child: !isLoading? RaisedButton(
                    child: Text("Submit",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      // todo: save into excel sheet online

                      FirebaseUser user = await FirebaseAuth.instance.currentUser();

                      await Firestore.instance.collection("Users").document(user.uid).get().then((DocumentSnapshot snapshot) async {
                        setState(() {
                          name = snapshot.data['name'];
                          email_id = snapshot.data['email'];
                          phone_number = snapshot.data['mobile'];
                        });
                      });


                      if(name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Name!')));
                      }else if(email_id.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Email ID!')));
                      }else if(phone_number.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Phone Number!')));
                      }else if(company_name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Company Name!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        EnquireServiceForm feedbackForm = EnquireServiceForm(
                            name,
                            email_id,
                            phone_number,
                            company_name,
                            widget.id
                        );

                        EnquireServiceFormController formController = EnquireServiceFormController((String response) {
                          print("Response: $response");
                          if (response == EnquireServiceFormController.STATUS_SUCCESS) {
                            // Feedback is saved succesfully in Google Sheets.
                            setState(() {
                              isLoading = false;
                            });
                            _showSnackbar("Enquiry Submitted");
                            Future.delayed(Duration(seconds: 3),(){
                              Navigator.pop(context);
                            });
                          } else {
                            // Error Occurred while saving data in Google Sheets.
                            setState(() {
                              isLoading = false;
                            });
                            _showSnackbar("Error Occurred!");
                          }
                        }
                        );

                        _showSnackbar("Submitting Enquiry");

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
