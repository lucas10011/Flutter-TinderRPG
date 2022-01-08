

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class IsekaiMaps{


  
static Future getPositionGeoPoint(distance,userId) async {

   Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'addUser'); // replace 'functionName' with the name of your function
                var response = await callable.call(<String, dynamic>{
                    "latitude": position.latitude,
                    "longitude":position.longitude,
                    "radius":distance,
                    "id":userId
                  }).catchError((onError) {
                  });

                  List datageo = response.data;
                  
                  return datageo;
                
        
  }

static Future filterPotentialChallenges(userId,List response)async{
    List filtereddata = [];
      response.forEach((item){
           filtereddata.add(item);
       });

      try{
        var result = await Firestore.instance
        .collection('userPositions')
        .document(userId)
        .collection('statusBattles')
        .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;

       if(documents != null){
          documents.forEach((challengers){
            var challengerdata = challengers.data();
            filtereddata.removeWhere((item) => item['id'] == challengerdata['idPerson']);
          });
       }
      }catch(e){
        print(e.toString());
      }
     
       return filtereddata;
         
  } 


static Future<ui.Image> getImageFromPath(imagePath) async {
    print(imagePath);
    
    Uint8List imageBytes;

    if(imagePath != ''){
       File imageFile = await DefaultCacheManager().getSingleFile(imagePath);
       imageBytes = imageFile.readAsBytesSync();
    }else{
        imageBytes = await getBytesFromAsset('assets/images/default.jpg',100);
    }
    

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
}


static Future<BitmapDescriptor> getMarkerIcon(imgPath,difficulty, Size size,color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.red;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = color;
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width - tagWidth,
              0.0,
              tagWidth,
              tagWidth
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '$difficulty',
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromPath(imgPath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
}


 static Future getCurrentPosition() async {
   Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   return position;
 }

  


 static Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 64,targetHeight: 64);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}


// Future<Uint8List> saveImage(BuildContext context, String image) {
//   final completer = Completer<Uint8List>();

//   NetworkImage(image).resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo imageInfo, bool _) async {
//     final byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData.buffer.asUint8List();
//     ui.Codec codec = await ui.instantiateImageCodec(pngBytes, targetWidth: 64,targetHeight: 64);
//     ui.FrameInfo fi = await codec.getNextFrame();
    
//     completer.complete((await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List());
//   }));

//   return completer.future;
// }


static int generateIds() {
        var rng = new Random();
        var randomInt;      
          randomInt = rng.nextInt(10000000);
          print(rng.nextInt(10000000));
        return randomInt;
      }


  static distanceBetween(lat1,lon1,lat2,lon2){
    var radlat1 = pi * lat1/180;
		var radlat2 = pi * lat2/180;
		var theta = lon1-lon2;
		var radtheta = pi * theta/180;
		var dist = sin(radlat1) * sin(radlat2) + cos(radlat1) * cos(radlat2) * cos(radtheta);
		if (dist > 1) {
			dist = 1;
		}
		dist = acos(dist);
		dist = dist * 180/pi;
		dist = dist * 60 * 1.1515;
		dist = dist * 1.609344; 
    print(dist);
    var n = num.parse(dist.toStringAsFixed(2));
		return n;   
  }

}