import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:my_isekai/maps_page/servicesmap/servicesmap.dart';
import 'package:my_isekai/models/state.dart';
import 'package:my_isekai/models/todo.dart';

import 'package:my_isekai/services/state_widget.dart';
import 'package:flutter/services.dart' show rootBundle;

class GoogleMaps extends StatefulWidget {
  final UserPersonagem user;
  final Function loading;
  final int distance;
  final Map monsters;
  GoogleMaps({this.user,this.loading,this.distance,this.monsters});
  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  final int targetWidth = 64;
  final int targetHeight= 64;
  BitmapDescriptor customIcon;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};


  MarkerId myMarker;

  GoogleMapController mapController;

  StateModel appState;

  String _mapStyle;

  Position currentLocation;
  
 bool _loadingAtualization = false;
  


  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/mapstyle/map_style.txt').then((string) {
        
          setState(() {
            _mapStyle = string;
          });
        });
        
      // if(mounted){
      //   addMyMarker();
      //   markersMonstersAndUsers(widget.monsters['monstersAndPlayers']);
      //   markersTreasures(widget.monsters['treasure']);
      //   }
    
  }


markersMonstersAndUsers(data)async{
    for (int i = 0; i < data.length; i++){

        if(data[i]['monster'] == true){
          markerMonster(data[i]);
        }else{
          markerUser(data[i],widget.user.id);
        }
                
    }
}

addMyMarker() async {
            LatLng center = LatLng(widget.user.coordinates.latitude,widget.user.coordinates.longitude);  
            var markerIdVal = IsekaiMaps.generateIds();
            final MarkerId markerId = MarkerId(markerIdVal.toString());
            myMarker = markerId;
             
              final Marker marker = Marker(
                markerId: markerId,
                icon: await IsekaiMaps.getMarkerIcon(widget.user.user_foto,widget.user.user_level, Size(150.0, 150.0),Colors.blue.withAlpha(100)),
                position: center,
                infoWindow: InfoWindow(title: widget.user.user_nome, snippet: widget.user.user_titulo)
              );
              if(mounted){
                setState(() {
                markers[markerId] = marker;
                });
                  
              }
                        
}

markerUser(otheruser,id) async {


     
          //   Uint8List resizedMarkerImageBytes;

          // if(datafiltered[i]['user_foto'] != ''){
          //   final File markerImageFile = await DefaultCacheManager().getSingleFile(datafiltered[i]['user_foto']);
          //   final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
          //   final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
          //     markerImageBytes,
          //     targetWidth: targetWidth,
          //     targetHeight: targetWidth,
          //   );
          //   final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
          //   final ByteData byteData = await frameInfo.image.toByteData(
          //     format: ui.ImageByteFormat.png,
          //   );
          //       resizedMarkerImageBytes = byteData.buffer.asUint8List();   
          // }else{
          //       resizedMarkerImageBytes = await getBytesFromAsset('assets/images/default.jpg',100);
          // }
        
          LatLng positionPeople = LatLng(otheruser['coordinates']['_latitude'],otheruser['coordinates']['_longitude']);   
            var markerIdVal = IsekaiMaps.generateIds();
            final MarkerId markerId = MarkerId(markerIdVal.toString());
              if(otheruser['id'] == id){
                setState(() {
                  myMarker = markerId;
                });
              }
              final Marker marker = Marker(
                markerId: markerId,
                icon: await IsekaiMaps.getMarkerIcon(otheruser['user_foto'],otheruser['user_level'], Size(125.0, 125.0),Colors.blue.withAlpha(100)),
                position: positionPeople,
                infoWindow: InfoWindow(title: otheruser['user_nome'], snippet: otheruser['user_titulo'])
              );
              if(mounted){
                setState(() {
                markers[markerId] = marker;
                });
                  
              }
                        
}

markerMonster(monsterSingle)async{

            //   Uint8List resizedMarkerImageBytes;
            //   final File markerImageFile = await DefaultCacheManager().getSingleFile(monsters[i]['img']);
            //   final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
            //   final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
            //   markerImageBytes,
            //   targetWidth: targetWidth,
            //   targetHeight: targetWidth,
            // );
            // final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
            // final ByteData byteData = await frameInfo.image.toByteData(
            //   format: ui.ImageByteFormat.png,
            // );
            //   resizedMarkerImageBytes = byteData.buffer.asUint8List();
            Color colorDificulty;

            if(monsterSingle['difficulty'] == 'S'){
              colorDificulty = Colors.red[900].withAlpha(100);
            }else if(monsterSingle['difficulty'] == 'A'){
              colorDificulty = Colors.yellow[700].withAlpha(100);
            }else if(monsterSingle['difficulty'] == 'B'){
              colorDificulty = Colors.blue[700].withAlpha(100);
            }else if(monsterSingle['difficulty'] == 'C'){
              colorDificulty = Colors.green[700].withAlpha(100);
            }else{
              colorDificulty = Colors.grey[700].withAlpha(100);
            }
        

            LatLng positionPeople = LatLng(monsterSingle['position']['latitude'],monsterSingle['position']['longitude']);   
              var markerIdVal = IsekaiMaps.generateIds();
              final MarkerId markerId = MarkerId(markerIdVal.toString());
                final Marker marker = Marker(
                  markerId: markerId,
                  icon: await IsekaiMaps.getMarkerIcon(monsterSingle['img'],monsterSingle['difficulty'], Size(120.0, 120.0),colorDificulty),
                  position: positionPeople,
                  infoWindow: InfoWindow(title: monsterSingle['name'], snippet: "level:${monsterSingle['level']} || rank:${monsterSingle['difficulty']}")
                );
                if(mounted){
                  setState(() {
                    markers[markerId] = marker;
                  }); 
                }
                
            
}
markersTreasures(data) async {
     for (int i = 0; i < data.length; i++){ 

              var treasureSingle = data[i];

               var imageBytes = await IsekaiMaps.getBytesFromAsset('assets/images/drop.jpg',100);

              LatLng positionPeople = LatLng(treasureSingle['latitude'],treasureSingle['longitude']);   
                var markerIdVal = IsekaiMaps.generateIds();
                final MarkerId markerId = MarkerId(markerIdVal.toString());
                  final Marker marker = Marker(
                    markerId: markerId,
                    icon: BitmapDescriptor.fromBytes(imageBytes),
                    position: positionPeople,
                    infoWindow: InfoWindow(title: 'Treasure',),
                    onTap: () {
                     _showDialog(markerId,data[i]);
                              }
                  );
                  if(mounted){
                    setState(() {
                      markers[markerId] = marker;
                    }); 
                  }
                
              }
  }






void removeMarkerId(markerId){
  print(markerId);
  print(markers[markerId]);
  setState(() {
     markers.removeWhere((key, value) => key == markerId);
  });
}

void removeTreasure(treasure){

  setState(() {
     StateWidget.of(context).removeTreasure(treasure);
  });
}

void _showDialog(MarkerId markerId,Map treasure) {
    var distance = IsekaiMaps.distanceBetween(treasure['latitude'],treasure['longitude'],widget.user.coordinates.latitude,widget.user.coordinates.longitude);
    var distanceFaltante = num.parse((distance - 0.15).toStringAsFixed(2));
    String tipodistancia;
    if(distanceFaltante < 1){
      tipodistancia = 'metros';
      distanceFaltante = (distanceFaltante * 1000).toInt();
    }else{
      tipodistancia = 'km';
    }
    showGeneralDialog(
    barrierColor: Colors.black.withOpacity(0.15),
    transitionBuilder: (context, a1, a2, widget) {
      final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0)),
          title:Text('Tesouro '),
          
          content:distance < 0.15 ?
          OpenChest(removeMarkerId:removeMarkerId,markerId:markerId,removeTreasure:removeTreasure,treasure:treasure)
          :
          Text('Voce esta muito longe, faltam $distanceFaltante $tipodistancia para poder abrir o tesouro')
          ,  
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            
          ],
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {});

    
}

void updatePosition() async {
        setState(() {
          _loadingAtualization = true;
        });
        appState = StateWidget.of(context).state;
        UserPersonagem userLocal = appState.user;
        Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        GeoPoint location = new GeoPoint(position.latitude, position.longitude);
        String geohash = Geohash.encode(position.latitude, position.longitude);
        Firestore.instance.collection('userPositions').document('${userLocal.id}').updateData({'d.coordinates':location,'g':'$geohash','l':location}).then((onValue){
           Marker marker = markers[myMarker];
            setState(() {
              StateWidget.of(context).state.user.coordinates = GeoPoint(position.latitude, position.longitude);
              markers[myMarker] = marker.copyWith(
                  positionParam: LatLng(position.latitude, position.longitude));
              setState(() {
                _loadingAtualization = false;
              });
            });
                  
          Flushbar(
          title: "Sucesso",
          message: 'Localização atualizada',
          duration: Duration(seconds: 5),
        )..show(context);
        });
}

  @override
  Widget build(BuildContext context) {
     Size screenSize = MediaQuery.of(context).size;
     

    // print(Geohash.encode(-22.479157, -44.050294));
    return Scaffold(
      body:Stack(children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[Factory<OneSequenceGestureRecognizer>(()=>ScaleGestureRecognizer())].toSet(),
          markers: Set<Marker>.of(markers.values),
          onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              mapController.setMapStyle(_mapStyle);
          },
          initialCameraPosition:
              CameraPosition(
                target: LatLng(widget.user.coordinates.latitude,widget.user.coordinates.longitude),
                zoom: 15.0
                ),
        ),
       _loadingAtualization 
       ?Container()
       :Positioned(
          left: screenSize.width/3.5,
          child: RaisedButton(
            color: Colors.blue[900],
            onPressed: updatePosition,
            child: Text('Atualizar localização',style:TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    )
      
    );
  }
}

class OpenChest extends StatefulWidget {
  final Function removeMarkerId;
  final MarkerId markerId;
  final Function removeTreasure;
  final Map treasure;
  OpenChest({this.removeMarkerId,this.markerId,this.removeTreasure,this.treasure});

  @override
  _OpenChestState createState() => _OpenChestState(removeMarkerId:removeMarkerId,markerId:markerId,removeTreasure:removeTreasure,treasure:treasure);
}

class _OpenChestState extends State<OpenChest> {
  Function removeMarkerId;
  MarkerId markerId;
  Function removeTreasure;
  Map treasure;
_OpenChestState({this.removeMarkerId,this.markerId,this.removeTreasure,this.treasure});

StateModel appState;
bool _isLoading = false;

List drop;



Future getTreasureDrop() async{
  appState = StateWidget.of(context).state;
  UserPersonagem user = appState?.user ?? null;
  print(user.id);
  print(user.user_level);

    var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'treasureDrop'); // replace 'functionName' with the name of your function
            var response = await callable.call(<String, dynamic>{
                "id":user.id,
                "levelmultiply":user.user_level,
              }).catchError((onError) {
            });
              drop = response.data;
              print(drop);
  }

  buildDrop(drop){
  
  // var drop = [{'inteligence': 4, 'name': 'Kodai wand', 'id': 781, 'slot': 'weapon', 'strenght': 6, 'agility': 5, 'idunique': 1575727398, 'rarity': 3}];

  TextStyle style;
  
  

  switch (drop[0]['rarity']) {
    case 1:
      style = TextStyle(color: Colors.green[900]);
      break;
    case 2:
      style = TextStyle(color: Colors.yellow[600]);
      break;
    case 3:
       style = TextStyle(color: Colors.orange[900]);
      break;
  }

  List<Widget> widget = [
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
      Image.asset('assets/images/drop.jpg',fit: BoxFit.cover, height: 50,),
      Text('Drop:'),
      ]),
    Text('${drop[0]['name']}',style: style),
    ];

 if(drop[0]['strenght'] != 0){
    widget.add(Text('Força: +${drop[0]['strenght']}',style: style,));
  }
  if(drop[0]['agility'] != 0){
    widget.add(Text('Agilidade: +${drop[0]['agility']}',style: style));
  }
  if(drop[0]['inteligence'] != 0){
      widget.add(Text('Inteligencia: +${drop[0]['inteligence']}',style: style));
  }

   return Container(
       height: 150,
       child: Column(children: widget )
       );
}


buildLoading(){
  return Container(
      height: 150,
      child: Column(children: <Widget>[
              Image.asset('assets/images/drop.jpg',fit: BoxFit.cover, height: 100,),
              CircularProgressIndicator()
            ],),
    );
}

buildOpen(){
  TextStyle style = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w300,//try changing weight to w500 if not thin
      color: Colors.black,
      fontSize: 18.0,
    );
  return Container(
      height: 150,
      child: Column(children: <Widget>[
        Image.asset('assets/images/drop.jpg',fit: BoxFit.cover, height: 100,),
        FlatButton(
                  child: new Text("Abrir",style: style,),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    removeMarkerId(markerId);
                    removeTreasure(treasure);
                    await getTreasureDrop();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                )
      ],),
    );
}

 @override
  Widget build(BuildContext context) {

    return _isLoading == true && drop == null
        ? buildLoading()
        : _isLoading == false && drop != null 
          ?buildDrop(drop)
          :buildOpen();
    }
}

