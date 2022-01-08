import 'package:flutter/material.dart';
import 'package:my_isekai/models/equipamento.dart';

class Atributo {
   static buildAtributo(item) {
    int bonusStr = 0;
    int bonusAgi = 0;
    int bonusInt = 0;
    if(item['monster'] != true){
    Equipamento equipamento  = Equipamento.fromJson(item['equipamento']);

    if(equipamento.weapon != null){
       bonusStr += equipamento.weapon['strenght'];
       bonusAgi += equipamento.weapon['agility'];
       bonusInt += equipamento.weapon['inteligence'];
    }
    if(equipamento.body != null){
       bonusStr += equipamento.body['strenght'];
       bonusAgi += equipamento.body['agility'];
       bonusInt += equipamento.body['inteligence'];
    }
    if(equipamento.cape != null){
       bonusStr += equipamento.cape['strenght'];
       bonusAgi += equipamento.cape['agility'];
       bonusInt += equipamento.cape['inteligence'];
    }
    if(equipamento.feet != null){
       bonusStr += equipamento.feet['strenght'];
       bonusAgi += equipamento.feet['agility'];
       bonusInt += equipamento.feet['inteligence'];
    }
    if(equipamento.head != null){
       bonusStr += equipamento.head['strenght'];
       bonusAgi += equipamento.head['agility'];
       bonusInt += equipamento.head['inteligence'];
    }
    if(equipamento.legs != null){
       bonusStr += equipamento.legs['strenght'];
       bonusAgi += equipamento.legs['agility'];
       bonusInt += equipamento.legs['inteligence'];
    }
    if(equipamento.neck != null){
       bonusStr += equipamento.neck['strenght'];
       bonusAgi += equipamento.neck['agility'];
       bonusInt += equipamento.neck['inteligence'];
    }

    if(equipamento.ring != null){
       bonusStr += equipamento.ring['strenght'];
       bonusAgi += equipamento.ring['agility'];
       bonusInt += equipamento.ring['inteligence'];
    }
    if(equipamento.shield != null){
       bonusStr += equipamento.shield['strenght'];
       bonusAgi += equipamento.shield['agility'];
       bonusInt += equipamento.shield['inteligence'];
    }
  }   

      TextStyle bioTextStyle = TextStyle(
      fontWeight: FontWeight.w300,//try changing weight to w500 if not thin
      color: Colors.white,
      fontSize: 16.0,
    );
    TextStyle valueTextStyle = TextStyle(
      fontWeight: FontWeight.w300,//try changing weight to w500 if not thin
      color: Colors.white,
      fontSize: 16.0,
    );
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
      buildAtributoItem('Força',item['strenght'],bonusStr,bioTextStyle,valueTextStyle,Colors.red),
      buildAtributoItem('Agilidade',item['agility'],bonusAgi,bioTextStyle,valueTextStyle,Colors.green),
      buildAtributoItem('Inteligencia',item['inteligence'],bonusInt,bioTextStyle,valueTextStyle,Colors.blueAccent),
    ],);

  }


 static buildAtributoItem(atribute,value,bonus,bioTextStyle,valueTextStyle,color){

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          
        Text('$atribute',style: bioTextStyle,),
       
        OutlineButton(
            borderSide: BorderSide(color: color),
            shape: CircleBorder(),
            child:Text('${(value+bonus).toInt()}',style: valueTextStyle,),
            onPressed: () {   
            },
          )
      ],);
  }
}