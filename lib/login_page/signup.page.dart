
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:my_isekai/loading.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/services/auth.dart';
import 'package:my_isekai/services/validator.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nome = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  final TextEditingController _passwordConfirm = new TextEditingController();


  bool _autoValidate = false;
  bool _loadingVisible = false;
  DateTime selectedDate = DateTime.now();
  TextStyle style = TextStyle(color: Colors.white);
  OutlineInputBorder outlinefocus = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
          borderRadius: BorderRadius.circular(32.0)
        );
  OutlineInputBorder outlineenalbed = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(32.0)
        );

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1000, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'logo',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/dragon.png',
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
              color: Colors.white
            ),
          )),
    );

    final firstName = TextFormField(
      style: new TextStyle(color: Colors.white),
      autofocus: false,
      textCapitalization: TextCapitalization.words,
      controller: _nome,
      validator: Validator.validateName,
      decoration: InputDecoration(
        focusedBorder: outlinefocus,
        enabledBorder: outlineenalbed,
        
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Name',
        hintStyle: style,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );


    final email = TextFormField(
      style: new TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _email,
      validator: Validator.validateEmail,
      decoration: InputDecoration(
        focusedBorder: outlinefocus,
        enabledBorder: outlineenalbed,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Email',
        hintStyle: style,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
    final zodiac = Container(
        child: Text('O data influenciará nos seus atributos se baseando nas constelações do zodíaco',style: new TextStyle(color: Colors.white,fontSize: 12,fontStyle: FontStyle.italic),),
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        
      );
     final date = Container(
        child: FlatButton(
              shape: OutlineInputBorder(
                 borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(32.0)
                ),
              onPressed: () => _selectDate(context),
              child: selectedDate == null ? Text('Data de renascimento') :Text(DateFormat('dd/MM/yyyy').format(selectedDate),style: style,)
              ),
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        
      );
      
    
    


    final password = TextFormField(
      style: new TextStyle(color: Colors.white),
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        focusedBorder: outlinefocus,
        enabledBorder: outlineenalbed,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        hintStyle: style,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
     final passwordConfirm = TextFormField(
      style: new TextStyle(color: Colors.white),
      autofocus: false,
      obscureText: true,
      controller: _passwordConfirm,
      validator:(value){
      Pattern pattern = r'^.{6,}$';
      RegExp regex = new RegExp(pattern);
      if (value != _password.text) {
             return 'Password is not matching';
              }
      if (!regex.hasMatch(value))
        return 'Password must be at least 6 characters.';
      else
        return null;
      },
      decoration: InputDecoration(
        focusedBorder: outlinefocus,
        enabledBorder: outlineenalbed,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
            color: Colors.grey,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Password',
        hintStyle: style,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _emailSignUp(
              nome: _nome.text,
              date:selectedDate.millisecondsSinceEpoch.toString(),
              email: _email.text,
              password: _password.text,
              context: context);
        },
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text('SIGN UP', style: TextStyle(color: Colors.white)),
      ),
    );

    final signInLabel = FlatButton(
      child: Text(
        'Have an Account? Sign In.',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingScreen(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Container(
              decoration: BoxDecoration(
        // Box decoration takes a gradient
                gradient: LinearGradient(
                  // Where the linear gradient begins and ends
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  // Add one stop for each color. Stops should increase from 0 to 1
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    // Colors are easy thanks to Flutter's Colors class.
                    Colors.indigo[800],
                    Colors.indigo[700],
                    Colors.indigo[600],
                    Colors.indigo[400],
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      logo,
                      SizedBox(height: 48.0),
                      firstName,
                      SizedBox(height: 24.0),
                      email,
                      SizedBox(height: 24.0),
                      zodiac,
                      date,
                      SizedBox(height: 24.0),
                      password,
                      SizedBox(height: 24.0),
                      passwordConfirm,
                      SizedBox(height: 12.0),
                      signUpButton,
                      signInLabel
                    ],
                  ),
                ),
              ),
            ),
          ),
          inAsyncCall: _loadingVisible),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailSignUp(
      {String nome,
      String date,
      String email,
      String password,
      BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        GeoPoint location;
        var url = 'https://geolocation-db.com/json/';
         var response = await http.get(url);
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            location = new GeoPoint(jsonResponse['latitude'], jsonResponse['longitude']);
            print(jsonResponse['latitude']);
             print(jsonResponse['longitude']);
          } else {
            print('Request failed with status: ${response.statusCode}.');
            location = new GeoPoint(-22.5198, -44.079);
          }
          print('registro');
        // Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        // GeoPoint location = new GeoPoint(position.latitude, position.longitude);
        //need await so it has chance to go through error if found.
        await Auth.signUp(email, password).then((uID) {
          Auth.addUserSettingsDB(new UserPersonagem(
            id: uID,
            token: '',
            user_nome: nome,
            user_foto: '',
            user_date:date,
            user_descricao:'',
            user_titulo:'',
            user_raca:'',
            user_profissao:'',
            user_idade:'',
            user_pontoforte:'',
            user_pontofraco:'',
            user_level:1,
            user_distance:100,
            coordinates: location,
            createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          ));
        });
        //now automatically login user too
        //await StateWidget.of(context).logInUser(email, password);
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } catch (e) {
        _changeLoadingVisible();
        print("Sign Up Error: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Register Error",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
