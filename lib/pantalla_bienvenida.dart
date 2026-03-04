import 'package:flutter/material.dart';
// Importa tu pantalla de login para que el botón funcione
import 'package:app_transtunja/screens/usuario/login_screen.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco limpio
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Imagen Principal (El bus y los pines)
              // Aquí está el truco: hacemos la imagen mucho más grande y sin fondo.
              Expanded(
                flex: 3, // Ocupa más espacio en la pantalla
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // Margen interno
                  child: Image.asset(
                    'assets/images/transtunja_logo.png', // Usamos tu imagen guardada
                    fit: BoxFit.contain, // Se ajusta sin deformarse
                  ),
                ),
              ),

              const SizedBox(height: 20), // Espacio entre imagen y botón
              // 2. El Botón Rojo de "Entrar" (¡Ahora funcional!)
              Expanded(
                flex: 1, // Espacio para el botón
                child: Center(
                  child: SizedBox(
                    width: 250, // Ancho del botón según el diseño
                    height: 55, // Alto del botón
                    child: ElevatedButton(
                      onPressed: () {
                        // --- AQUÍ ESTÁ LA MAGIA DEL BOTÓN ---
                        // Al presionarlo, navega a la LoginScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFF1E1E,
                        ), // Rojo vibrante exacto
                        elevation: 6, // Sombra sutil pero visible
                        shadowColor: Colors.black45, // Color de la sombra
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            27.5,
                          ), // Bordes muy redondeados
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Texto grande y claro
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Pequeño espacio extra abajo para equilibrar
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
