import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ocd/Screens/Vendor/Model/CollaborateWithOCDForm.dart';
import 'package:ocd/Screens/Vendor/Controller/CollaborateWithOCDFormController.dart';

class AddService extends StatefulWidget {
  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  String title, description, price;
  List<File> _image;

  Future getImage(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: SizedBox(
                height: _image!=null? 190 : 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Take a Picture",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640, imageQuality: 50);
                        setState(() {
                          if(image!=null){
                            _image.add(image);
                          }
                          Navigator.pop(context);
                        });
                      },
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    FlatButton(
                      child: Text(
                        "Pick from Gallery",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 640, imageQuality: 50);
                        setState(() {
                          if(image!=null){
                            _image.add(image);
                          }
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  bool isLoading;


  @override
  void initState() {
    title = '';
    description = '';
    price = '';

    _image = new List();

    isLoading = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;


    return Scaffold(
      appBar: AppBar(title: Text("Add Service"),),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    width: screenWidth,
                    height: 150,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(style: BorderStyle.solid, width: 1, color: Colors.black54),
                    ),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Upload Service Image', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center,),
                          onPressed: (){
                            if(_image.length<5){
                              getImage(context);
                            }else{
                              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Maximum of 5 images allowed'),));
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
                _image.length>0? Container(
                  child: GridView.builder(
                      itemCount: _image.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
                      itemBuilder: (context, index){

                        return Container(
                          height: 30,
                          width: screenWidth/2-10,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                  child: Image.file(_image[index], fit: BoxFit.contain,)
                              ),
                              Container(
                                height: 32,
                                width: 32,
                                margin: EdgeInsets.only(right: 10),
                                color: Colors.black12,
                                child: IconButton(
                                  icon: Icon(Icons.close, size: 16,),
                                  onPressed: (){
                                    if(_image.length>0){
                                      setState(() {
                                        _image.removeAt(index);
                                      });
                                    }
                                  },),
                              )
                            ],
                          ),
                        );
                      }
                  ),
                ): Container(),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Title',
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        title = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: 'Services included',
                        labelText: 'Services included',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                    ),
                    onChanged: (input){
                      setState(() {
                        description = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Price',
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    onChanged: (input){
                      setState(() {
                        price = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: !isLoading? RaisedButton(
                    child: Text("Add",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      // todo: save into excel sheet online

                      if(_image.length<1){
                      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Select Atleast 1 Service Image!')));
                      }else if(title.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Title!')));
                      }else if(description.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Description!')));
                      }else if(price.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Price!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        // todo: save product in database


                        List<String> service_image_url = new List();
                        for(int i=0;i<_image.length;i++){

                          String file_name = DateTime.now().toIso8601String()+i.toString()+'.jpg';
                          final StorageReference storageReference = FirebaseStorage().ref().child('Service_Images/'+file_name);

                          final StorageUploadTask uploadTask = storageReference.putData(_image[i].readAsBytesSync());

                          final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
                            // You can use this to notify yourself or your user in any kind of way.
                            // For example: you could use the uploadTask.events stream in a StreamBuilder instead
                            // to show your user what the current status is. In that case, you would not need to cancel any
                            // subscription as StreamBuilder handles this automatically.

                            // Here, every StorageTaskEvent concerning the upload is printed to the logs.
                            print('SERVICE ${event.type}');
                          });

                          // Cancel your subscription when done.
                          await uploadTask.onComplete;
                          streamSubscription.cancel();

                          await storageReference.getDownloadURL().then((val){
                            service_image_url.add(val);
                          });

                        }


                        Map<String,dynamic> userMap = new Map();
                        userMap.putIfAbsent("service_image_url", ()=> service_image_url);
                        userMap.putIfAbsent("title", ()=> title);
                        userMap.putIfAbsent("description", ()=> description);
                        userMap.putIfAbsent("price", ()=> price);
                        userMap.putIfAbsent("added_by", ()=> user.uid);

                        Firestore.instance.collection("Services").add(userMap).whenComplete(() async {
                          _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Service Added!')));

                          print('service added to firestore----------------------->>>>>>>>>>>>>>>>>>>>>>>>');
                          setState(() {
                            isLoading = false;
                          });

                          setState(() {
                            _image=new List();
                            title = '';
                            description = '';
                            price = '';
                          });

                        }).catchError((error){
                          setState(() {
                            isLoading = false;
                          });
                          print("Error: "+error.toString());
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
