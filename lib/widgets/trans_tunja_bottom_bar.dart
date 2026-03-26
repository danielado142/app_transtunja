import 'package:flutter/material.dart';

class TransTunjaBottomBar extends StatelessWidget {
  const TransTunjaBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color colorRojoApp = Color(0xFFD10000);

  static const List<_BottomBarItemData> _items = [
    _BottomBarItemData(
      label: 'Admin',
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt_rounded,
    ),
    _BottomBarItemData(
      label: 'Rutas',
      icon: Icons.alt_route_outlined,
      activeIcon: Icons.alt_route_rounded,
    ),
    _BottomBarItemData(
      label: 'Paradas',
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on_rounded,
    ),
    _BottomBarItemData(
      label: 'Conductores',
      icon: Icons.drive_eta_outlined,
      activeIcon: Icons.drive_eta_rounded,
    ),
    _BottomBarItemData(
      label: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorRojoApp,
      elevation: 10,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: Colors.white,
                          size: isSelected ? 26 : 23,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSelected ? 13 : 12,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3,
                          width: isSelected ? 22 : 0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _BottomBarItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
