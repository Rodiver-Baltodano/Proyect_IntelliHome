import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/screens/home/domotic_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final usuario = themeProvider.usuarioActual;
    final nombreUsuario = usuario?.username ?? username;
    final fotoPerfil = usuario?.fotoPerfil;
    final estilo = usuario?.estilo ?? themeProvider.currentStyle.name;
    final estiloDisplay = _estiloConEmoji(estilo, context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundImage: _buildImageProvider(fotoPerfil),
                    child: (fotoPerfil == null || fotoPerfil.isEmpty)
                        ? const Icon(Icons.person, size: 32, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombreUsuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Opción de Control Domótico
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(AppLocalizations.of(context).domoticControl),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DomoticScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_home_outlined),
              title: const Text('Añadir casa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/anadir_casa');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.palette),
              title: Text(AppLocalizations.of(context).customize),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/personalizacion',
                  arguments: {
                    'username': nombreUsuario,
                    'fromRegister': false,
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(AppLocalizations.of(context).logout),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar de perfil
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
              backgroundImage: _buildImageProvider(fotoPerfil),
              child: (fotoPerfil == null || fotoPerfil.isEmpty)
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.secondaryColor,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).welcome,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              nombreUsuario,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.tertiaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (estiloDisplay != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      estiloDisplay.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estiloDisplay.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  _EstiloDisplay? _estiloConEmoji(String estilo, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (estilo) {
      case 'aventurero':
        return _EstiloDisplay(label: l10n.adventurous, emoji: '🚀');
      case 'minimalista':
        return _EstiloDisplay(label: l10n.minimalist, emoji: '✨');
      case 'contemporaneo':
        return _EstiloDisplay(label: l10n.contemporary, emoji: '🖼️');
      default:
        return null;
    }
  }

  ImageProvider? _buildImageProvider(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) {
      return NetworkImage(ruta);
    }
    final file = File(ruta);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }
}

class _EstiloDisplay {
  final String label;
  final String emoji;
  _EstiloDisplay({required this.label, required this.emoji});
}