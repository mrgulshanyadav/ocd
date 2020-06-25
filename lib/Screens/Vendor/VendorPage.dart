import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Constants.dart';
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
          child: Container(
            height: screenHeight-80,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/4.jpg"),
                fit: BoxFit.fill,
              )
            ),
            child: Column(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorSellServiceProduct()));
                  },
                  child: Container(
                    width: screenWidth,
                    height: 90,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text('Sell Service/Product', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 26), textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorCollaborateWithOCD()));
                  },
                  child: Container(
                    width: screenWidth,
                    height: 90,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text('Collaborate With OCD for Events', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 26), textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VendorSponsorshipForEvents()));
                  },
                  child: Container(
                    width: screenWidth,
                    height: 90,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Text('Sponsorship for events', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 26), textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}