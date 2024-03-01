import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:votaciones_equipos/screens/home_screen.dart';
import 'package:votaciones_equipos/screens/status_server_screen.dart';
import 'package:votaciones_equipos/services/socket_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load( fileName: ".env" );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ( _ ) => SocketService()),
      ],
      child: const MyApp()
    )
  );
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Votaciones App',
      initialRoute: 'home',
      routes: {
        'home'   : (_) => const HomeScreen(),
        'status' : (_) => const StatusServerScreen()
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xff335c67), 
      ),
    );
  }
}