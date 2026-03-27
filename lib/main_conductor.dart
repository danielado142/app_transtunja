import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'package:app_transtunja/screens/conductor/home_conductor.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // ✅ CORRECCIÓN: Ahora pasamos el mapa 'userData' que el Home espera
      home: const HomeConductor(
        userData: {
          'nombre': "Daniela",
          'correo': "daniela@mail.com", // 👈 Debe ser igual al ID en tu Firestore
        },
      ), 
    );
  }
}