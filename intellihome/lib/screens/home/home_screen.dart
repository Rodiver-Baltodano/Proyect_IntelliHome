import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/providers/theme_provider.dart';
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
    final estiloDisplay = _estiloConEmoji(estilo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliHome'),
        centerTitle: true,
        elevation: 0,
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
              'Bienvenido',
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

  _EstiloDisplay? _estiloConEmoji(String estilo) {
    switch (estilo) {
      case 'aventurero':
        return const _EstiloDisplay(label: 'Aventurero', emoji: '🚀');
      case 'minimalista':
        return const _EstiloDisplay(label: 'Minimalista', emoji: '✨');
      case 'contemporaneo':
        return const _EstiloDisplay(label: 'Contemporáneo', emoji: '🖼️');
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
  const _EstiloDisplay({required this.label, required this.emoji});
}
