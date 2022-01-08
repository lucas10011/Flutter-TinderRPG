import 'dart:async';
import 'dart:math';
//import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/services.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:my_isekai/models/otherUser.dart';
import 'package:my_isekai/models/settings.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/services/calculo.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {
  static Future<String> signUp(String email, String password) async {
    User user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }


 

  static void addUserSettingsDB(UserPersonagem user){
    checkUserExist(user.id).then((value) async {
      if (!value) {
        String geohash = Geohash.encode(user.coordinates.latitude, user.coordinates.longitude);
        GeoPoint location = new GeoPoint(user.coordinates.latitude, user.coordinates.longitude);
        Map<String,dynamic> status = await Calculo.buildStatus(user);

          Firestore.instance
            .document("userPositions/${user.id}")
            .setData({
              'd':{
                'id':user.id,
                'user_nome':user.user_nome,
                'user_foto':user.user_foto,
                'user_date':user.user_date,
                'user_descricao':user.user_descricao,
                'user_titulo':status['user_titulo'],
                'user_raca':user.user_raca,
                'user_profissao':user.user_profissao,
                'user_idade':user.user_idade,
                'user_pontoforte':user.user_pontoforte,
                'user_pontofraco':user.user_pontofraco,
                'user_level':user.user_level,
                'user_distance':user.user_distance,
                'coordinates':location,
                'createdAt':user.createdAt},
              'g':geohash,
              'l':location  
            }).then((data){
                Firestore.instance
                .document("userPositions/${user.id}/status/${user.id}")
                .setData({
                    'agility':status['agility'],
                    'elementprimary':status['elementprimary'],
                    'elementsecondary':status['elementsecondary'],
                    'inteligence':status['inteligence'],
                    'strenght':status['strenght'],
                    'equipamento':{'weapon':null,
                                    'body':null,
                                    'head':null,
                                    'neck':null,
                                    'feet':null,
                                    'legs':null,
                                    'shield':null,
                                    'cape':null,
                                    'ring':null,
                                    'hands':null
                                    },
                    'zodiac':status['zodiac'],
                    'xp':status['xp'],
                }).then((onValue){
                   print("user ${user.user_nome} added");
                });

            });  
          
        _addSettings(new SettingsPersonagem(
          settingsId: user.id,
        ));
      } else {
        print("user ${user.user_nome} ${user.token} exists");
      }
    });
  }

  static Future<bool> checkUserExist(String id) async {
    bool exists = false;
    try {
      await Firestore.instance.document("users/$id").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static void _addSettings(SettingsPersonagem settings) async {
    Firestore.instance
        .document("settings/${settings.settingsId}")
        .setData(settings.toJson());
  }
  static Stream<String> get onAuthStateChanged {
    return FirebaseAuth.instance.onAuthStateChanged.map((User user) => user?.uid);
  }

  static Future<String> signIn(String email, String password) async {
    User user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  static Future<UserPersonagem> getUserFirestore(String id) async {
    if (id != null) {
      return Firestore.instance
          .collection('userPositions')
          .document(id)
          .get()
          .then((documentSnapshot) => UserPersonagem.fromDocument(documentSnapshot.data()));
    } else {
      print('firestore userId can not be null');
      return null;
    }
  }

  static Future<SettingsPersonagem> getSettingsFirestore(String settingsId) async {
    if (settingsId != null) {
      return Firestore.instance
          .collection('settings')
          .document(settingsId)
          .get()
          .then((documentSnapshot) => SettingsPersonagem.fromDocument(documentSnapshot));
    } else {
      print('no firestore settings available');
      return null;
    }
  }

  static Future<String> storeUserLocal(UserPersonagem user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //aprender como passar as cordernadas para string
    print(user.coordinates.toString());
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.id;
  }

  static Future<String> storeOtherUserLocal(OtherUser otherUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //aprender como passar as cordernadas para string
    print(otherUser.distanceBetween.toString());
    String storeUser = otherUserToJson(otherUser);
    await prefs.setString("${otherUser.id}", storeUser);
    return otherUser.id;
  }

  static Future<String> storeSettingsLocal(SettingsPersonagem settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeSettings = settingsToJson(settings);
    await prefs.setString('settings', storeSettings);
    return settings.settingsId;
  }

  static Future<User> getCurrentFirebaseUser() async {
    User currentUser = await FirebaseAuth.instance.currentUser;
    print(currentUser);
    return currentUser;
  }

  static Future<UserPersonagem> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      UserPersonagem user = userFromJson(prefs.getString('user'));
      //print('USER: $user');
      return user;
    } else {
      return null;
    }
  }

    static Future<OtherUser> getOtherUserLocal(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('$id') != null) {
      OtherUser otherUser = otherUserFromJson(prefs.getString('$id'));
      //print('USER: $user');
      return otherUser;
    } else {
      return null;
    }
  }

  static Future<SettingsPersonagem> getSettingsLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('settings') != null) {
      SettingsPersonagem settings = settingsFromJson(prefs.getString('settings'));
      //print('SETTINGS: $settings');
      return settings;
    } else {
      return null;
    }
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> forgotPasswordEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }


  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this email address not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'This email address already has an account.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }

  /*static Stream<User> getUserFirestore(String userId) {
    print("...getUserFirestore...");
    if (userId != null) {
      //try firestore
      return Firestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return User.fromDocument(doc);
        }).first;
      });
    } else {
      print('firestore user not found');
      return null;
    }
  }*/

  /*static Stream<Settings> getSettingsFirestore(String settingsId) {
    print("...getSettingsFirestore...");
    if (settingsId != null) {
      //try firestore
      return Firestore.instance
          .collection("settings")
          .where("settingsId", isEqualTo: settingsId)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
          return Settings.fromDocument(doc);
        }).first;
      });
    } else {
      print('no firestore settings available');
      return null;
    }
  }*/
}