import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:multi_haber/multi_haber/multi_home_page.dart';

import 'package:multi_haber/model/User.dart';
import 'package:multi_haber/ui/services/Authenticate.dart';
import 'package:multi_haber/ui/utils/helper.dart';

import '../../constants.dart';
import '../../main.dart';

final _fireStoreUtils = FireStoreUtils();

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
      ),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
              child: Text(
                'Giriş Yap',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.next,
                  validator: validateEmail,
                  onSaved: (String val) {
                    email = val;
                  },
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: _emailController,
                  style: TextStyle(fontSize: 18.0),
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                    contentPadding: new EdgeInsets.only(left: 16, right: 16),
                    fillColor: Colors.white,
                    hintText: 'E-mail Adresi',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: TextFormField(
                    obscureText: true,
                    textAlignVertical: TextAlignVertical.center,
                    validator: validatePassword,
                    onSaved: (String val) {
                      email = val;
                    },
                    onFieldSubmitted: (password) async {
                      await onClick(
                          _emailController.text, _passwordController.text);
                    },
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(fontSize: 18.0),
                    cursorColor: Colors.blue,
                    decoration: InputDecoration(
                        contentPadding:
                            new EdgeInsets.only(left: 16, right: 16),
                        fillColor: Colors.white,
                        hintText: 'Şifre',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  splashColor: Colors.blue,
                  onPressed: () async {
                    await onClick(
                        _emailController.text, _passwordController.text);
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.blue)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  onClick(String email, String password) async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'Giriş Yapılıyor...', false);
      OurUser user =
          await loginWithUserNameAndPassword(email.trim(), password.trim());
      if (user != null) pushAndRemoveUntil(context, MultiHomePage(), false);
    } else {
      setState(() {
        _validate = AutovalidateMode.always;
      });
    }
  }

  showAlertDialog(BuildContext context, String title, String content) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            new FlatButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
              child: new Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Future<OurUser> loginWithUserNameAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      DocumentSnapshot documentSnapshot = await FireStoreUtils.firestore
          .collection(Constants.USERS)
          .doc(result.user.uid)
          .get();
      OurUser user;
      if (documentSnapshot != null && documentSnapshot.exists) {
        user = OurUser.fromJson(documentSnapshot.data());
        user.active = true;
        await _fireStoreUtils.updateCurrentUser(user, context);
        hideProgress();
        MyAppState.currentUser = user;
      }
      print("got user");
      return user;
    } catch (exception) {
      hideProgress();
      switch (exception.code) {
        case 'invalid-email':
          showAlertDialog(
              context, 'Giriş Yapılamadı', 'Geçerli Bir email giriniz');
          break;
        case 'wrong-password':
          showAlertDialog(context, 'Giriş Yapılamadı', 'hatalı şifre');
          break;
        case 'user-not-found':
          showAlertDialog(context, 'Giriş Yapılamadı', 'Kullanıcı Kulunamadı');
          break;
        case 'user-disabled':
          showAlertDialog(
              context, 'Giriş Yapılamadı', 'Kullanıcı devredışı bırakıldı');
          break;
        case 'too-many-requests':
          showAlertDialog(
              context, 'Giriş Yapılamadı', 'Birden fazla oturum açma denemesi');
          break;
        case 'operation-not-allowed':
          showAlertDialog(
              context, 'Giriş Yapılamadı', 'Email ve Şifre etkinleştirilmedi');
          break;
      }
      print(exception.toString());
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
