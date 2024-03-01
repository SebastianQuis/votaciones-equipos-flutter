import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:votaciones_equipos/services/socket_service.dart';


class StatusServerScreen extends StatelessWidget {
  const StatusServerScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);   

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado del servidor: ${socketService.serverStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          socketService.socket.emit('emitir-mensaje',{
            'nombre': 'Flutter',
            'mensaje': 'Hola desde Flutter'
          });
        },
      ),
    );
  }
}