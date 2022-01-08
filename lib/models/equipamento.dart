import 'dart:convert';

// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);


Equipamento equipamentoFromJson(String str) {
  final jsonData = json.decode(str);
  return Equipamento.fromJson(jsonData);
}

String equipamentoToJson(Equipamento data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Equipamento {
  Map weapon;
  Map body;
  Map head;
  Map neck;
  Map feet;
  Map legs;
  Map shield;
  Map cape;
  Map ring;
  Map hands;



  
  

  Equipamento({
    this.weapon,
    this.body,
    this.head,
    this.neck,
    this.feet,
    this.legs,
    this.shield,
    this.cape,
    this.ring,
    this.hands
  });

  
  factory Equipamento.fromJson(Map<dynamic, dynamic> json) => new Equipamento(
        weapon: json["weapon"],
        body: json["body"],
        head: json["head"],
        neck: json["neck"],
        feet: json["feet"],
        legs: json["legs"],
        shield: json["shield"],
        cape: json["cape"],
        ring: json["ring"],
        hands: json["hands"],
      );

  Map<String, dynamic> toJson() => {
        "weapon": weapon,
        "body": body,
        "head": head,
        "neck": neck,
        "feet": feet,
        "legs": legs,
        "shield": shield,
        "cape": cape,
        "ring": ring,
        "hands": hands,
      };

  factory Equipamento.fromDocument(doc) {
    return Equipamento.fromJson(doc);
  }
  
}