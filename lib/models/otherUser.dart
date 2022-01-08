import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);


OtherUser otherUserFromJson(String str) {
  final jsonData = json.decode(str);
  return OtherUser.otherfromJson(jsonData);
}

String otherUserToJson(OtherUser data) {
  final dyn = data.othertoJson();
  return json.encode(dyn);
}

class OtherUser {
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
  int distanceBetween;
  GeoPoint coordinates;
  String createdAt;

  OtherUser({
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
    this.distanceBetween,
    this.coordinates,
    this.createdAt,
  });

  
  factory OtherUser.otherfromJson(Map<dynamic, dynamic> json) => new OtherUser(
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
        distanceBetween:json["distanceBetween"],
        coordinates: null,
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> othertoJson() => {
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
        "distanceBetween":distanceBetween,
        "coordinates": null,
        "createdAt": createdAt,
      };

  factory OtherUser.otherfromDocument(doc) {
    return OtherUser.otherfromJson(doc);
  }
  
}