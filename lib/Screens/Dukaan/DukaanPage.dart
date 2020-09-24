import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Constants.dart';
import 'package:ocd/Models/CartItem.dart';
import 'package:ocd/Screens/Dukaan/CartPage.dart';
import 'package:ocd/Screens/Dukaan/ViewServicePage.dart';
import 'package:ocd/Screens/Enquire/Controller/EnquireProductFormController.dart';
import 'package:ocd/Screens/Enquire/EnquireProductPage.dart';
import 'package:ocd/Screens/Enquire/EnquireServicePage.dart';
import 'package:ocd/Screens/Enquire/Model/EnquireProductForm.dart';
import '../Dukaan/ViewProductPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Login.dart';

class DukaanPage extends StatefulWidget {
  @override
  _DukaanPageState createState() => _DukaanPageState();
}

class _DukaanPageState extends State<DukaanPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;
  List<Map<String,dynamic>> productListMap;
  List productKeyLists;

  List<Map<String,dynamic>> serviceListMap;
  List serviceKeyLists;

  bool isGuest;

  List<String> _list= new List();
  List<CartItem> _cartItemList = new List();

  Future<void> getLocationDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isGuest = prefs.getBool('isGuest')??false;
      try {
        _cartItemList = CartItem.decodeCartItems(prefs.getString("cart_items"));
      }catch(e){
        _cartItemList = [];
      }
    });
  }

  @override
  void initState() {

    isGuest = false;
    getLocationDataFromSharedPreferences();

    productListMap = new List();
    productKeyLists = new List();

    serviceListMap = new List();
    serviceKeyLists = new List();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    return !isGuest? DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Constants().dukaanBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(125),
          child: AppBar(
            title: Container(
              height: 150,
              child: Image.asset("assets/images/dukaanlogo.jpg", fit: BoxFit.scaleDown)
            ),
//          Text('Dukaan', style: TextStyle(color: Constants().dukaanFontColor),),
            centerTitle: true,
//          actions: <Widget>[IconButton(icon: Icon(Icons.more_vert), onPressed: (){},)],
            backgroundColor: Constants().dukaanBackgroundColor,
            bottom: TabBar(tabs: [
              Tab(child: Text('Products', style: TextStyle(color: Constants().dukaanFontColor),),),
              Tab(child: Text('Ocdcurates', style: TextStyle(color: Constants().dukaanFontColor),),),
            ]),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: getProductsListFromDatabase(),
              builder: (context, res){

                if(!res.hasData){
                  return Center(child: CircularProgressIndicator());
                }else{

                  productListMap = res.data;

                  print('listMap.toString(): '+productListMap.toString());

                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    color: Colors.transparent,
                    child: GridView.builder(
                        itemCount: productListMap.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 1.4),
                        ),
                        itemBuilder: (context, index){

                          return GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context)=> ViewProductPage(
                                        id: productKeyLists[index],
                                        postMap: productListMap[index],
                                      )
                                  )
                              );
                            },
                            child: Card(
                              elevation: 2,
                              color: Colors.transparent,
                              child: Container(
                                height: 315,
                                color: Colors.transparent,
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: (screenWidth/2) - 60,
                                      width: screenWidth,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(9)),
                                        child: Image.network(
                                          productListMap[index]['product_image_url'][0],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.all(5),
                                      child: Text(productListMap[index]['title'], style: TextStyle(fontSize: 18, color: Constants().dukaanFontColor),),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                        padding: EdgeInsets.only(left: 5),
                                      child: Text('Rs.'+productListMap[index]['price'], style: TextStyle(fontSize: 18, color: Constants().dukaanFontColor),)
                                    ),
//                                    Row(
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        productListMap[index]['buy_enable']? RaisedGradientButton(
//                                          width: 75,
//                                          gradient: LinearGradient(
//                                            begin: FractionalOffset.topCenter,
//                                            end: FractionalOffset.bottomCenter,
//                                            colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
//                                          ),
//                                          child: Text('Buy', style: TextStyle(color: Colors.white),), onPressed: (){
//
//                                        },): Container(),
//                                        productListMap[index]['enquire_enable']? RaisedGradientButton(
//                                          width: 75,
//                                          gradient: LinearGradient(
//                                            begin: FractionalOffset.topCenter,
//                                            end: FractionalOffset.bottomCenter,
//                                            colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
//                                          ),
//                                          child: Text('Enquire', style: TextStyle(color: Colors.white),), onPressed: (){
//
//                                          saveProductDataToExcelSheet(productKeyLists[index]);
//
//                                        },): Container(),
//                                      ],
//                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                        }
                    ),
                  );
                }
              },
            ),
            FutureBuilder(
              future: getServicesListFromDatabase(),
              builder: (context, res){

                if(!res.hasData){
                  return Center(child: CircularProgressIndicator());
                }else{

                  serviceListMap = res.data;

                  print('serviceListMap.toString(): '+serviceListMap.toString());

                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    color: Colors.transparent,
                    child: GridView.builder(
                        itemCount: serviceListMap.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 1.4),
                        ),
                        itemBuilder: (context, index){

                          return GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context)=> ViewServicePage(
                                        id: serviceKeyLists[index],
                                        postMap: serviceListMap[index],
                                      )
                                  )
                              );
                            },
                            child: Card(
                              elevation: 2,
                              color: Colors.transparent,
                              child: Container(
                                height: 315,
                                margin: EdgeInsets.all(10),
                                color: Colors.transparent,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: (screenWidth/2)-60,
                                      width: screenWidth,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(9)),
                                        child: Image.network(
                                          serviceListMap[index]['service_image_url'][0],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.all(5),
                                      child: Text(serviceListMap[index]['title'], style: TextStyle(fontSize: 18, color: Constants().dukaanFontColor),),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                        padding: EdgeInsets.only(left: 5),
                                      child: Text('Rs.'+serviceListMap[index]['price'], style: TextStyle(fontSize: 18, color: Constants().dukaanFontColor),)
                                    ),
//                                    Row(
//                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        serviceListMap[index]['buy_enable']?
//                                        RaisedGradientButton(
//                                          width: 75,
//                                          gradient: LinearGradient(
//                                            begin: FractionalOffset.topCenter,
//                                            end: FractionalOffset.bottomCenter,
//                                            colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
//                                          ),
//                                          child: Text('Buy', style: TextStyle(color: Colors.white),), onPressed: (){
//
//                                        },): Container(),
//                                        serviceListMap[index]['enquire_enable']?
//                                        RaisedGradientButton(
//                                          width: 75,
//                                          gradient: LinearGradient(
//                                            begin: FractionalOffset.topCenter,
//                                            end: FractionalOffset.bottomCenter,
//                                            colors: <Color>[Constants().dukaanMenuBackgroundColor, Constants().dukaanMenuBackgroundColor],
//                                          ),
//                                          child: Text('Book', style: TextStyle(color: Colors.white),), onPressed: () async {
//
//                                          saveServiceDataToExcelSheet(serviceKeyLists[index]);
//
////                                          Navigator.of(context).push(
////                                              MaterialPageRoute(
////                                                  builder: (context)=> EnquireServicePage(
////                                                    id: serviceKeyLists[index],
////                                                    postMap: serviceListMap[index],
////                                                  )
////                                              )
////                                          );
//                                        },): Container(),
//                                      ],
//                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: new Container(
              height: 40.0,
              width: 40.0,
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
      ),
    ):
    Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text("Login First", style: TextStyle(color: Colors.white),),
              onPressed: () async {
                // open link

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context){
                      return Login();
                    }
                ));

              },
              color: Colors.blueAccent,
            ),
          ),
        )
      ),
    );
  }


  getProductsListFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Products").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      productKeyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    return list;
  }

  getServicesListFromDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Services").getDocuments();
    List<DocumentSnapshot> templist;
    List<Map<dynamic, dynamic>> list = new List();

    templist = collectionSnapshot.documents;

    list = templist.map((DocumentSnapshot docSnapshot){
      serviceKeyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();


    return list;
  }

  void saveServiceDataToExcelSheet(String id) async {
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
        id
    );

    EnquireProductFormController formController = EnquireProductFormController((String response) {
      print("Response: $response");
      if (response == EnquireProductFormController.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
//                                setState(() {
//                                  isLoading = false;
//                                });
        _showSnackbar("Enquiry Submitted");
//        Future.delayed(Duration(seconds: 3),(){
//          Navigator.pop(context);
//        });
      } else {
        // Error Occurred while saving data in Google Sheets.
//                                setState(() {
//                                  isLoading = false;
//                                });
        _showSnackbar("Error Occurred!");
      }
    }
    );

    _showSnackbar("Submitting Enquiry");

    // Submit 'feedbackForm' and save it in Google Sheets.
    formController.submitForm(feedbackForm);
  }

  void saveProductDataToExcelSheet(String id) async {
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
        id
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
    this.width = 75,
    this.height = 30.0,
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