import 'package:flutter/material.dart';
import '../../services/admin_service.dart'; // Asegúrate de ajustar esta ruta

class RegistrarConductor extends StatefulWidget {
  const RegistrarConductor({super.key});

  @override
  State<RegistrarConductor> createState() => _RegistrarConductorState();
}

class _RegistrarConductorState extends State<RegistrarConductor> {
  // Controladores para los datos
  final _nombreCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _licenciaCtrl = TextEditingController();
  final _arlCtrl = TextEditingController();
  String _sangreSeleccionada = 'O';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Nuevo Conductor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextField(
              controller: _cedulaCtrl,
              decoration: const InputDecoration(labelText: 'Identificación'),
            ),
            TextField(
              controller: _correoCtrl,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _licenciaCtrl,
              decoration: const InputDecoration(labelText: 'Licencia'),
            ),
            TextField(
              controller: _arlCtrl,
              decoration: const InputDecoration(labelText: 'ARL'),
            ),
            DropdownButtonFormField(
              value: _sangreSeleccionada,
              items: [
                'O',
                'A',
                'B',
                'AB',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _sangreSeleccionada = val!),
              decoration: const InputDecoration(labelText: 'Grupo Sanguíneo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Aquí llamaremos al servicio que crearemos en el siguiente paso
                bool exito = await AdminService().registrarConductor(
                  _nombreCtrl.text,
                  _cedulaCtrl.text,
                  _correoCtrl.text,
                  _licenciaCtrl.text,
                  _arlCtrl.text,
                  _sangreSeleccionada,
                );
                if (exito) Navigator.pop(context);
              },
              child: const Text('Guardar Conductor'),
            ),
          ],
        ),
      ),
    );
  }
}
