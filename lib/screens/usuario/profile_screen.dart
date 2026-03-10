import 'package:flutter/material.dart';

import 'help_center_screen.dart';
import 'accessibility_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const red = Color(0xFFD10000);

  bool _notificationsEnabled = true;
  bool _darkMode = false;

  final String _name = "Usuario TransTunja";
  final String _email = "usuario@email.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          children: [
            const Center(
              child: Text(
                "Perfil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 20),

            // Avatar + Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
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
                        child: Container(
                          decoration: const BoxDecoration(
                            color: red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Función de cambiar foto (mock)",
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_email, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preferencias
            _SectionCard(
              title: "Preferencias",
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  activeColor: red,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                  title: const Text(
                    "Recibir notificaciones",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  secondary: const Icon(Icons.notifications_none),
                ),
                SwitchListTile(
                  value: _darkMode,
                  activeColor: red,
                  onChanged: (v) => setState(() => _darkMode = v),
                  title: const Text(
                    "Modo oscuro (mock)",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  secondary: const Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cuenta
            _SectionCard(
              title: "Cuenta",
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text(
                    "Cambiar contraseña",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Función futura")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    "Política de privacidad",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Función futura")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Soporte e inclusión
            _SectionCard(
              title: "Soporte e inclusión",
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text(
                    "Centro de ayuda",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.accessibility_new),
                  title: const Text(
                    "Accesibilidad",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccessibilityScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cerrar sesión (mock)")),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
