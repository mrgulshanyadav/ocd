import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalysisPage extends StatefulWidget {

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  var series = [
    new charts.Series(
      id: 'Visited',
      domainFn: (LoginPerDay clickData, _) => clickData.date,
      measureFn: (LoginPerDay clickData, _) => clickData.isLogged,
//      colorFn: (LoginPerDay clickData, _) => clickData.color,
      data: [
        new LoginPerDay('19-04-2020', 2, Colors.green),
        new LoginPerDay('20-04-2020', 12, Colors.green),
        new LoginPerDay('21-04-2020', 42, Colors.green),
      ],
    ),
  ];


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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              new AspectRatio(
                aspectRatio: 8 / 3,
                child: Container(
                  child: charts.BarChart(
                    series,
                    animate: true,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class LoginPerDay {
  final String date;
  final int isLogged;
  final Color color;

  LoginPerDay(this.date, this.isLogged, this.color);
}