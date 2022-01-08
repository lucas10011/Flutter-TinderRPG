import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_isekai/models/settings.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/services/auth.dart';
import 'package:my_isekai/services/getmonster.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  //GoogleSignInAccount googleAccount;
  //final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    //print('...initUser...');
    User firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    print('...firebaseUserAuth...');
    UserPersonagem user = await Auth.getUserLocal();
    print('...user...');
    SettingsPersonagem settings = await Auth.getSettingsLocal();
     print('...user...');
    Stream stream;
     print('...stream...');
    Map monsters;
    print('...monsters...');
    DocumentSnapshot status;
    print('...status...');

    if(user != null){
      var getmonsters = await Monsters.getMonsters(user.user_level,user.coordinates);
       print('...getmonsters...');  
      monsters = await Monsters.getListMonsters(user.user_distance,user.id,getmonsters);
      print('...monsters...');
    }else{
      monsters = null;
      print('...monstersnull...');
    }
    
      if(firebaseUserAuth != null){
        try {
        stream = Firestore.instance.collection("userPositions").document("${firebaseUserAuth.uid}").collection("statusBattles").where('battle', isEqualTo: true).snapshots();
        status = await Firestore.instance.collection('userPositions').document('${firebaseUserAuth.uid}').collection('status').document('${firebaseUserAuth.uid}').get();
        }catch(e){
          print(e);
          stream = null;
          status = null;
        }
      }
      
      print('...firebaseUserAuth !=null...');

    
    setState(() {
      state.isLoading = false;
      state.firebaseUserAuth = firebaseUserAuth;
      state.user = user;
      state.settings = settings;
      state.stream = stream;
      state.monsters = monsters;
      state.status = status.data();
    });
    print("...setstate...");
  }

  Future<void> logOutUser() async {
    await Auth.signOut();
    User firebaseUserAuth = await Auth.getCurrentFirebaseUser();
    setState(() {
      state.user = null;
      state.settings = null;
      state.firebaseUserAuth = null;
      state.isLoading = false;
      state.stream = null;
      state.monsters = null;
      state.status = null;
    });
  }

  Future<void> logInUser(email, password) async {
    print(email);
    print(password);
    String userId = await Auth.signIn(email, password);
    print("userId $userId");
    UserPersonagem user = await Auth.getUserFirestore(userId);
    print("getUserFirestore $user");
    await Auth.storeUserLocal(user);
    print("storeUserLocal:$user");
    SettingsPersonagem settings = await Auth.getSettingsFirestore(userId);
    print("getSettingsFirestore:$settings");
    await Auth.storeSettingsLocal(settings);
    print("storeSettingsLocal:$settings");
    await initUser();
  }


  Future<void> removeMonster(Map item) async {
    setState(() {
      state.monsters['monstersAndPlayers'].remove(item);
    });
    
  }

    Future<void> removeTreasure(Map item) async {
    setState(() {
      state.monsters['treasure'].remove(item);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}