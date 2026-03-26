import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 🔥 Importante
import 'firebase_options.dart'; // Archivo generado por FlutterFire
import 'package:app_transtunja/screens/conductor/home_conductor.dart'; 

void main() async {
  // 1. Asegurar que los widgets carguen antes que Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyAppConductor());
}

class MyAppConductor extends StatelessWidget {
  const MyAppConductor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransTunja Conductor',
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // 3. Pasamos los datos que el Home ahora pide obligatoriamente
      home: const HomeConductor(
        nombreConductor: "Daniela", 
        correoConductor: "daniela@mail.com", // 👈 Este debe existir en tu Firestore
      ), 
    );
  }
}