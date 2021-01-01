import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:multi_haber/constants.dart';
import 'package:multi_haber/model/User.dart';

import '../../main.dart';

class FireStoreUtils {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static DocumentReference currentUserDocRef =
      firestore.collection(Constants.USERS).doc(MyAppState.currentUser.userID);

  Future<OurUser> getCurrentUser(String uid) async {
    DocumentSnapshot userDocument =
        await firestore.collection(Constants.USERS).doc(uid).get();
    if (userDocument != null && userDocument.exists) {
      return OurUser.fromJson(userDocument.data());
    } else {
      return null;
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

  Future<OurUser> updateCurrentUser(OurUser user, BuildContext context) async {
    return await firestore
        .collection(Constants.USERS)
        .doc(user.userID)
        .set(user.toJson())
        .then((document) {
      return user;
    }, onError: (e) {
      print(e);
      showAlertDialog(context, 'Error', 'Failed to Update, Please try again.');
      return null;
    });
  }
}
