import 'package:flutter/material.dart';

// Importaciones con la ruta absoluta del proyecto
import 'package:app_transtunja/models/user_model.dart';
import 'package:app_transtunja/services/profile_service.dart';

// Importaciones locales de la carpeta 'usuario'
import 'help_center_screen.dart';
import 'accessibility_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const red = Color(0xFFD10000);

  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  bool _isLoading = true;
  bool _isUpdatingPreferences = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = await _profileService.getUserProfile();
      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: $e')),
      );
    }
  }

  Future<void> _openEditProfile() async {
    if (_user == null) return;

    // Navegamos pasando únicamente el objeto user
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(user: _user!),
      ),
    );

    // Verificamos si regresó un usuario actualizado
    if (updatedUser != null && mounted) {
      setState(() {
        _user = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateNotifications(bool value) async {
    if (_user == null || _isUpdatingPreferences) return;
    setState(() => _isUpdatingPreferences = true);

    try {
      final updatedUser = await _profileService.updatePreferences(
        notificationsEnabled: value,
      );
      if (mounted) setState(() => _user = updatedUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPreferences = false);
    }
  }

  Future<void> _updateDarkMode(bool value) async {
    if (_user == null || _isUpdatingPreferences) return;
    setState(() => _isUpdatingPreferences = true);

    try {
      final updatedUser = await _profileService.updatePreferences(
        darkMode: value,
      );
      if (mounted) setState(() => _user = updatedUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPreferences = false);
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    try {
      await _profileService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada con éxito')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: red)),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No se pudo cargar la información.',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Reintentar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final String subtitleExtra = [
      if (_user!.phone.isNotEmpty) _user!.phone,
      if (_user!.gender != null && _user!.gender!.isNotEmpty) _user!.gender!,
    ].join(' • ');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: red,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Administra tu información personal y tus preferencias.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildHeaderCard(_user!, subtitleExtra),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Preferencias',
                children: [
                  SwitchListTile(
                    value: _user!.notificationsEnabled,
                    activeColor: red,
                    onChanged:
                        _isUpdatingPreferences ? null : _updateNotifications,
                    title: const Text('Recibir notificaciones',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    secondary: const Icon(Icons.notifications_none),
                  ),
                  SwitchListTile(
                    value: _user!.darkMode,
                    activeColor: red,
                    onChanged: _isUpdatingPreferences ? null : _updateDarkMode,
                    title: const Text('Modo oscuro',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Cuenta',
                children: [
                  _buildListTile(Icons.person_outline,
                      'Editar datos personales', _openEditProfile),
                  const Divider(height: 1, indent: 50),
                  _buildListTile(Icons.lock_outline, 'Cambiar contraseña', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Soporte e inclusión',
                children: [
                  _buildListTile(Icons.help_outline, 'Centro de ayuda', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen()));
                  }),
                  const Divider(height: 1, indent: 50),
                  _buildListTile(Icons.accessibility_new, 'Accesibilidad', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AccessibilityScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: red,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title:
          const Text('Perfil', style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildHeaderCard(UserModel user, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              blurRadius: 10, color: Colors.black12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: red.withOpacity(0.15),
                child: const Icon(Icons.person, size: 50, color: red),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: red,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    onPressed: _openEditProfile,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user.name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          Text(user.email, style: const TextStyle(color: Colors.black54)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: const TextStyle(color: Colors.black45, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing:
          const Icon(Icons.chevron_right, size: 20, color: Colors.black38),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: red))
          : const Icon(Icons.logout),
      label: const Text('Cerrar sesión',
          style: TextStyle(fontWeight: FontWeight.w900)),
      style: OutlinedButton.styleFrom(
        foregroundColor: red,
        side: const BorderSide(color: red, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  Color? get red => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              blurRadius: 10, color: Colors.black12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 15, color: red)),
          ),
          ...children,
        ],
      ),
    );
  }
}
