import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:votaciones_equipos/models/team.dart';
import 'package:votaciones_equipos/services/socket_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Team> teams = []; 

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);    
    socketService.socket.on('active-teams', _handleActiveTeams);
    super.initState();
  }

  _handleActiveTeams( dynamic payload ) { 
    teams = (payload as List)
      .map( (team) => Team.fromMap(team))
      .toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-teams');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverStatus = Provider.of<SocketService>(context).serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votaciones Equipos de Fútbol'),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only( right: 10),
            child: serverStatus == ServerStatus.online 
              ? const Icon(Icons.check_circle, color: Colors.blue,)
              : const Icon(Icons.offline_bolt_outlined, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [
          
          _showGraph(),
          
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teams.length,
              itemBuilder: ( context, index) => _bandaTile(teams[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: agregarNuevoEquipo,
        elevation: 0,
        child: const Icon( Icons.add, color: Colors.black87, size: 30, ),
      ),
    );
  }

  Widget _bandaTile(Team team) {
    final socket = Provider.of<SocketService>(context, listen: false).socket;

    return Dismissible(
      key: Key(team.id!),
      direction: DismissDirection.endToStart,
      onDismissed: ( _ ) => socket.emit('delete-team', { 'id': team.id }),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only( right: 10 ),
        child: const Icon(Icons.delete, color: Colors.white,),
      ),
      child: ListTile(
        leading: CircleAvatar(
          maxRadius: 20,
          backgroundColor: Colors.blue[100],
          child: Text(team.nombre!.substring(0,2), style: const TextStyle(color: Colors.black87),),
        ),
        title: Text(team.nombre!),
        trailing: Text('${team.votos}', style: const TextStyle( fontSize: 18)),
        onTap: () => socket.emit('vote-team', { 'id': team.id } ),
      ),
    );
  }

  agregarNuevoEquipo(){
    final controller = TextEditingController();

    if ( Platform.isAndroid) {
      showDialog(
        context: context, 
        builder: ( _ ) => AlertDialog(

          title: const Text('Nuevo equipo'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Nombre'
            ),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () => agregarEquipo(controller.text),
              child: const Text('Agregar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red),),
            ),
          ],
          elevation: 0,
        )
      );
    }

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
          content: CupertinoTextField(
            controller: controller,
            placeholder: 'Nombre',
          ),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: const Text('Nuevo equipo')),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true, // siempre en true
              child: const Text('Agregar'),
              onPressed: () => agregarEquipo(controller.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // destruir el dialog y no hacer nada
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context)
            ),
          ],
        )
      );
    }
  }

  agregarEquipo( String nombre ) {
    if ( nombre.length > 1) {
      final socket = Provider.of<SocketService>(context, listen: false).socket;
      socket.emit('add-team', {
        'nombre': nombre,
      });
    }

    Navigator.pop(context);
  }


  Widget _showGraph(){
    final List<Color> colorList = [
      const Color(0xffee6352),
      const Color(0xff59cd90),
      const Color(0xff3fa7d6),
      const Color(0xfffac05e),
      const Color(0xfff79d84),
    ];

    Map<String, double> dataMap = {};

    teams.forEach((team) {
      dataMap.putIfAbsent( team.nombre!, () => team.votos!.toDouble() );
    });

    return dataMap.isNotEmpty 
      ? Container(
          margin: const EdgeInsets.symmetric( horizontal: 20 ),
          width: double.infinity,
          height: 300,
          child: PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(seconds: 2),
            chartRadius: MediaQuery.of(context).size.width / 1.0,
            colorList: colorList,
            chartType: ChartType.disc,
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: true,
              decimalPlaces: 0,
              chartValueStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              )
            ),
          )
        )
      : Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
        child: const CircularProgressIndicator.adaptive());
  }

}