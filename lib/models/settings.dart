import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
// To parse this JSON data, do
//
//     final settings = settingsFromJson(jsonString);

SettingsPersonagem settingsFromJson(String str) {
  final jsonData = json.decode(str);
  return SettingsPersonagem.fromJson(jsonData);
}

String settingsToJson(SettingsPersonagem data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class SettingsPersonagem {
  String settingsId;

  SettingsPersonagem({
    this.settingsId,
  });

  factory SettingsPersonagem.fromJson(Map<String, dynamic> json) => new SettingsPersonagem(
        settingsId: json["settingsId"],
      );

  Map<String, dynamic> toJson() => {
        "settingsId": settingsId,
      };

  factory SettingsPersonagem.fromDocument(DocumentSnapshot doc) {
    return SettingsPersonagem.fromJson(doc.data());
  }
}