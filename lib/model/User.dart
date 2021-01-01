import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class OurUser {
  String email = '';
  String firstName = '';
  String lastName = '';
  Settings settings = Settings(allowPushNotifications: true);

  bool active = false;
  Timestamp lastOnlineTimestamp = Timestamp.now();
  String userID;

  bool selected = false;
  String appIdentifier = 'Flutter ${Platform.operatingSystem}';

  OurUser({
    this.email,
    this.firstName,
    this.lastName,
    this.active,
    this.lastOnlineTimestamp,
    this.settings,
    this.userID,
  });

  String fullName() {
    return '$firstName $lastName';
  }

  factory OurUser.fromJson(Map<String, dynamic> parsedJson) {
    return new OurUser(
      email: parsedJson['email'] ?? "",
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      active: parsedJson['active'] ?? false,
      lastOnlineTimestamp: parsedJson['lastOnlineTimestamp'],
      settings: Settings.fromJson(
          parsedJson['settings'] ?? {'allowPushNotifications': true}),
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": this.email,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "settings": this.settings.toJson(),
      "id": this.userID,
      'active': this.active,
      'lastOnlineTimestamp': this.lastOnlineTimestamp,
      'appIdentifier': this.appIdentifier
    };
  }
}

class Settings {
  bool allowPushNotifications = true;

  Settings({this.allowPushNotifications});

  factory Settings.fromJson(Map<dynamic, dynamic> parsedJson) {
    return new Settings(
        allowPushNotifications: parsedJson['allowPushNotifications'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'allowPushNotifications': this.allowPushNotifications};
  }
}
