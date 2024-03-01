import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus { 
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier{

  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  Function get emit => _socket.emit;

  SocketService(){
    _initConfig();
  }

  void _initConfig() {
    // _socket = IO.io('http://xxx.xx.xx.xx:3000/', { // cambiar ip de tu servidor
    _socket = IO.io(dotenv.env['SOCKET_IP'], { // cambiar ip de tu servidor
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.onConnect( (_) {
      // print('connect');
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });
      
    _socket.onDisconnect( (_) {
      // print('disconnect');
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    socket.on('nuevo-mensaje', (payload) => print(payload));
  }

}