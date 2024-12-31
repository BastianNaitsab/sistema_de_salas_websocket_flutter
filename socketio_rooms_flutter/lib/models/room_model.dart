import 'dart:convert';

import 'user_model.dart';

class RoomModel {
  final int idRoom;
  final String name;
  final DateTime dateCreation;
  final DateTime dateStarted;
  final List<UserModel> listUsers;
  final int limitUsers;
  final int limitTime;
  final String state;

  RoomModel({
    required this.idRoom,
    required this.name,
    required this.dateCreation,
    required this.dateStarted,
    required this.listUsers,
    required this.limitUsers,
    required this.limitTime,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      "idRoom": idRoom,
      "name": name,
      "dateCreation": dateCreation.toIso8601String(),
      "dateStarted": dateStarted.toIso8601String(),
      "listUsers": listUsers
          .map((user) => user.toMap())
          .toList(), // Convierte cada UserModel a mapa
      "limitUsers": limitUsers,
      "limitTime": limitTime,
      "state": state,
    };
  }

  // Convertir el objeto Message a JSON (cadena de texto) Para enviar en websocket

  String toJson() {
    return jsonEncode(toMap());
  }

  // Crear un RoomModel a partir de un mapa
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      idRoom: map["idRoom"] ?? 0,
      name: map["name"] ?? "default",
      dateCreation: map["dateCreation"] != null
          ? DateTime.parse(map["dateCreation"])
          : DateTime.now().toUtc(),
      dateStarted: map["dateStarted"] != null
          ? DateTime.parse(map["dateStarted"])
          : DateTime.now().toUtc(),
      listUsers: List<UserModel>.from(
          map["listUsers"]?.map((userMap) => UserModel.fromMap(userMap)) ??
              []), // Convierte cada mapa en UserModel
      limitUsers: map["limitUsers"] ?? 2,
      limitTime: map["limitTime"] ?? 1,
      state: map["state"] ?? "loading",
    );
  }

  // Crear un Message a partir de JSON (cadena de texto) Para recibir en websocket
  factory RoomModel.fromJson(String source) {
    return RoomModel.fromMap(jsonDecode(source));
  }
}
