import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_isekai/services/calculo.dart';

class BattleFunction {

  static Future battleMatch(item,appState) async{
  

  String battleId;

  var status = appState.status.data;
  var myid = appState.user.id;
  var otherid = item['id'];

  if (myid.hashCode <= otherid.hashCode) {
    battleId = '$myid-$otherid';
    print(battleId.hashCode);
  } else {
    battleId = '$otherid-$myid';
    print(battleId.hashCode);
  }
  
  var document = await Firestore.instance
        .collection('battles')
        .document('${battleId.hashCode}')
        .get();
    if(document.data != null){
      print('Existe battle');
        if(document['battle'] == true){
          print('Desafio pendente aceito');
          try{
            await Firestore.instance.collection('userPositions').document(myid).collection('statusBattles').document('${battleId.hashCode}').setData({
              'idChallenger':otherid,
              'idChallenged':myid,
              'idPerson':otherid,
              'battle': true,
              'run':false,
              'battleHash':battleId.hashCode,
            });
            await Firestore.instance.collection('userPositions').document(otherid).collection('statusBattles').document('${battleId.hashCode}').setData({
              'idChallenger':otherid,
              'idChallenged':myid,
              'idPerson':myid,
              'battle': true,
              'run': false,
              'battleHash':battleId.hashCode,
            });
            var resultado = await Calculo.calculoBatalha(status,null,item['user_nome'],myid,otherid,item['user_level'],null,false,battleId.hashCode);
            resultado['dice'] = false;
            await Firestore.instance.collection('battles').document('${battleId.hashCode}').collection('result').document('${battleId.hashCode}').setData(resultado);
            print(resultado);
            return resultado;
          }catch(e){
            print(e.toString());
            return false;
          }
        }else{
            print('Desafio pendente recusado');
            await Firestore.instance.collection('userPositions').document(myid).collection('statusBattles').document('${battleId.hashCode}').setData({
            'idChallenger':otherid,
            'idChallenged':myid,
            'idPerson':otherid,
            'battle': false,
            'run':true,
            'battleHash':battleId.hashCode,
          });
          return false;
        }
        
    }else{
      print('Desafiado');
        await Firestore.instance.collection('battles').document('${battleId.hashCode}').setData({
          'idChallenger':myid,
          'idChallenged':otherid,
          'battle': true,
          'run':false,
          'battleHash':battleId.hashCode,
        });

        await Firestore.instance.collection('userPositions').document(myid).collection('statusBattles').document('${battleId.hashCode}').setData({
          'idChallenger':myid,
          'idChallenged':otherid,
          'idPerson':otherid,
          'battle': false,
          'run': false,
          'battleHash':battleId.hashCode,
        });
      return false;
    }
  }


static Future battleRun(item,appState) async{
    print('Fugiu');
    
  String battleId;
  var status = appState.status.data;
  var myid = appState.user.id;
  var otherid = item['id'];

  if (myid.hashCode <= otherid.hashCode) {
    battleId = '$myid-$otherid';
    print(battleId.hashCode);
  } else {
    battleId = '$otherid-$myid';
    print(battleId.hashCode);
  }

      var document = await Firestore.instance.collection('battles').document('${battleId.hashCode}').get();
      if(document.data == null){
        await Firestore.instance.collection('battles').document('${battleId.hashCode}').setData({
            'idChallenger':myid,
            'idChallenged':otherid,
            'battle': false,
            'run': true,
            'battleHash':battleId.hashCode,
          });
      }
    
    await Firestore.instance.collection('userPositions').document(myid).collection('statusBattles').document('${battleId.hashCode}').setData({
            'idChallenger':myid,
            'idChallenged':otherid,
            'idPerson':otherid,
            'battle': false,
            'run': true,
            'battleHash':battleId.hashCode,
          });


  }
}