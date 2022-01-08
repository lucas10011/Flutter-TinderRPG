import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);


UserPersonagem userFromJson(String str) {
  final jsonData = json.decode(str);
  return UserPersonagem.fromJson(jsonData);
}

String userToJson(UserPersonagem data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserPersonagem {
  String id;
  String token;
  String user_nome;
  String user_foto;
  String user_date;
  String user_descricao;
  String user_titulo;
  String user_raca;
  String user_profissao;
  String user_idade;
  String user_pontoforte;
  String user_pontofraco;
  int user_level;
  int user_distance;
  GeoPoint coordinates;
  String createdAt;


  
  

  UserPersonagem({
    this.id,
    this.token,
    this.user_nome,
    this.user_foto,
    this.user_date,
    this.user_descricao,
    this.user_titulo,
    this.user_raca,
    this.user_profissao,
    this.user_idade,
    this.user_pontoforte,
    this.user_pontofraco,
    this.user_level,
    this.user_distance,
    this.coordinates,
    this.createdAt,
  });

  
  factory UserPersonagem.fromJson(Map<dynamic, dynamic> json) => new UserPersonagem(
        id: json["id"],
        token: json["token"],
        user_nome: json["user_nome"],
        user_foto: json["user_foto"],
        user_date: json["user_date"],
        user_descricao: json["user_descricao"],
        user_titulo: json["user_titulo"],
        user_raca: json["user_raca"],
        user_profissao: json["user_profissao"],
        user_idade: json["user_idade"],
        user_pontoforte: json["user_pontoforte"],
        user_pontofraco: json["user_pontofraco"],
        user_level: json["user_level"],
        user_distance: json["user_distance"],
        coordinates: GeoPoint(json["coordinates"]["latitude"],json["coordinates"]["longitude"]),
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "token": token,
        "user_nome": user_nome,
        "user_foto": user_foto,
        "user_date": user_date,
        "user_descricao": user_descricao,
        "user_titulo": user_titulo,
        "user_raca": user_raca,
        "user_profissao": user_profissao,
        "user_idade": user_idade,
        "user_pontoforte": user_pontoforte,
        "user_pontofraco": user_pontofraco,
        "user_level": user_level,
        "user_distance": user_distance,
        "coordinates": {'latitude':coordinates.latitude,'longitude':coordinates.longitude},
        "createdAt": createdAt,
      };

  factory UserPersonagem.fromDocument(doc) {
    var latitude = doc['d']['coordinates'].latitude;
    var longitude = doc['d']['coordinates'].longitude;
    doc['d']['coordinates'] = {'latitude':latitude,'longitude':longitude};
    return UserPersonagem.fromJson(doc['d']);
  }
  
}