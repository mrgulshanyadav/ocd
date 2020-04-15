import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddReviewPage extends StatefulWidget {
  String rest_id;

  AddReviewPage({@required this.rest_id});

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<double> ratingList = [1.0,1.0,1.0,1.0,1.0];

  String review;


  bool isLoading;

  @override
  void initState() {
    review = "";

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth =  MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text("Write Review"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                        hintText: 'Review',
                        labelText: 'Review',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        review = input;
                      });
                    },
                  ),
                ),
                Container(
                  width: screenWidth,
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Quality', style: TextStyle(fontSize: 18),)
                ),
                new StarRating(
                  rating: ratingList[0],
                  onRatingChanged: (rating) => setState(() => this.ratingList[0] = rating),
                ),
                Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Quantity', style: TextStyle(fontSize: 18),)
                ),
                new StarRating(
                  rating: ratingList[1],
                  onRatingChanged: (rating) => setState(() => this.ratingList[1] = rating),
                ),
                Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Cost', style: TextStyle(fontSize: 18),)
                ),
                new StarRating(
                  rating: ratingList[2],
                  onRatingChanged: (rating) => setState(() => this.ratingList[2] = rating),
                ),
                Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Hygiene', style: TextStyle(fontSize: 18),)
                ),
                new StarRating(
                  rating: ratingList[3],
                  onRatingChanged: (rating) => setState(() => this.ratingList[3] = rating),
                ),
                Container(
                    width: screenWidth,
                    padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Ambience', style: TextStyle(fontSize: 18),)
                ),
                new StarRating(
                  rating: ratingList[4],
                  onRatingChanged: (rating) => setState(() => this.ratingList[4] = rating),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: !isLoading? RaisedButton(
                    child: Text("Post",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      if(review.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Review!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        await Firestore.instance.collection("Users").document(user.uid).get().then((userProfile){

                          double average_ratings = (ratingList[0]+ratingList[1]+ratingList[2]+ratingList[3]+ratingList[4])/5;
                          Map<String,dynamic> listMap = new Map();
                          listMap.putIfAbsent("review", ()=> review);
                          listMap.putIfAbsent("quality", ()=> ratingList[0].toString());
                          listMap.putIfAbsent("quantity", ()=> ratingList[1].toString());
                          listMap.putIfAbsent("cost", ()=> ratingList[2].toString());
                          listMap.putIfAbsent("hygiene", ()=> ratingList[3].toString());
                          listMap.putIfAbsent("ambience", ()=> ratingList[4].toString());
                          listMap.putIfAbsent("average_rating", ()=> average_ratings.toString());
                          listMap.putIfAbsent("posted_by", ()=> user.uid);
                          listMap.putIfAbsent("posted_by_name", ()=> userProfile.data['name']);

                          Firestore.instance.collection("Restaurants").document(widget.rest_id).collection('Reviews').document(user.uid).setData(listMap).whenComplete((){
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Review Posted"), duration: Duration(seconds: 3),));

                            setState(() {
                              isLoading = false;
                            });

                            Navigator.pop(context);

                          }).catchError((error){
                            setState(() {
                              isLoading = false;
                            });
                            print("Error: "+error.toString());
                          });

                        });

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
}


typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  double size = 35;

  StarRating({this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
        size: size,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size,
      );
    }
    return new InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
        child: new Row(mainAxisAlignment: MainAxisAlignment.start, children: new List.generate(starCount, (index) => buildStar(context, index)))
    );
  }
}