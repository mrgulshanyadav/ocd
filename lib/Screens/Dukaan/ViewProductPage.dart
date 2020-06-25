import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/Enquire/Controller/EnquireProductFormController.dart';
import 'package:ocd/Screens/Enquire/EnquireProductPage.dart';
import 'package:ocd/Screens/Enquire/Model/EnquireProductForm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants.dart';

class ViewProductPage extends StatefulWidget {
  Map<String, dynamic> postMap;
  String id;

  ViewProductPage({this.postMap, this.id});

  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;

  bool isGuest;
  Future<bool> checkIfGuest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool is_guest = prefs.getBool('isGuest')??false;
    setState(() {
      isGuest = is_guest;
    });

    return is_guest;
  }

  @override
  void initState() {

    checkIfGuest();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants().dukaanBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: screenHeight-40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Hero(
                      tag: widget.id,
                      child: Container(
                          width: screenWidth,
                          height: 280,
                          child: Image.network(widget.postMap["product_image_url"][0], fit: BoxFit.cover,)
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                                alignment: Alignment.topLeft,
                                padding: EdgeInsets.all(5),
                                child: Text(widget.postMap["title"], style: TextStyle(fontSize: 18, color:  Constants().dukaanFontColor), softWrap: true,)),
                          ),
                          Flexible(
                            child: Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.all(5),
                                child: Text('Rs.'+ widget.postMap["price"], style: TextStyle(fontSize: 18, color: Constants().dukaanFontColor), softWrap: true,)),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.white70,),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: Text(widget.postMap["description"], style: TextStyle(fontSize: 20, color: Constants().dukaanFontColor), softWrap: true,)),
                  ],
                ),

                Container(
                  child: Column(
                    children: <Widget>[
                      Divider(color: Colors.white70,),
                      widget.postMap['buy_enable']? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedGradientButton(
                            width: 100,
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
                            ),
                            child: Text('Buy', style: TextStyle(color: Colors.white),), onPressed: (){

                          },),
                          widget.postMap['enquire_enable']?
                          RaisedGradientButton(
                            width: 100,
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
                            ),
                            child: Text('Enquire', style: TextStyle(color: Colors.white),), onPressed: (){

                            saveProductDataToExcelSheet();
//                            Navigator.of(context).push(
//                                MaterialPageRoute(
//                                    builder: (context)=> EnquireProductPage(
//                                      id: widget.id,
//                                      postMap: widget.postMap,
//                                    )
//                                )
//                            );
                          },): Visibility(visible: false, child: Container(),),
                        ],
                      ):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget.postMap['enquire_enable']?
                          RaisedGradientButton(
                            width: 100,
                            gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
                            ),
                            child: Text('Enquire', style: TextStyle(color: Colors.white),), onPressed: (){

                            saveProductDataToExcelSheet();
//                            Navigator.of(context).push(
//                                MaterialPageRoute(
//                                    builder: (context)=> EnquireProductPage(
//                                      id: widget.id,
//                                      postMap: widget.postMap,
//                                    )
//                                )
//                            );
                          },): Visibility(visible: false, child: Container(),),
                        ],
                      ),
                      Divider(color: Colors.white70,),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveProductDataToExcelSheet() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String name, email_id, phone_number;
    await Firestore.instance.collection("Users").document(user.uid).get().then((DocumentSnapshot snapshot) async {
      name = snapshot.data['name'];
      email_id = snapshot.data['email'];
      phone_number = snapshot.data['mobile'];
    });

    EnquireProductForm feedbackForm = EnquireProductForm(
        name,
        email_id,
        phone_number,
        '',
        widget.id
    );

    EnquireProductFormController formController = EnquireProductFormController((String response) {
      print("Response: $response");
      if (response == EnquireProductFormController.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
//        setState(() {
//          isLoading = false;
//        });
        _showSnackbar("Enquiry Submitted");
//        Future.delayed(Duration(seconds: 3),(){
//          Navigator.pop(context);
//        });
      } else {
        // Error Occurred while saving data in Google Sheets.
//        setState(() {
//          isLoading = false;
//        });
        _showSnackbar("Error Occurred!");
      }
    }
    );

    _showSnackbar("Submitting Enquiry");

    // Submit 'feedbackForm' and save it in Google Sheets.
    formController.submitForm(feedbackForm);
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
