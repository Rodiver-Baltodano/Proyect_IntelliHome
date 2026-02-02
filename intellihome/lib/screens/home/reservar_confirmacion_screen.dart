import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/reservas/services/reserva_service.dart';
import 'package:intellihome/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ReservarConfirmacionScreen extends StatefulWidget {
  final Casa casa;
  final DateTimeRange rango;

  const ReservarConfirmacionScreen({
    super.key,
    required this.casa,
    required this.rango,
  });

  @override
  State<ReservarConfirmacionScreen> createState() =>
      _ReservarConfirmacionScreenState();
}

class _ReservarConfirmacionScreenState
    extends State<ReservarConfirmacionScreen> {
  final _numeroController = TextEditingController();
  final _expiracionController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _numeroController.dispose();
    _expiracionController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  int _calcularNoches(DateTime inicio, DateTime fin) {
    final noches = fin.difference(inicio).inDays;
    return noches <= 0 ? 1 : noches;
  }

  String _formatPrecio(double precio) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(precio);
  }

  String _formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
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

  String _formatearDatosTarjeta(String numeroTarjeta, String fechaExpiracion) {
    final limpia = numeroTarjeta.replaceAll(RegExp(r'\s+'), '');
    final ultimos4 = limpia.length >= 4 ? limpia.substring(limpia.length - 4) : limpia;
    final mascara = '**** **** **** $ultimos4';
    if (fechaExpiracion.trim().isNotEmpty) {
      return '$mascara (exp $fechaExpiracion)';
    }
    return mascara;
  }

  Future<void> _guardarTarjeta(Usuario usuario, String datosTargeta) async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'usuarios_integrado.json');
    final repo = UsuarioRepositorioJson(rutaArchivo: rutaJson);

    final actualizado = Usuario(
      id: usuario.id,
      username: usuario.username,
      nombreApellidos: usuario.nombreApellidos,
      correo: usuario.correo,
      telefono: usuario.telefono,
      contrasena: usuario.contrasena,
      nacionalidad: usuario.nacionalidad,
      numeroIBAN: usuario.numeroIBAN,
      fotoPerfil: usuario.fotoPerfil,
      aceptaTerminos: usuario.aceptaTerminos,
      cedula: usuario.cedula,
      datosTargeta: datosTargeta,
      huellaBiometrica: usuario.huellaBiometrica,
      intentosFallidos: usuario.intentosFallidos,
      intentosFallidosCodigo: usuario.intentosFallidosCodigo,
      estaBloqueado: usuario.estaBloqueado,
      codigoRecuperacion: usuario.codigoRecuperacion,
      codigoExpira: usuario.codigoExpira,
      fechaRegistro: usuario.fechaRegistro,
      fechaNacimiento: usuario.fechaNacimiento,
      tema: usuario.tema,
      estilo: usuario.estilo,
      colorPrimarioARGB: usuario.colorPrimarioARGB,
      colorBackgroundARGB: usuario.colorBackgroundARGB,
      casas: usuario.casas,
      reservas: usuario.reservas,
    );

    await repo.actualizarUsuario(actualizado);
    if (!mounted) return;
    context.read<ThemeProvider>().inicializarConUsuario(actualizado, repositorio: repo);
  }

  Future<void> _confirmarReserva() async {
    final usuario = context.read<ThemeProvider>().usuarioActual;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe iniciar sesión para reservar.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    final tieneTarjeta = usuario.datosTargeta != null && usuario.datosTargeta!.isNotEmpty;

    if (!tieneTarjeta) {
      final numero = _numeroController.text.trim();
      final exp = _expiracionController.text.trim();
      final cvv = _cvvController.text.trim();

      if (numero.isEmpty || exp.isEmpty || cvv.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe ingresar los datos de la tarjeta.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      final datosTargeta = _formatearDatosTarjeta(numero, exp);
      await _guardarTarjeta(usuario, datosTargeta);
    }

    final appDir = await getApplicationDocumentsDirectory();
    final reservasPath = p.join(appDir.path, 'reservas_integrado.json');
    final usuariosPath = p.join(appDir.path, 'usuarios_integrado.json');
    final casasPath = p.join(appDir.path, 'casas_integrado.json');

    final reservasRepo = ReservaRepositorioJson(rutaArchivo: reservasPath);
    final usuariosRepo = UsuarioRepositorioJson(rutaArchivo: usuariosPath);
    final casasRepo = CasaRepositorioJson(rutaArchivo: casasPath);
    final service = ReservaService(
      repositorio: reservasRepo,
      usuarioRepositorio: usuariosRepo,
      casaRepositorio: casasRepo,
    );

    final resultado = await service.createReservation(
      userId: usuario.id,
      propertyId: widget.casa.id,
      nombreCasa: widget.casa.nombre,
      startDate: widget.rango.start,
      endDate: widget.rango.end,
    );

    if (!mounted) return;

    if (resultado.exitoso) {
      final fechasActualizadas = _buildFechasNoDisponibles(
        widget.casa.fechasNoDisponibles,
        widget.rango.start,
        widget.rango.end,
      );

      await casasRepo.actualizarCasa(
        Casa(
          id: widget.casa.id,
          nombre: widget.casa.nombre,
          precioPorNoche: widget.casa.precioPorNoche,
          maxPersonas: widget.casa.maxPersonas,
          habitaciones: widget.casa.habitaciones,
          descripcion: widget.casa.descripcion,
          fotos: widget.casa.fotos,
          ubicacion: widget.casa.ubicacion,
          reglasUso: widget.casa.reglasUso,
          ownerId: widget.casa.ownerId,
          fechaRegistro: widget.casa.fechaRegistro,
          amenidades: widget.casa.amenidades,
          fechasNoDisponibles: fechasActualizadas,
        ),
      );

      final usuarioActualizado = await usuariosRepo.buscarPorId(usuario.id);
      if (usuarioActualizado != null && mounted) {
        context.read<ThemeProvider>().inicializarConUsuario(
              usuarioActualizado,
              repositorio: usuariosRepo,
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado.mensaje,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado.mensaje,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  List<DateTime> _buildFechasNoDisponibles(
    List<DateTime> existentes,
    DateTime inicio,
    DateTime fin,
  ) {
    final set = <String>{
      for (final fecha in existentes)
        DateTime(fecha.year, fecha.month, fecha.day).toIso8601String(),
    };

    for (DateTime d = DateTime(inicio.year, inicio.month, inicio.day);
        !d.isAfter(fin);
        d = d.add(const Duration(days: 1))) {
      set.add(d.toIso8601String());
    }

    final result = set.map(DateTime.parse).toList();
    result.sort();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<ThemeProvider>().usuarioActual!;
    final tieneTarjeta = usuario.datosTargeta != null &&
        usuario.datosTargeta!.isNotEmpty;

    if (tieneTarjeta) {
      _numeroController.text = usuario.datosTargeta!;
    }

    final noches = _calcularNoches(widget.rango.start, widget.rango.end);
    final subtotal = widget.casa.precioPorNoche * noches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar reserva'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.casa.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.casa.fotos.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    final provider = _buildImageProvider(
                      widget.casa.fotos.first,
                    );
                    if (provider == null) return const SizedBox.shrink();
                    return Image(
                      image: provider,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            if (widget.casa.fotos.isNotEmpty) const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desglose de la reserva',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Fechas: ${_formatFecha(widget.rango.start)} - ${_formatFecha(widget.rango.end)}'),
                  const SizedBox(height: 6),
                  Text('Noches: $noches'),
                  const SizedBox(height: 6),
                  Text('Precio por noche: ₡${_formatPrecio(widget.casa.precioPorNoche)}'),
                  const Divider(height: 20),
                  Text(
                    'Total: ₡${_formatPrecio(subtotal)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Método de pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (tieneTarjeta) ...[
              TextField(
                controller: _numeroController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tarjeta registrada',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Para cambiar la tarjeta, actualice sus datos en perfil.',
                style: TextStyle(color: Colors.grey),
              ),
            ] else ...[
              TextField(
                controller: _numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiracionController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Expiración (MM/AA)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmarReserva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Confirmar Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
