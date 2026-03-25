import 'package:flutter/material.dart';
// Asegúrate de que esta ruta sea la correcta hacia tu archivo del home
import 'package:app_transtunja/screens/conductor/home_conductor.dart'; 

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    // Pon aquí el nombre que quieras que aparezca en el saludo
    home: HomeConductor(nombreConductor: "Carlos"), 
  ));
}