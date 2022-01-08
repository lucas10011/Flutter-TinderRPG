import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';

class Monsters {
  

static Future getMonsters(level,coordinates) async {
      Map monsters = {'treasure':[],'monstersGenerated':[]};
      var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'generateMonsters'); // replace 'functionName' with the name of your function
                var response = await callable.call(<String, dynamic>{
                    "latitude": coordinates.latitude,
                    "longitude":coordinates.longitude,
                    "level":level,
                  }).catchError((onError) {
                });

            var result = response.data;

            for (int i = 0; i < result['monstersGenerated'].length; i++){
              result['monstersGenerated'][i]['id'] = i;
              monsters['monstersGenerated'].add(result['monstersGenerated'][i]);
            }
            for (int i = 0; i < result['treasure'].length; i++){
                monsters['treasure'].add(result['treasure'][i]);
            }


                  return monsters;
                      
    }


static Future getListMonsters(distance,userId,monsters) async{



  var positions = await getPositionGeoPoint(distance,userId,monsters);
  print('////////////getListMonsters:positions///////////////');
  var listfiltered = await filterPotentialChallenges(positions,userId,monsters);
  print('////////////getListMonsters:listfiltered///////////////');
  var shuffle = await shuffleData(listfiltered,monsters);
  print('////////////getListMonsters:shuffle///////////////');


  print(shuffle);
  return shuffle;

}


static getPositionGeoPoint(distance,userId,monsters) async {

   
  //  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
 

    var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'addUser'); // replace 'functionName' with the name of your function
                var response = await callable.call(<String, dynamic>{
                    "latitude":-22.4740283,
                    "longitude":-44.0490496,
                    "radius":distance
                  }).catchError((onError) {
                  });

                  List datageo = response.data;

                  return datageo;
                
        
  }


   static filterPotentialChallenges(List response,userId,monsters)async{
    List filtereddata = [];
      response.forEach((item){
           filtereddata.add(item);
       });

      filtereddata.removeWhere((item) => item['id'] == userId);
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


  static shuffleData(datafiltered,monsters) async {
    
  Map<String,List> data = {'monstersAndPlayers':[],'treasure':[]};
       monsters['monstersGenerated'].forEach((value){
        value['monster'] = true;
        data['monstersAndPlayers'].add(value);
      });
      monsters['treasure'].forEach((value){
        value['treasure'] = true;
        data['treasure'].add(value);
      });

      datafiltered.forEach((value){
          value['monster'] = false;
          data['monstersAndPlayers'].add(value);
      });
      data['monstersAndPlayers'].shuffle();
      return data;

   }

}