import 'package:flutter/material.dart';
import 'VendorSellServiceProduct.dart';
import 'VendorCollaborateWithOCD.dart';
import 'VendorSponsorshipForEvents.dart';

class VendorPage extends StatefulWidget {

  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Vendor'),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorSellServiceProduct()));
                },
                child: Container(
                  width: screenWidth,
                  height: screenHeight/3 - 100,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      gradient: LinearGradient(colors: [Colors.redAccent, Colors.red[200]])
                  ),
                  child: Text('Sell Service/Product', style: TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorCollaborateWithOCD()));
                },
                child: Container(
                  width: screenWidth,
                  height: screenHeight/3 - 100,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      gradient: LinearGradient(colors: [Colors.redAccent, Colors.red[200]])
                  ),
                  child: Text('Collaborate with OCD for events', style: TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorSponsorshipForEvents()));
                },
                child: Container(
                  width: screenWidth,
                  height: screenHeight/3 - 100,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      gradient: LinearGradient(colors: [Colors.redAccent, Colors.red[200]])
                  ),
                  child: Text('Sponsorship for events', style: TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}