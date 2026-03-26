import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  // Controladores para los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Llenamos los campos con la info actual del usuario
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedGender = widget.user.gender ?? "Masculino";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // FUNCIÓN CRUCIAL: Envía los datos a Hostinger
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Llamamos al servicio con la URL que me pasaste
      final updatedUser = await _profileService.updateUserProfile(
        userId: widget.user.id_usuario.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        gender: _selectedGender!,
      );

      if (mounted) {
        // Regresamos a la pantalla de Perfil enviando el nuevo usuario
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFD10000);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        title: const Text('Editar Perfil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: redColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputCard(),
              const SizedBox(height: 30),
              _buildSaveButton(redColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildTextField(_nameController, 'Nombre', Icons.person),
          const SizedBox(height: 15),
          _buildTextField(_emailController, 'Correo', Icons.email,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 15),
          _buildTextField(_phoneController, 'Teléfono', Icons.phone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: InputDecoration(
              labelText: 'Género',
              prefixIcon: const Icon(Icons.wc),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            items: ['Masculino', 'Femenino', 'Otro']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
    );
  }

  Widget _buildSaveButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Guardar Cambios',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
      ),
    );
  }
}
