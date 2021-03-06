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

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _textEditingController = new TextEditingController();

  String name, type, footfall, event_location;


  File _image;

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
                          _image = image;
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
                        var image = await ImagePicker.pickImage(
                            source: ImageSource.gallery, maxHeight: 480, maxWidth: 640, imageQuality: 50);
                        setState(() {
                          _image = image;
                          Navigator.pop(context);
                        });
                      },
                    ),
                    _image != null
                        ? Divider(
                      thickness: 2,
                    ) : Container(),
                    _image != null
                        ? FlatButton(
                      child: Text(
                        "Remove Profile",
                        style: TextStyle(fontSize: 26),
                      ),
                      onPressed: () async {
                        setState(() {
                          _image = null;
                          Navigator.pop(context);
                        });
                      },
                    )
                        : Text("",),
                  ],
                ),
              ));
        });
  }

  bool isLoading;

  double lat, long;

  List<Placemark> addresses;

  Future<void> getLocationDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double _lat = prefs.getDouble('lat')?? 0.0;
    double _long = prefs.getDouble('long')?? 0.0;
    setState(() {
      lat = _lat;
      long = _long;
    });
    List<Placemark> _placemark = await Geolocator().placemarkFromCoordinates(_lat, _long);
    setState(() {
      addresses = _placemark;
      event_location = _placemark[0].locality+', '+_placemark[0].administrativeArea+', '+_placemark[0].country ?? _placemark[0].administrativeArea?? _placemark[0].country?? 'NA';
      _textEditingController.text = addresses[0].name +', '+addresses[0].thoroughfare +', '+ _placemark[0].locality+', '+_placemark[0].administrativeArea+', '+_placemark[0].country ?? _placemark[0].administrativeArea?? _placemark[0].country?? 'NA';
    });
    print('event_location: '+event_location);
    print('Address: '+ _placemark[0].name +', '+ _placemark[0].administrativeArea+', '+ _placemark[0].locality + ', '+ _placemark[0].subLocality+', '
        + _placemark[0].subAdministrativeArea +', '+ _placemark[0].country+ ', '+ _placemark[0].postalCode);

  }

  // get User location

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<void> getUserLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lat', _locationData.latitude);
    prefs.setDouble('long', _locationData.longitude);

    print('lat: '+_locationData.latitude.toString());
    print('long: '+_locationData.longitude.toString());

    location.onLocationChanged.listen((LocationData currentLocation) async {
      // Use current location
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble('lat', currentLocation.latitude);
      prefs.setDouble('long', currentLocation.longitude);

      print('updated lat: '+currentLocation.latitude.toString());
      print('updated long: '+currentLocation.longitude.toString());

    });

    setState(() {
      long = _locationData.longitude;
      lat = _locationData.latitude;
    });

  }


  @override
  void initState() {
    name = "";
    type = "";
    footfall = "";
    event_location = "";
    lat = 0.0;
    long = 0.0;

    isLoading = false;

    addresses = new List();

    getLocationDataFromSharedPreferences().whenComplete((){
      getUserLocation();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Event"),),
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
                    decoration: InputDecoration(
                        hintText: 'Event Name',
                        labelText: 'Event Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        name = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Event Type',
                        labelText: 'Event Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    onChanged: (input){
                      setState(() {
                        type = input;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Footfall',
                        labelText: 'Footfall',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (input){
                      setState(() {
                        footfall = input;
                      });
                    },
                  ),
                ),
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(style: BorderStyle.solid, width: 1, color: Colors.black54),
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    child:_image!=null? GestureDetector(onTap: ()=> getImage(context), child: Image.file(_image, fit: BoxFit.contain,)) : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Upload Picture', style: TextStyle(color: Colors.black54), textAlign: TextAlign.center,),
                          onPressed: (){
                            getImage(context);
                          },
                        )
                      ],
                    ),

                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: FocusScope(
                    canRequestFocus: false,
                    child: TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          hintText: 'Event Location',
                          labelText: 'Event Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                      ),
                      onChanged: (input){
                        setState(() {
                          event_location = input;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: !isLoading? RaisedButton(
                    child: Text("Post",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    padding: EdgeInsets.all(15),
                    onPressed: () async {
                      // save into database firebase

                      if(name.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Event Name!')));
                      }else if(type.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Event Type!')));
                      }else if(footfall.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Event Footfall!')));
                      }else if(event_location.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Enter Location!')));
                      } else if(_image==null){
                        _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text('Select Picture!')));
                      }else{

                        setState(() {
                          isLoading = true;
                        });

                        String file_name = 'event_'+DateTime.now().toIso8601String()+'.jpg';
                        final StorageReference storageReference = FirebaseStorage().ref().child('Event_Pictures/'+file_name);

                        final StorageUploadTask uploadTask = storageReference.putData(_image.readAsBytesSync());

                        final StreamSubscription<StorageTaskEvent> streamSubscription = uploadTask.events.listen((event) {
                          print('EVENT ${event.type}');
                        });

                        // Cancel your subscription when done.
                        await uploadTask.onComplete;
                        streamSubscription.cancel();

                        String post_pic_url;
                        storageReference.getDownloadURL().then((val) async {
                          post_pic_url = val;

                          FirebaseUser user = await FirebaseAuth.instance.currentUser();

                          Map<String,dynamic> listMap = new Map();
                          listMap.putIfAbsent("name", ()=> name);
                          listMap.putIfAbsent("type", ()=> type);
                          listMap.putIfAbsent("footfall", ()=> footfall);
                          listMap.putIfAbsent("location", ()=> event_location);
                          listMap.putIfAbsent("lat", ()=> lat);
                          listMap.putIfAbsent("long", ()=> long);
                          listMap.putIfAbsent("image", ()=> post_pic_url);
                          listMap.putIfAbsent("avg_rating", ()=> 'NA');


                          Firestore.instance.collection("Events").add(listMap).whenComplete((){
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Event Added"), duration: Duration(seconds: 3),));

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
