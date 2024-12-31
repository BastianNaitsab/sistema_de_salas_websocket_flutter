import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Aca todo se recibe y se manda en formato String, en la UI es donde se hacen las transformaciones

// O tambien podria aqui transformar los datos, ya yo vere

class WebSocketService {
  // Socket.io client
  IO.Socket? _socket;

  // Streams para los diferentes eventos

  final StreamController<String> _lastRoomStreamController =
      StreamController<String>();
  final StreamController<String> _roomStreamController =
      StreamController<String>();

  // Obtener el Stream de mensajes para UI

  Stream<String> get lastRoomStream => _lastRoomStreamController.stream;
  Stream<String> get roomStream => _roomStreamController.stream;

  // Conectar al WebSocket y configurar los eventos de escucha
  void connect(String url) {
    _socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Eventos de escucha

    _socket?.on('lastRoom', (data) {
      debugPrint('Mensaje lastRoom recibido: $data');
      _lastRoomStreamController.sink.add(data);
    });

    _socket?.on('room', (data) {
      debugPrint('Mensaje room recibido: $data');
      _roomStreamController.sink.add(data);
    });

    _socket?.connect();
  }

  // Eventos de mandar mensajes

  void joinMessage(String user) {
    debugPrint("Mensaje join enviado: $user");
    _socket?.emit('join', user);
  }

  // Cerrar conexión y Streams

  void disconnect() {
    _socket?.disconnect();
    _lastRoomStreamController.close();
  }
}
