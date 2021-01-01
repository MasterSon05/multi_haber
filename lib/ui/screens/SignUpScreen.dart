import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_haber/multi_haber/multi_home_page.dart';
import 'package:multi_haber/model/User.dart';
import 'package:multi_haber/ui/services/Authenticate.dart';
import 'package:multi_haber/ui/utils/helper.dart';
//import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

import '../../main.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  TextEditingController _passwordController = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String firstName, lastName, email, mobile, password, confirmPassword;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      //  retrieveLostData();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: new Form(
            key: _key,
            autovalidateMode: _validate,
            child: formUI(),
          ),
        ),
      ),
    );
  }

//  Future<void> retrieveLostData() async {
//    final LostDataResponse response = await ImagePicker.retrieveLostData();
//    if (response == null) {
//      return;
//    }
//    if (response.file != null) {
//      setState(() {
//        _image = response.file;
//      });
//    }
//  }

  Widget formUI() {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Yeni Hesap Oluştur',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            )),
        Container(
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    //validator: validateName,
                    onSaved: (String val) {
                      firstName = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Adınız',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    //  validator: validateName,
                    onSaved: (String val) {
                      lastName = val;
                    },
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Soyadınız',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: validateEmail,
                    onSaved: (String val) {
                      email = val;
                    },
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        fillColor: Colors.white,
                        hintText: 'Email Adresiniz',
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ))))),
        ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
              child: TextFormField(
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  controller: _passwordController,
                  validator: validatePassword,
                  onSaved: (String val) {
                    password = val;
                  },
                  style: TextStyle(height: 0.8, fontSize: 18.0),
                  cursorColor: Colors.blue,
                  decoration: InputDecoration(
                      contentPadding:
                          new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      fillColor: Colors.white,
                      hintText: 'Şifre',
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ))),
            )),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: TextFormField(
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _sendToServer();
                },
                obscureText: true,
                validator: (val) =>
                    validateConfirmPassword(_passwordController.text, val),
                onSaved: (String val) {
                  confirmPassword = val;
                },
                style: TextStyle(height: 0.8, fontSize: 18.0),
                cursorColor: Colors.blue,
                decoration: InputDecoration(
                    contentPadding:
                        new EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: Colors.white,
                    hintText: 'Şifre Doğrulama',
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                'Üye Ol',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              textColor: Colors.white,
              splashColor: Colors.blue,
              onPressed: _sendToServer,
              padding: EdgeInsets.only(top: 12, bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.blue)),
            ),
          ),
        ),
      ],
    );
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

  _sendToServer() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'Yeni Üye Oluşturuluyor.....', false);

      try {
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
//        if (_image != null) {
//          updateProgress('Uploading image, Please wait...');
//          profilePicUrl = await FireStoreUtils()
//              .uploadUserImageToFireStorage(_image, result.user.uid);
//        }
        OurUser user = OurUser(
          email: email,
          firstName: firstName,
          userID: result.user.uid,
          active: true,
          lastName: lastName,
          settings: Settings(allowPushNotifications: true),
        );
        await FireStoreUtils.firestore
            .collection(Constants.USERS)
            .doc(result.user.uid)
            .set(user.toJson());
        hideProgress();
        MyAppState.currentUser = user;
        pushAndRemoveUntil(context, MultiHomePage(), false);
      } catch (error) {
        hideProgress();
        (error as PlatformException).code != 'ERROR_EMAIL_ALREADY_IN_USE'
            ? showAlertDialog(context, 'Failed', 'Kullanıcı Oluşturulamadı!!!')
            : showAlertDialog(
                context, 'Failed', 'Bu mail adresi zaten kullanımda!!');
        print(error.toString());
      }
    } else {
      print('false');
      setState(() {
        _validate = AutovalidateMode.always;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }
}
