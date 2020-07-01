import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocd/Screens/Dukaan/PaymentPage.dart';
import './Screens/NavigationPage.dart';
import 'Screens/Register.dart';
import 'Screens/Login.dart';
import 'Screens/SplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCD',
      theme: ThemeData(
        primaryColor: Colors.redAccent,
      ),
      home: Scaffold(
        body: SplashScreen(), //NavigationPage(), //FirebaseAuth.instance.currentUser()!=null? NavigationPage() : Login(),
      ),
    );
  }
}