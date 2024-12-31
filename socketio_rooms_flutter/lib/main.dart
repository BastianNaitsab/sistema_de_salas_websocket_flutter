import 'package:flutter/material.dart';
import 'package:socketio_rooms_flutter/models/room_model.dart';
import 'package:socketio_rooms_flutter/models/user_model.dart';

import 'models/message.dart';
import 'services/websocket_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Socket.IO Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  // Instancia del servicio
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    const String wsUrl = 'http://localhost:3000';
    // Conectar al WebSocket
    _webSocketService.connect(wsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration:
                    const InputDecoration(labelText: 'Enter your Username'),
              ),
            ),
            const SizedBox(height: 24),

            // Usar el StreamBuilder con los Streams del WebSocketService

            StreamBuilder<String>(
              stream: _webSocketService.lastRoomStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  try {
                    RoomModel room = RoomModel.fromJson(snapshot.data!);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 200,
                          width: 380,
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${room.name}"),
                                Text("${room.dateCreation}"),
                                Text(
                                    "${room.listUsers.length} of ${room.limitUsers}"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } catch (error) {
                    debugPrint(
                        "Error en Stream Builder lastRoomStream: $error");
                    return const Text("Error Stream Builder lastRoomStream");
                  }
                } else {
                  return const Text('Esperando mensaje...');
                }
              },
            ),

            const SizedBox(height: 24),

            StreamBuilder<String>(
              stream: _webSocketService.roomStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text('Esperando a que te unas a una sala...'));
                } else if (snapshot.hasData) {
                  try {
                    RoomModel room = RoomModel.fromJson(snapshot.data!);
                    // Extraer los idUser de la lista de usuarios
                    List<String> userIds =
                        room.listUsers.map((user) => user.idUser).toList();

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${room.name}"),
                          Text("${room.state}"),
                          Text("${room.dateStarted}"),
                          const SizedBox(height: 20),
                          const Text("Usuarios en la sala:"),
                          for (var id in userIds)
                            Text(id), // Mostrar cada idUser
                        ],
                      ),
                    );
                  } catch (error) {
                    debugPrint("Error en Stream Builder roomStream: $error");
                    return const Text("Error Stream Builder roomStream");
                  }
                } else {
                  return const Text('Esperando mensaje...');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _joinMessage,
            tooltip: 'Join Group',
            child: const Icon(Icons.join_full),
          ),
        ],
      ),
    );
  }

  void _joinMessage() {
    if (_controller.text.isNotEmpty) {
      UserModel user = UserModel(idUser: _controller.text);
      String encodedUser = user.toJson();
      _webSocketService.joinMessage(encodedUser);
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect(); // Desconectar WebSocket
    _controller.dispose();
    super.dispose();
  }
}
