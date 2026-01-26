import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intellihome/screens/home/reservar_casa_screen.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class MisCasasScreen extends StatefulWidget {
  const MisCasasScreen({super.key});

  @override
  State<MisCasasScreen> createState() => _MisCasasScreenState();
}

class _MisCasasScreenState extends State<MisCasasScreen> {
  final Map<String, int> _imageIndexByCasa = {};

  Future<List<Casa>> _cargarMisCasas() async {
    final usuario = context.read<ThemeProvider>().usuarioActual;
    if (usuario == null) return [];
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'casas_integrado.json');
    final repo = CasaRepositorioJson(rutaArchivo: rutaJson);
    final casas = await repo.cargarCasas();
    return casas.where((c) => c.ownerId == usuario.id).toList();
  }

  void _toggleImage(Casa casa) {
    final total = casa.fotos.length;
    if (total <= 1) return;
    final current = _imageIndexByCasa[casa.id] ?? 0;
    final next = (current + 1) % total;
    setState(() {
      _imageIndexByCasa[casa.id] = next;
    });
  }

  ImageProvider? _buildCasaImage(String? ruta) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis casas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Casa>>(
        future: _cargarMisCasas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar casas: ${snapshot.error}'),
            );
          }
          final casas = snapshot.data ?? [];
          if (casas.isEmpty) {
            return const Center(
              child: Text('No has publicado casas aún.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: casas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final casa = casas[index];
              final imageIndex = _imageIndexByCasa[casa.id] ?? 0;
              final imagePath = casa.fotos.isNotEmpty
                  ? casa.fotos[imageIndex.clamp(0, casa.fotos.length - 1)]
                  : null;
              final imageProvider = _buildCasaImage(imagePath);

              return InkWell(
                onTap: () => _toggleImage(casa),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: imageProvider != null
                                  ? Image(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppColors.backgroundColor,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: AppColors.textSecondaryColor,
                                        size: 40,
                                      ),
                                    ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  casa.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReservarCasaScreen(
                                      casa: casa,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_red_eye_outlined),
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ver detalles',
                              style: TextStyle(
                                color: AppColors.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
