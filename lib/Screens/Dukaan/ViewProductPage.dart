import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_counter/flutter_counter.dart';
import 'package:ocd/Models/CartItem.dart';
import 'package:ocd/Screens/Dukaan/CartPage.dart';
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
      try {
        _cartItemList = CartItem.decodeCartItems(prefs.getString("cart_items"));
      }catch(e){
        _cartItemList = [];
      }
    });

    return is_guest;
  }

  int _quantity;

  List<String> _list = new List();
  List<CartItem> _cartItemList = new List();

  @override
  void initState() {

    checkIfGuest();
    _quantity = 1;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants().dukaanBackgroundColor,
      appBar: AppBar(
        backgroundColor: Constants().dukaanBackgroundColor,
        title: Text(widget.postMap['title']),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
      ),
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
                          height: screenHeight-330,
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
                      widget.postMap['buy_enable']? Container(
                        margin: EdgeInsets.only(left: 10, bottom: 15),
                        child: Row(
                          children: <Widget>[
                            Text("Quantity ", style: TextStyle(color: Constants().dukaanFontColor),),
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Constants().dukaanFontColor,),
                              onPressed: (){
                                if(_quantity>1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                            Text("$_quantity", style: TextStyle(color: Constants().dukaanFontColor),),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Constants().dukaanFontColor,),
                              onPressed: (){
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ): Container(),
                      Container(
                        margin: EdgeInsets.only(left: 10, bottom: 15),
                        child: Text("Total Price: "+(_quantity*int.parse(widget.postMap['price'].toString().contains(".")? widget.postMap['price'].toString().split(".")[0]: widget.postMap['price'])).toString(), style: TextStyle(color: Constants().dukaanFontColor, fontWeight: FontWeight.bold),)
                      ),
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
                            child: Text('Add to Cart', style: TextStyle(color: Colors.white),),
                            onPressed: () async {

//                              Navigator.of(context).push(MaterialPageRoute(
//                                  builder: (context)=> PaymentPage(
//                                    amount: (_quantity*int.parse(widget.postMap['price'])).toString(),
//                                    title: widget.postMap['title'],
//                                    description: widget.postMap['description'],
//                                  )
//                              ));


                            setState(() {
                             _cartItemList.add(
                               new CartItem(
                                   id: widget.id,
                                   total_amount: (int.parse(widget.postMap['price'])*_quantity).toString(),
                                   description: widget.postMap['description'],
                                   title: widget.postMap['title'],
                                   image: widget.postMap['product_image_url'][0],
                                   quantity: _quantity.toString(),
                                   price: widget.postMap['price']
                               ),
                             );
                            });

                             String encodedCartItems = CartItem.encodeCartItems(_cartItemList);

                             SharedPreferences prefs = await SharedPreferences.getInstance();
                             prefs.setString("cart_items", encodedCartItems);

                             _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item Added to Cart!"),));

                            },
                          ),
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
      floatingActionButton: FloatingActionButton(
        child: new Container(
            height: 150.0,
            width: 30.0,
            alignment: Alignment.center,
            child: new Stack(
              children: <Widget>[
                new IconButton(icon: new Icon(Icons.shopping_cart,
                  color: Colors.white,),
                  onPressed: null,
                ),
                _cartItemList.length ==0 ? new Container() :
                new Positioned(
                    child: new Stack(
                      children: <Widget>[
                        new Icon(
                            Icons.brightness_1,
                            size: 20.0, color: Colors.green[800]),
                        new Positioned(
                            top: 3.0,
                            right: 4.0,
                            child: new Center(
                              child: new Text(
                                _cartItemList.length.toString(),
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            )),
                      ],
                    )),
              ],
            )
        ),
        backgroundColor: Constants().navigationSelectedColor,
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CartPage()));
        },
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
