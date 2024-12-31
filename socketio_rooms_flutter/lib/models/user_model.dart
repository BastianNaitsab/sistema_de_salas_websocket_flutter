import 'dart:convert';

class UserModel {
  final String idUser;

  UserModel({
    required this.idUser,
  });

  Map<String, dynamic> toMap() {
    return {
      "idUser": idUser,
    };
  }

  // Convertir el objeto Message a JSON (cadena de texto) Para enviar en websocket
  String toJson() {
    return jsonEncode(toMap());
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      idUser: map["idUser"] ?? "default",
    );
  }

  // Crear un Message a partir de JSON (cadena de texto) Para recibir en websocket
  factory UserModel.fromJson(String source) {
    return UserModel.fromMap(jsonDecode(source));
  }
}
