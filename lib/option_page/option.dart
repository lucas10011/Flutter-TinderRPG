import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geohash/geohash.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/models/todo.dart';
import 'package:my_isekai/services/state_widget.dart';
import 'package:http/http.dart' as http;

class Options extends StatefulWidget {
  final int userDistance;
  Options({this.userDistance});
  @override
  _OptionsState createState() => _OptionsState(userDistance: userDistance);
}

class _OptionsState extends State<Options> {
  final int userDistance;
  _OptionsState({this.userDistance});

  StateModel appState;

     void _logout()  {
     Navigator.popUntil(context, ModalRoute.withName('/'));
     StateWidget.of(context).logOutUser();
  }

  double _sliderValue = 1.0;


  @override
  void initState() {
    print(userDistance);
      setState(() {
        _sliderValue = userDistance.toDouble();
      });
    super.initState();
  }


  _changeDistance()async{
   appState = StateWidget.of(context).state;
   UserPersonagem userLocal = appState.user;
    await Firestore.instance
              .collection('userPositions')
              .document(userLocal.id)
              .updateData({'d.user_distance':_sliderValue.toInt()}).then((data){ 
                  setState(() {
                    StateWidget.of(context).state.user.user_distance = _sliderValue.toInt();
                  });
                  Flushbar(
                  title: "Sucesso",
                  message: 'Distancia atualizada para ${_sliderValue.toInt()} ',
                  duration: Duration(seconds: 5),
                )..show(context);
          });
  }

  void updatePosition() async {
        appState = StateWidget.of(context).state;
        UserPersonagem userLocal = appState.user;
        // Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        // GeoPoint location = new GeoPoint(position.latitude, position.longitude);

        GeoPoint location;
        var url = 'https://geolocation-db.com/json/';
         var response = await http.get(url);
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            location = new GeoPoint(jsonResponse['latitude'], jsonResponse['longitude']);
          } else {
            print('Request failed with status: ${response.statusCode}.');
            location = new GeoPoint(-22.5198, -44.079);
          }

        String geohash = Geohash.encode(location.latitude, location.longitude);
        Firestore.instance.collection('userPositions').document('${userLocal.id}').updateData({'d.coordinates':location,'g':'$geohash','l':location}).then((onValue){
          Flushbar(
          title: "Sucesso",
          message: 'Localização atualizada',
          duration: Duration(seconds: 5),
        )..show(context);
        });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:BoxDecoration(
                    image: DecorationImage(image:new ExactAssetImage('assets/images/isekai.jpg'), fit: BoxFit.cover)             
                      ),
        child: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
            Text('Opções',style:TextStyle(color: Colors.black,fontSize: 40 ,fontWeight: FontWeight.w300,),textAlign: TextAlign.start,),
            Container(
              child:Column(children: <Widget>[
                    
                    Text('${_sliderValue.toInt()} Milhas',style:TextStyle(color: Colors.black,fontSize: 30 ,fontWeight: FontWeight.w300)),
                    Slider(
                      activeColor: Colors.indigoAccent,
                      min: 1.0,
                      max: 5000.0,
                      onChanged: (newRating) {
                        setState(() => _sliderValue = newRating);
                      },
                      value: _sliderValue,
                    ),
                    RaisedButton(
                      color: Colors.green,
                      onPressed: _changeDistance,
                      child: Text('Salvar',style:TextStyle(color: Colors.white) ,),),
                      
                      
              ],)
            ,),
            RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: updatePosition,
                      child: Text('Atualizar localização',style:TextStyle(color: Colors.white) ,),),
            RaisedButton(
              color: Colors.indigo[700],
              onPressed: _logout,
              child: Text('Logout',style: TextStyle(color: Colors.white),),)
          ],) ),
      ),      
    );
  }
}