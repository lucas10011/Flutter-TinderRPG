import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:my_isekai/models/equipamento.dart';
import 'package:my_isekai/models/todo.dart';

class Calculo {

 static getEstacao(UserPersonagem user) async{
      DocumentSnapshot buildestacao;

     String elementEstacao = DateFormat('dd:MM').format(DateTime.now()).toString();
     var dmEstacao = elementEstacao.split(':');
     
    if((int.parse(dmEstacao[1]) == 3 && int.parse(dmEstacao[0]) >= 20) || (int.parse(dmEstacao[1]) == 6 && int.parse(dmEstacao[0]) <= 20 )){
        print('Primavera');
         buildestacao = await Firestore.instance.collection('estacoes').document('1').get();
    }else if((int.parse(dmEstacao[1]) == 6 && int.parse(dmEstacao[0]) >= 21) || (int.parse(dmEstacao[1]) == 9 && int.parse(dmEstacao[0]) <= 22 )){
      print('Verao');
       buildestacao = await Firestore.instance.collection('estacoes').document('2').get();
    }else if((int.parse(dmEstacao[1]) == 9 && int.parse(dmEstacao[0]) >= 23) || (int.parse(dmEstacao[1]) == 12 && int.parse(dmEstacao[0]) <= 22 )){
        print('Outono');
        buildestacao = await Firestore.instance.collection('estacoes').document('3').get();
    }else{
       buildestacao = await Firestore.instance.collection('estacoes').document('0').get();
        print('Inverno');
    }

    return buildestacao;

  }

    static getSigno(UserPersonagem user) async{
      DocumentSnapshot buildsignoAttr;

      String renascimento =  DateFormat('dd:MM').format(DateTime.fromMillisecondsSinceEpoch(int.parse(user.user_date))).toString();
      var diaMES = renascimento.split(':');


      print(diaMES);
        if((int.parse(diaMES[1]) == 3 && int.parse(diaMES[0]) >= 21) || (int.parse(diaMES[1]) == 4 && int.parse(diaMES[0]) <= 19 )) {
            print('Aries');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('3').get(); 
          
        }else if((int.parse(diaMES[1]) == 4 && int.parse(diaMES[0]) >= 20) || (int.parse(diaMES[1]) == 5 && int.parse(diaMES[0]) <= 20 )){
            print('Touro');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('4').get(); 
        }
        else if((int.parse(diaMES[1]) == 5 && int.parse(diaMES[0]) >= 22) || (int.parse(diaMES[1]) == 6 && int.parse(diaMES[0]) <= 21 )){
            print('Gemeos');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('5').get(); 
        } 
        else if((int.parse(diaMES[1]) == 6 && int.parse(diaMES[0]) >= 23) || (int.parse(diaMES[1]) == 7 && int.parse(diaMES[0]) <= 22 )){
            print('Cancer');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('6').get();
        }
        else if((int.parse(diaMES[1]) == 7 && int.parse(diaMES[0]) >= 23) || (int.parse(diaMES[1]) == 8 && int.parse(diaMES[0]) <= 22 )){
            print('Leao');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('7').get();
        }
        else if((int.parse(diaMES[1]) == 8 && int.parse(diaMES[0]) >= 23) || (int.parse(diaMES[1]) == 9 && int.parse(diaMES[0]) <= 22 )){
            print('Virgem');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('8').get();
        }
        else if((int.parse(diaMES[1]) == 9 && int.parse(diaMES[0]) >= 23) || (int.parse(diaMES[1]) == 10 && int.parse(diaMES[0]) <= 22 )){
            print('Libra');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('9').get();
        }
        else if((int.parse(diaMES[1]) == 10 && int.parse(diaMES[0]) >= 23) || (int.parse(diaMES[1]) == 11 && int.parse(diaMES[0]) <= 21 )){
            print('Escorpiao');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('10').get();
        }
        else if((int.parse(diaMES[1]) == 11 && int.parse(diaMES[0]) >= 22) || (int.parse(diaMES[1]) == 12 && int.parse(diaMES[0]) <= 21 )){
            print('Sargitario');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('11').get();
        }
        else if((int.parse(diaMES[1]) == 12 && int.parse(diaMES[0]) >= 22) || (int.parse(diaMES[1]) == 1 && int.parse(diaMES[0]) <= 19 )){
            print('Capricornio');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('12').get();
        }
        else if((int.parse(diaMES[1]) == 1 && int.parse(diaMES[0]) >= 20) || (int.parse(diaMES[1]) == 2 && int.parse(diaMES[0]) <= 18 )){
            print('Aquario');
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('1').get();
        }
        else{
            buildsignoAttr = await Firestore.instance.collection('zodiac').document('2').get();
            print('Peixes');
        }
      return buildsignoAttr;
  }


  static calculoAtributo(int idatributo,UserPersonagem user){
    var now = DateTime.now();
    var firstDayOfYear = DateTime(now.year, 1, 1);

    String renascimento =  DateFormat('dd:MM').format(DateTime.fromMillisecondsSinceEpoch(int.parse(user.user_date))).toString();
    var diaMES = renascimento.split(':');

    var fator =  int.parse(diaMES[0]) + int.parse(diaMES[1]);

    int attrdeterminante;
    int distributed;

  Map<String,dynamic> status = {'strenght':300,'agility':300, 'inteligence':300};
   
  var difference = now.difference(firstDayOfYear);
    print(difference.inDays);
      if(difference.inDays > 182){
          attrdeterminante = difference.inDays;
          distributed = 365 - difference.inDays;
          print("Atributo determinante $attrdeterminante");
          print("Para distribuir $distributed");
          
    }else{
        ///diferença de dias é menor que 180 dias
          attrdeterminante = 365 - difference.inDays;
          distributed = difference.inDays;
          print("Atributo determinante $attrdeterminante");
          print("Para distribuir $distributed");
      }

    switch (idatributo) {
        case 0:
          {
            var soma = (status['strenght'] + attrdeterminante);
            var points = distributed;
            var soma2 = (status['agility'] + points);
            var soma3 = (status['inteligence'] + points);
            status['strenght'] = soma;

            if (fator.isEven){
              status['agility'] = soma2;
            }else{
              status['inteligence'] = soma3;
            }
                      
          }
          break;

        case 1:
          {
            var soma = (status['agility'] + attrdeterminante);
            var points = distributed;
            var soma2 = (status['strenght'] + points);
            var soma3 = (status['inteligence'] + points);
            status['agility'] = soma;

            if (fator.isEven){
              status['strenght'] = soma2;
            }else{
              status['inteligence'] = soma3;
            }

          }
          break;

        case 2:
          {
            var soma = (status['inteligence'] + attrdeterminante);
            var points = distributed;
            var soma2 = (status['strenght'] + points);
            var soma3 = (status['agility'] + points);
            status['inteligence'] = soma;

             if (fator.isEven){
              status['strenght'] = soma2;
            }else{
               status['agility'] = soma3;
            }



          }
          break;

        case 3:
          {
            var soma = (status['strenght'] + 50);
              var soma2 = (status['agility'] + 50);
              var soma3 = (status['inteligence'] + 50);
              status['strenght'] = soma;
              status['agility'] = soma2;
              status['inteligence'] = soma3;

            List atributos = ['strenght','agility','inteligence'];
              var rng = new Random();
              for (int i = 0; i < 215; i++) {
                status[atributos[rng.nextInt(3)]] += 1;
              
              }
            
          }
          break;

      }
    return status;
  }

  static buildTitulo(atributo){

  if(atributo['agility'] > atributo['strenght'] && atributo['agility'] > atributo['inteligence']){
      if(atributo['strenght'] > atributo['inteligence']){
        //agi > str > int
        return 'Ninja';
      }else{
        //agi > int > str
        return 'Arqueiro';
      }
  }
  else if(atributo['strenght'] > atributo['agility'] && atributo['strenght'] > atributo['inteligence']){
          if(atributo['agility'] > atributo['inteligence']){
              //str > agi > int
              return 'Guerreiro';
           }else{
             //str > int > int
             return 'Templário';
           }
  }
   else if(atributo['inteligence'] > atributo['agility'] && atributo['inteligence'] > atributo['strenght']){
          if(atributo['agility'] > atributo['strenght']){
              //int > agi > str
              return 'Mago';
           }else{
             //int > str > str
             return 'Arcano';
           }
  }else{
    return 'Indeterminado';
  }

  }


  static buildStatus(UserPersonagem user) async{
//////////Seleciona a estacao do ano e a primeira afinidade magica
     DocumentSnapshot estacao = await getEstacao(user);
//////////Seleciona o signo baseado na sua data de renascimento, sua afinidade magica e o atributo determinante de cada signo para redistribuicao
     DocumentSnapshot zodiac = await getSigno(user);
     var estacaodata = estacao.data();
     var zodiacdata = zodiac.data();
     Map<String,dynamic> statusprofile = await calculoAtributo(zodiacdata['atributo'],user);

      String titulo = buildTitulo(statusprofile);

      statusprofile['elementprimary'] = estacaodata['element'];
      statusprofile['elementsecondary'] = zodiacdata['element'];
      statusprofile['zodiac'] = zodiacdata['id'];
      statusprofile['xp'] = 0;
      statusprofile['user_titulo'] = titulo;

      return statusprofile;
   

  }



 static calculateZodiacPower(idzodiac){
   var now = DateTime.now();

  var anofuturo = DateTime((now.year + 1 ), idzodiac, 21);
  var atual = DateTime(now.year, idzodiac, 21);

  

  var zodiacatual = (now.difference(atual).inDays).toInt();
  var zodiacfuturo = (now.difference(anofuturo).inDays).toInt();
  
  
  if(zodiacatual.isNegative){
    zodiacatual=  zodiacatual * -1;
  }
  if(zodiacfuturo.isNegative){
    zodiacfuturo =  zodiacfuturo * -1;
  }

  if (zodiacatual < zodiacfuturo){
      return zodiacatual; 
  }else if(zodiacatual > zodiacfuturo){
      return zodiacfuturo; 
  }else{
      return zodiacatual;
  }

}



  static Future calculoBatalha(statusmyuser,statusother,nameotheruser,myuser,otheruser,levelmultiply,rank,dice,battleHash) async {

  print(levelmultiply);
  var now = DateTime.now();
  var monthatual = now.month;
  int victory = 0;
  int lose = 0;

 
   Map<String,dynamic> historyBattle = {'$myuser':{},'$otheruser':{},};
   Map userStatus = statusmyuser;
   Map otherStatus;

   Map equipamentUser={'strenght':0,'agility':0,'inteligence':0};
   
   Map equipamentOtherUser={'strenght':0,'agility':0,'inteligence':0};

 
    Equipamento equipamento  = Equipamento.fromJson(statusmyuser['equipamento']);

    if(equipamento.weapon != null){
       equipamentUser['strenght'] += equipamento.weapon['strenght'];
       equipamentUser['agility'] += equipamento.weapon['agility'];
       equipamentUser['inteligence'] += equipamento.weapon['inteligence'];
    }
    if(equipamento.body != null){
       equipamentUser['strenght'] += equipamento.body['strenght'];
       equipamentUser['agility'] += equipamento.body['agility'];
       equipamentUser['inteligence'] += equipamento.body['inteligence'];
    }
    if(equipamento.cape != null){
       equipamentUser['strenght'] += equipamento.cape['strenght'];
       equipamentUser['agility'] += equipamento.cape['agility'];
       equipamentUser['inteligence'] += equipamento.cape['inteligence'];
    }
    if(equipamento.feet != null){
       equipamentUser['strenght'] += equipamento.feet['strenght'];
       equipamentUser['agility'] += equipamento.feet['agility'];
       equipamentUser['inteligence'] += equipamento.feet['inteligence'];
    }
    if(equipamento.head != null){
       equipamentUser['strenght'] += equipamento.head['strenght'];
       equipamentUser['agility'] += equipamento.head['agility'];
       equipamentUser['inteligence'] += equipamento.head['inteligence'];
    }
    if(equipamento.legs != null){
       equipamentUser['strenght'] += equipamento.legs['strenght'];
       equipamentUser['agility'] += equipamento.legs['agility'];
       equipamentUser['inteligence'] += equipamento.legs['inteligence'];
    }
    if(equipamento.neck != null){
       equipamentUser['strenght'] += equipamento.neck['strenght'];
       equipamentUser['agility'] += equipamento.neck['agility'];
       equipamentUser['inteligence'] += equipamento.neck['inteligence'];
    }

    if(equipamento.ring != null){
       equipamentUser['strenght'] += equipamento.ring['strenght'];
       equipamentUser['agility'] += equipamento.ring['agility'];
       equipamentUser['inteligence'] += equipamento.ring['inteligence'];
    }
    if(equipamento.shield != null){
       equipamentUser['strenght'] += equipamento.shield['strenght'];
       equipamentUser['agility'] += equipamento.shield['agility'];
       equipamentUser['inteligence'] += equipamento.shield['inteligence'];
    }






   if(battleHash != null){
    DocumentSnapshot otheruserStatus = await Firestore.instance.collection('userPositions').document('$otheruser').collection('status').document('$otheruser').get();
    otherStatus = otheruserStatus.data();

     Equipamento equipamentoOther  = Equipamento.fromJson(otherStatus['equipamento']);

    if(equipamentoOther.weapon != null){
       equipamentOtherUser['strenght'] += equipamentoOther.weapon['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.weapon['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.weapon['inteligence'];
    }
    if(equipamentoOther.body != null){
       equipamentOtherUser['strenght'] += equipamentoOther.body['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.body['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.body['inteligence'];
    }
    if(equipamentoOther.cape != null){
       equipamentOtherUser['strenght'] += equipamentoOther.cape['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.cape['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.cape['inteligence'];
    }
    if(equipamentoOther.feet != null){
       equipamentOtherUser['strenght'] += equipamentoOther.feet['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.feet['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.feet['inteligence'];
    }
    if(equipamentoOther.head != null){
       equipamentOtherUser['strenght'] += equipamentoOther.head['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.head['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.head['inteligence'];
    }
    if(equipamentoOther.legs != null){
       equipamentOtherUser['strenght'] += equipamentoOther.legs['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.legs['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.legs['inteligence'];
    }
    if(equipamentoOther.neck != null){
       equipamentOtherUser['strenght'] += equipamentoOther.neck['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.neck['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.neck['inteligence'];
    }

    if(equipamentoOther.ring != null){
       equipamentOtherUser['strenght'] += equipamentoOther.ring['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.ring['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.ring['inteligence'];
    }
    if(equipamentoOther.shield != null){
       equipamentOtherUser['strenght'] += equipamentoOther.shield['strenght'];
       equipamentOtherUser['agility'] += equipamentoOther.shield['agility'];
       equipamentOtherUser['inteligence'] += equipamentoOther.shield['inteligence'];
    } 
   }else{
     otherStatus = statusother;
     equipamentOtherUser['strenght'] = 0;
     equipamentOtherUser['agility'] = 0;
     equipamentOtherUser['inteligence'] = 0;
   }


int zodiacproximityuser = calculateZodiacPower(statusmyuser['zodiac']);
int zodiacproximityotheruser = calculateZodiacPower(otherStatus['zodiac']);

 
  print('Minha proximidade $zodiacproximityuser');
  print('Proximidade do oponente $zodiacproximityotheruser');    
  
 
////////////Combate de atributo////////////////////
combatAtributeWin(atribute,userAtribute){
      historyBattle['$myuser']['$atribute'] = userAtribute;
      historyBattle['$otheruser']['$atribute'] = (otherStatus['$atribute'] + equipamentOtherUser['$atribute']);
      historyBattle['$myuser']['result$atribute'] = true;
      historyBattle['$otheruser']['result$atribute'] = false;
      print('Win...My user atribute :$userAtribute > other user atribute:${(otherStatus['$atribute'] + equipamentOtherUser['$atribute'])}');
      victory +=1;
    }

combatAtributeLose(atribute,userAtribute){
        historyBattle['$myuser']['$atribute'] = userAtribute;
        historyBattle['$otheruser']['$atribute'] = (otherStatus['$atribute'] + equipamentOtherUser['$atribute']);
        historyBattle['$myuser']['result$atribute'] = false;
        historyBattle['$otheruser']['result$atribute'] = true;
        print('Lose....My user atribute :$userAtribute < other user atribute:${(otherStatus['$atribute'] + equipamentOtherUser['$atribute'])}');
        lose +=1;
    }


battleDirection(atribute,diceResult){
      var userAtribute = (userStatus['$atribute'] + equipamentUser['$atribute']);
      var otheruserAtribute = (otherStatus['$atribute'] + equipamentOtherUser['$atribute']);

      if(diceResult != false){
        userAtribute = ((userAtribute * diceResult) / 10).toInt();
      }
       

      if(userAtribute > otheruserAtribute){
        combatAtributeWin('$atribute',userAtribute);
      }else if(userAtribute == otheruserAtribute){
          if(zodiacproximityuser < zodiacproximityotheruser){
            combatAtributeWin('$atribute',userAtribute);
            
          }else if(zodiacproximityuser > zodiacproximityotheruser){
            combatAtributeLose('$atribute',userAtribute);
          }else{
            combatAtributeWin('$atribute',userAtribute);
          }
    }else{
        combatAtributeLose('$atribute',userAtribute);
    }
  }






combatWin(userElement,otherUserElement,element){
  print('Win:$userElement,Lose:$otherUserElement,element:$element');

  historyBattle['$myuser']['${element}result'] = true;
  historyBattle['$otheruser']['${element}result'] = false;
  historyBattle['$myuser']['$element'] = userElement;
  historyBattle['$otheruser']['$element'] = otherUserElement;
  victory +=1;
}
combatLose(userElement,otherUserElement,element){
  print('Lose:$userElement,Win:$otherUserElement,element:$element');
  historyBattle['$myuser']['${element}result'] = false;
  historyBattle['$otheruser']['${element}result'] = true;
  historyBattle['$myuser']['$element'] = userElement;
  historyBattle['$otheruser']['$element'] = otherUserElement;
  lose +=1;
}

////////////Decisao pela proximidade com zodiaco
battleCaseEqualOrDivergent(userElement,otherUserElement,element,atributedesempate){
    if(zodiacproximityuser < zodiacproximityotheruser){
        combatWin(userElement,otherUserElement,element);
      }else if (zodiacproximityuser > zodiacproximityotheruser){
        combatLose(userElement,otherUserElement,element);
      }else{
          if(userStatus['$atributedesempate'] >= otherStatus['$atributedesempate']){
          combatWin(userElement,otherUserElement,element);
        }else{
          combatLose(userElement,otherUserElement,element);
          }
      }  


}


 elementBattleCase(userElement,otherUserElement,element){
    switch (userElement) {
        case 0:
          {
            if(otherUserElement == 0 ){   
                  battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');    
            }else if(otherUserElement == 1){
                  combatWin(userElement,otherUserElement,element);
            }else if(otherUserElement == 2){
                  combatLose(userElement,otherUserElement,element);
            }else{
                  battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence'); 
                
            }
                      
          }
          break;

        case 1:
          {
             if(otherUserElement == 0 ){
                combatLose(userElement,otherUserElement,element);
            }else if(otherUserElement == 1){
                battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence'); 
            }else if(otherUserElement == 2){
                battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');        
            }else{
                combatWin(userElement,otherUserElement,element);
                
            }

          }
          break;

        case 2:
          {
             if(otherUserElement == 0 ){
                combatWin(userElement,otherUserElement,element);
            }else if(otherUserElement == 1){
               battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');                  
            }else if(otherUserElement == 2){
               battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');  
            }else{
                combatLose(userElement,otherUserElement,element);  
            }

          }
          break;

        case 3:
          {
            if(otherUserElement == 0 ){
              battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');                
            }else if(otherUserElement == 1){
                combatLose(userElement,otherUserElement,element);
            }else if(otherUserElement == 2){
                combatWin(userElement,otherUserElement,element);
            }else{
              battleCaseEqualOrDivergent(userElement,otherUserElement,element,'inteligence');   
            }
            
          }
          break;

      }

 }



battleDirection('agility',dice);
battleDirection('strenght',dice);
battleDirection('inteligence',dice);
elementBattleCase(userStatus['elementprimary'],otherStatus['elementprimary'],'elementprimary');
elementBattleCase(userStatus['elementsecondary'],otherStatus['elementsecondary'],'elementsecondary');       

historyBattle['$myuser']['zodiac'] = zodiacproximityuser;
historyBattle['$otheruser']['zodiac'] = zodiacproximityotheruser;


      double min;
      double max;
    if(rank != null){  
      if(rank == 'S'){
        min = levelmultiply.toDouble() * 60.0;
        max = levelmultiply.toDouble() * 70.0;
      }else if(rank == 'A'){
        min = levelmultiply.toDouble() * 25.0;
        max = levelmultiply.toDouble() * 50.0;
      }else if(rank == 'B'){
        min = levelmultiply.toDouble() * 20.0;
        max = levelmultiply.toDouble() * 40.0;
      }else if(rank == 'C'){
        min = levelmultiply.toDouble() * 15.0;
        max = levelmultiply.toDouble() * 30.0;
      }else{
        min = levelmultiply.toDouble() * 10.0;
        max = levelmultiply.toDouble() * 20.0;
      }
    }else{
        min = levelmultiply.toDouble() * 60.0;
        max = levelmultiply.toDouble() * 90.0;
    }
      Random rnd = new Random();
      var xp = min.toInt() + rnd.nextInt(max.toInt() - min.toInt());

   print('victory:$victory');
  print('lose:$lose');

    if(victory > lose){

      historyBattle['$myuser']['result'] = true;
      historyBattle['$otheruser']['result'] = false;

      if(battleHash != null){
         calculateXp('$otheruser',xp,false,nameotheruser,levelmultiply);
      }
      
      var resultbattle =  await calculateXp('$myuser',xp,true,nameotheruser,levelmultiply);
      historyBattle['resultbattle'] = resultbattle;
      print(historyBattle);
      return historyBattle;
    }else{
   
      historyBattle['$myuser']['result'] = false;
      historyBattle['$otheruser']['result'] = true;

      if(battleHash != null){
        calculateXp('$otheruser',xp,true,nameotheruser,levelmultiply);
      }
     
       var resultbattle = await calculateXp('$myuser',xp,false,nameotheruser,levelmultiply);
       historyBattle['resultbattle'] = resultbattle;
       print(historyBattle);
       return historyBattle;
    }

  }

  static Future calculateXp(id,xp,win,oponente,levelmultiply) async {
    print(levelmultiply);
    var callable =  CloudFunctions.instance.getHttpsCallable(functionName: 'resultBattle'); // replace 'functionName' with the name of your function
                var response = await callable.call(<String, dynamic>{
                    "id": id,
                    "xp": xp,
                    "win":win,
                    "oponente": oponente,
                    "levelmultiply":levelmultiply
                  }).catchError((onError) {
              });  
            var result = response.data;
            return result;
  }


}