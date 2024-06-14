import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Esto es para hacer la barra de gestos transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Registros de Vehículos',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, 
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}

