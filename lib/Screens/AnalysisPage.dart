import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocd/Constants.dart';

class AnalysisPage extends StatefulWidget {

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  FirebaseUser user;
  Map<String, dynamic> loginRecordsMap;
  Map<String, dynamic> userMap;

  // streak counter
  int counter=0;

  @override
  void initState() {

    loginRecordsMap = new Map();
    userMap = new Map();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Login Analysis"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              Container(
                padding: EdgeInsets.all(10),
                child: Text('Your Login Records', style: TextStyle(color: Constants().blueFontColor),),
              ),
              FutureBuilder(
                future: getLoginRecords(),
                builder: (context, res){

                  if(!res.hasData){
                    return Center(child: CircularProgressIndicator(),);
                  }else{

                    loginRecordsMap = userMap['login_record'];

                    List<LoginPerDay> loginPerDayList = new List();
                    counter = 0;
                    loginRecordsMap.forEach((k,v){
                      v==true? counter++ : counter=0;
                      loginPerDayList.add(new LoginPerDay(k, v==true ? 1 : 0, Constants().blueFontColor));
                    });

                    var series = [
                      new charts.Series(
                        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Constants().blueFontColor),
                        id: 'Visited',
                        domainFn: (LoginPerDay clickData, _) => clickData.date,
                        measureFn: (LoginPerDay clickData, _) => clickData.isLogged,
                        data: loginPerDayList,
                      ),
                    ];

                    return Column(
                      children: <Widget>[
                        new AspectRatio(
                          aspectRatio: 8 / 3,
                          child: Container(
                            color: Colors.black12,
                            child: charts.BarChart(
                              series,
                              animate: true,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'YOU\'VE BEEN REGULAR FOR '+counter.toString()+' DAYS in a row',
                            style: TextStyle(color: Constants().blueFontColor),
                          ),
                        ),
                      ],
                    );

                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getLoginRecords() async {
    user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("Users").document(user.uid).get();

    userMap.addAll(documentSnapshot.data);

    return documentSnapshot.data["login_record"];
  }

}

class LoginPerDay {
  final String date;
  final int isLogged;
  Color color = Constants().blueFontColor;

  LoginPerDay(this.date, this.isLogged, this.color);
}