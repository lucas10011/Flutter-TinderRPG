import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:my_isekai/models/settings.dart';
import 'package:my_isekai/models/todo.dart';


class StateModel {
  bool isLoading;
  User firebaseUserAuth;
  UserPersonagem user;
  SettingsPersonagem settings;
  Stream stream;
  Map monsters;
  Map status;

  StateModel({
    this.isLoading = false,
    this.firebaseUserAuth,
    this.user,
    this.settings,
    this.stream,
    this.monsters,
    this.status
  });
}