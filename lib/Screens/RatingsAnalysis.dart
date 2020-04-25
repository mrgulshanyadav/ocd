import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class RatingsAnalysis extends StatefulWidget {
  String rest_id;

  RatingsAnalysis({@required this.rest_id});

  @override
  _RatingsAnalysisState createState() => _RatingsAnalysisState();
}

class _RatingsAnalysisState extends State<RatingsAnalysis> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  FirebaseUser user;
  List<Map<String,dynamic>> reviewsListMap;
  List keyLists;

  @override
  void initState() {

    reviewsListMap = new List();
    keyLists = new List();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(child: Container(
          child: FutureBuilder(
            future: getReviewsListsFromDatabase(widget.rest_id),
            builder: (context,res){

              if(!res.hasData){
                return Center(
                    child: CircularProgressIndicator()
                );
              }
              else{

                reviewsListMap = res.data;

                double quality_sum = 0;
                double quantity_sum = 0;
                double cost_sum = 0;
                double hygiene_sum = 0;
                double ambience_sum = 0;

                double quality_average = 0;
                double quantity_average = 0;
                double cost_average = 0;
                double hygiene_average = 0;
                double ambience_average = 0;

                int counter = 0;

                reviewsListMap.forEach((element){
                  quality_sum = quality_sum + double.parse(element['quality']);
                  quantity_sum = quantity_sum + double.parse(element['quantity']);
                  cost_sum = cost_sum + double.parse(element['cost']);
                  hygiene_sum = hygiene_sum + double.parse(element['hygiene']);
                  ambience_sum = ambience_sum + double.parse(element['ambience']);
                  counter++;
                });

                quality_average = quality_sum/counter;
                quantity_average = quantity_sum/counter;
                cost_average = cost_sum/counter;
                hygiene_average = hygiene_sum/counter;
                ambience_average = ambience_sum/counter;

                Map<String, double> dataMap = new Map();
                dataMap.putIfAbsent("Quality", () => quantity_average);
                dataMap.putIfAbsent("Quantity", () => quantity_average);
                dataMap.putIfAbsent("Cost", () => cost_average);
                dataMap.putIfAbsent("Hygiene", () => hygiene_average);
                dataMap.putIfAbsent("Ambience", () => ambience_average);

                return PieChart(
                  dataMap: dataMap,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 32.0,
                  chartRadius: MediaQuery.of(context).size.width / 1.3,
                  showChartValuesInPercentage: true,
                  showChartValues: true,
                  showChartValuesOutside: false,
                  chartValueBackgroundColor: Colors.grey[200],
                  colorList: [Colors.redAccent, Colors.greenAccent, Colors.blue, Colors.yellowAccent, Colors.black],
                  showLegends: true,
                  legendPosition: LegendPosition.bottom,
                  decimalPlaces: 1,
                  showChartValueLabel: true,
                  initialAngle: 0,
                  chartValueStyle: defaultChartValueStyle.copyWith(
                    color: Colors.blueGrey[900].withOpacity(0.9),
                  ),
                  chartType: ChartType.disc,
                );

              }

            },

          ),
        )),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getReviewsListsFromDatabase(String rest_id) async {
    user = await FirebaseAuth.instance.currentUser();
    QuerySnapshot collectionSnapshot = await Firestore.instance.collection("Restaurants").document(rest_id).collection('Reviews').getDocuments();
    List<Map<dynamic, dynamic>> list = new List();

    list = collectionSnapshot.documents.map((DocumentSnapshot docSnapshot){
      keyLists.add(docSnapshot.documentID);

      return docSnapshot.data;
    }).toList();

    return list;
  }

}