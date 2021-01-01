import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:multi_haber/config.dart';

import 'package:multi_haber/model/User.dart';

import 'package:multi_haber/ui/services/Authenticate.dart';

import 'package:multi_haber/multi_haber/multi_home_page.dart';
import 'package:multi_haber/ui/utils/helper.dart';

import 'ui/screens/AuthScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static OurUser currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //    theme: ThemeData(accentColor: Colors.blue),
      debugShowCheckedModeBanner: false,
      title: "Multi Haber",
      theme: currentTheme.currentTheme(),
      routes: {
        '/home': (context) => MultiHomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
      },
      color: Colors.blue,
      home: FutureBuilder(
        // Initialize FlutterFire
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.blue,
              body: Text("Hata Oluştu"),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return Landing();
          }

          return Scaffold(
            backgroundColor: Colors.blue,
            body: Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            )),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    currentTheme.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused) {
        //user offline
        currentUser.active = false;
        currentUser.lastOnlineTimestamp = Timestamp.now();
        FireStoreUtils.currentUserDocRef.update(currentUser.toJson());
      } else if (state == AppLifecycleState.resumed) {
        //user online
        currentUser.active = true;
        FireStoreUtils.currentUserDocRef.update(currentUser.toJson());
      }
    }
  }
}

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  User firebaseUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    landingProcess();
    super.initState();
  }

  Future landingProcess() async {
    if (firebaseUser != null) {
      OurUser user = await FireStoreUtils().getCurrentUser(firebaseUser.uid);
      if (user != null) {
        MyAppState.currentUser = user;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          pushAndRemoveUntil(context, MultiHomePage(), false);
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          pushAndRemoveUntil(context, AuthScreen(), false);
        });
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        pushAndRemoveUntil(context, AuthScreen(), false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      )),
    );
  }
}

/*

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}


class OnBoardingState extends State<OnBoarding> {
  Future hasFinishedOnBoarding() async {
    User firebaseUser = FirebaseAuth.instance.currentUser;
    print(firebaseUser);
    if (firebaseUser != null) {
      OurUser user = await FireStoreUtils().getCurrentUser(firebaseUser.uid);
      if (user != null) {
        MyAppState.currentUser = user;
        pushReplacement(context, new HomeScreen(user: user));
      } else {
        pushReplacement(context, new AuthScreen());
      }
    } else {
      pushReplacement(context, new OnBoardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
*/
