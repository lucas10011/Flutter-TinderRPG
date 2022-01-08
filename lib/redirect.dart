
import 'package:flutter/material.dart';
import 'package:my_isekai/awaitscreen.dart';
import 'package:my_isekai/home.dart';

import 'package:my_isekai/login_page/login.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/services/state_widget.dart';

class LandingPage extends StatelessWidget {

   StateModel appState;

    @override
    Widget build(BuildContext context) {
      appState = StateWidget.of(context).state;
    //   Navigator.popUntil(context, ModalRoute.withName('/'));
    //  StateWidget.of(context).logOutUser();
      if (!appState.isLoading &&
          (appState.firebaseUserAuth == null ||
              appState.user == null ||
              appState.settings == null || appState.stream == null)) {
        return LoginPage();
      } else if (!appState.isLoading && (appState.firebaseUserAuth != null ||
              appState.user != null ||
              appState.settings != null || appState.stream != null)){
        return Home();
    }else{
        return AwaitPage();
    }
  }
}