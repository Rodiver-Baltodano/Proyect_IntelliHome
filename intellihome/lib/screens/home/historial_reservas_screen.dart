import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/reservas/models/reserva.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/screens/home/domotic_screen.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class HistorialReservasScreen extends StatefulWidget {
  const HistorialReservasScreen({super.key});

  @override
  State<HistorialReservasScreen> createState() => _HistorialReservasScreenState();
}

class _HistorialReservasScreenState extends State<HistorialReservasScreen> {
  Future<List<_ReservaItem>> _cargarReservas() async {
    final usuario = context.read<ThemeProvider>().usuarioActual;
    if (usuario == null) return [];

    final appDir = await getApplicationDocumentsDirectory();
    final reservasPath = p.join(appDir.path, 'reservas_integrado.json');
    final casasPath = p.join(appDir.path, 'casas_integrado.json');

    final reservasRepo = ReservaRepositorioJson(rutaArchivo: reservasPath);
    final casasRepo = CasaRepositorioJson(rutaArchivo: casasPath);

    final reservas = await reservasRepo.obtenerPorUsuario(usuario.id);
    final casas = await casasRepo.cargarCasas();
    final casasMap = {for (final casa in casas) casa.id: casa};

    return reservas
        .map((r) => _ReservaItem(reserva: r, casa: casasMap[r.propertyId]))
        .toList();
  }

  String _estadoLabel(String status) {
    switch (status) {
      case ReservaStatus.pending:
        return 'Pendiente';
      case ReservaStatus.confirmed:
      case ReservaStatus.active:
        return 'Activo';
      case ReservaStatus.finished:
      case ReservaStatus.completed:
      case ReservaStatus.cancelled:
        return 'Finalizado';
      default:
        return 'Finalizado';
    }
  }

  bool _domoticaHabilitada(String status) {
    return status == ReservaStatus.active;
  }

  ImageProvider? _buildImageProvider(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) return NetworkImage(ruta);
    final file = File(ruta);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de reservas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<_ReservaItem>>(
        future: _cargarReservas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar reservas: ${snapshot.error}'),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No hay reservas registradas.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final casa = item.casa;
              final imagen = casa?.fotos.isNotEmpty == true ? casa!.fotos.first : null;
              final imageProvider = _buildImageProvider(imagen);
              final estado = _estadoLabel(item.reserva.status);
              final domoticaEnabled = _domoticaHabilitada(item.reserva.status);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Columna 1: imagen
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: AppColors.backgroundColor,
                        child: imageProvider != null
                            ? Image(image: imageProvider, fit: BoxFit.cover)
                            : Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondaryColor,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Columna 2: nombre + estado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            casa?.nombre ?? 'Casa desconocida',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            estado,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Columna 3: botón domótica
                    IconButton(
                      onPressed: domoticaEnabled
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DomoticScreen(),
                                ),
                              );
                            }
                          : null,
                      icon: Icon(Icons.home_outlined),
                      color: AppColors.primaryColor,
                      tooltip: 'Domótica',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservaItem {
  final Reserva reserva;
  final Casa? casa;

  _ReservaItem({
    required this.reserva,
    required this.casa,
  });
}
