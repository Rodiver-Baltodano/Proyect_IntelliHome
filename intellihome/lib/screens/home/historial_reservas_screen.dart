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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
                          _MarqueeText(
                            text: casa?.nombre ?? 'Casa desconocida',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            estado,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(item.reserva.startDate)} - ${_formatDate(item.reserva.endDate)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryColor,
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

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pause;

  const _MarqueeText({
    required this.text,
    required this.style,
    this.pause = const Duration(milliseconds: 800),
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> {
  final ScrollController _controller = ScrollController();
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _start(reset: true);
    }
  }

  Future<void> _start({bool reset = false}) async {
    if (!mounted) return;
    if (_running) return;
    _running = true;

    if (reset && _controller.hasClients) {
      _controller.jumpTo(0);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted || !_controller.hasClients) {
      _running = false;
      return;
    }

    final maxScroll = _controller.position.maxScrollExtent;
    if (maxScroll <= 0) {
      _running = false;
      return;
    }

    while (mounted && _controller.hasClients) {
      final duration = Duration(milliseconds: (maxScroll * 20).toInt().clamp(800, 8000));
      await _controller.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
      if (!mounted || !_controller.hasClients) break;
      await Future.delayed(widget.pause);
      _controller.jumpTo(0);
      await Future.delayed(widget.pause);
    }

    _running = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize != null ? widget.style.fontSize! + 4 : 18,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
