import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/screens/home/amenidades_data.dart';

class ReservarCasaScreen extends StatelessWidget {
  final Casa casa;

  const ReservarCasaScreen({
    super.key,
    required this.casa,
  });

  ImageProvider? _buildImageProvider(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) return NetworkImage(ruta);
    final file = File(ruta);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final portada = casa.fotos.isNotEmpty ? casa.fotos.first : null;
    final portadaProvider = _buildImageProvider(portada);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar casa'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Fotos
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.backgroundColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: portadaProvider != null
                  ? Image(
                      image: portadaProvider,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondaryColor,
                        size: 48,
                      ),
                    ),
            ),
            if (casa.fotos.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: casa.fotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final ruta = casa.fotos[index];
                    final provider = _buildImageProvider(ruta);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: AppColors.backgroundColor,
                        child: provider != null
                            ? Image(image: provider, fit: BoxFit.cover)
                            : Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondaryColor,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Sección: Detalles básicos
            Text(
              casa.nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('🇨🇷', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '₵ ${casa.precioPorNoche.toStringAsFixed(0)} / noche',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 6),
                Text('Máximo ${casa.maxPersonas} personas'),
                const SizedBox(width: 16),
                const Icon(Icons.meeting_room, size: 18),
                const SizedBox(width: 6),
                Text('${casa.habitaciones} cuartos'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción y Características',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              casa.descripcion,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detalles del lugar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _detalleItem(
              icon: Icons.public,
              label: 'Ubicación',
              value: casa.ubicacion.isEmpty ? 'Sin ubicación' : casa.ubicacion,
            ),
            const SizedBox(height: 10),
            _detalleItem(
              icon: Icons.schedule,
              label: 'Reglas de uso',
              value: casa.reglasUso.isEmpty ? 'Sin reglas' : casa.reglasUso,
            ),
            const SizedBox(height: 10),
            _detalleItem(
              icon: Icons.list_alt,
              label: 'Amenidades',
              value: casa.amenidades.isEmpty ? 'Sin amenidades' : '',
            ),
            if (casa.amenidades.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: amenidadesCatalogo
                      .where((item) => casa.amenidades.contains(item.id))
                      .length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selectedItems = amenidadesCatalogo
                        .where((item) => casa.amenidades.contains(item.id))
                        .toList();
                    final item = selectedItems[index];
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Icon(item.icono, size: 18, color: AppColors.primaryColor),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 10),
            _detalleItem(
              icon: Icons.calendar_today,
              label: 'Disponibilidad',
              value: casa.fechasNoDisponibles.isEmpty
                  ? 'Sin fechas bloqueadas'
                  : '',
            ),
            if (casa.fechasNoDisponibles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: casa.fechasNoDisponibles
                    .map(
                      (date) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Text(
                          _formatDate(date),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Reservar casa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detalleItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }
}
