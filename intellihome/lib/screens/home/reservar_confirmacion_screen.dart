import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/models/usuario.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/finanzas/services/algoritmo_banquero.dart';
import 'package:intellihome/modules/finanzas/models/pago.dart';
import 'package:intellihome/modules/finanzas/repositories/pago_repository.dart';
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
  bool _procesandoPago = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _expiracionController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
/*
  int _calcularNoches(DateTime inicio, DateTime fin) {
    final noches = fin.difference(inicio).inDays;
    return noches <= 0 ? 1 : noches;
  }*/

  int _calcularDias(DateTime inicio, DateTime fin) {
    final start = DateTime(inicio.year, inicio.month, inicio.day);
    final end = DateTime(fin.year, fin.month, fin.day);
    final diff = end.difference(start).inDays;
    if (diff < 0) return 0;
    return diff + 1;
  }

  String _formatPrecio(double precio) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(precio);
  }

  String _formatPrecioConDecimales(double precio) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
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

  Widget _buildDetalleFila(
    String label,
    String value, {
    bool bold = false,
  }) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: style),
          ),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
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

    if (_procesandoPago) return;

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
    setState(() {
      _procesandoPago = true;
    });

    bool dialogAbierto = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 12),
            Expanded(child: Text('Procesando pago...')),
          ],
        ),
      ),
    );

    try {
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
        final dias = _calcularDias(widget.rango.start, widget.rango.end);
        final montoArrendamiento = widget.casa.precioPorNoche * dias;
        final comision = montoArrendamiento * 0.05;
        final iva = comision * 0.13;
        final ahora = DateTime.now();
        final porcentajeAjuste = AlgoritmoBanquero.calcularAjusteFinanciero(
          dia: ahora.day,
          mes: ahora.month,
          montoTotal: montoArrendamiento,
        );
        final subtotalConCargos = montoArrendamiento + comision + iva;
        final ajuste = subtotalConCargos * porcentajeAjuste;
        final total = subtotalConCargos + ajuste;

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

        final pagosPath = p.join(appDir.path, 'pagos_integrado.json');
        final pagosRepo = PagoRepositorioJson(rutaArchivo: pagosPath);
        final reservaId = resultado.reserva?.reservationId ?? '';
        if (reservaId.isNotEmpty) {
          final pago = Pago(
            pagoId: reservaId,
            reservationId: reservaId,
            userId: usuario.id,
            propertyId: widget.casa.id,
            nombreCasa: widget.casa.nombre,
            montoArrendamiento: montoArrendamiento,
            comision: comision,
            iva: iva,
            ajuste: ajuste,
            total: total,
            fecha: DateTime.now(),
          );
          await pagosRepo.agregarPago(pago);
        }

        final usuarioActualizado = await usuariosRepo.buscarPorId(usuario.id);
        if (usuarioActualizado != null && mounted) {
          context.read<ThemeProvider>().inicializarConUsuario(
                usuarioActualizado,
                repositorio: usuariosRepo,
              );
        }

        if (dialogAbierto && mounted) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          dialogAbierto = false;
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
        if (dialogAbierto && mounted) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          dialogAbierto = false;
        }
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
    } finally {
      if (mounted) {
        if (dialogAbierto && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
          dialogAbierto = false;
        }
        setState(() {
          _procesandoPago = false;
        });
      }
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

    final dias = _calcularDias(widget.rango.start, widget.rango.end);
    final montoArrendamiento = widget.casa.precioPorNoche * dias;
    final comision = montoArrendamiento * 0.05;
    final iva = comision * 0.13;
    final ahora = DateTime.now();
    final porcentajeAjuste = AlgoritmoBanquero.calcularAjusteFinanciero(
      dia: ahora.day,
      mes: ahora.month,
      montoTotal: montoArrendamiento,
    );
    final subtotalConCargos = montoArrendamiento + comision + iva;
    final ajuste = subtotalConCargos * porcentajeAjuste;
    final total = subtotalConCargos + ajuste;

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
              padding: const EdgeInsets.all(16),
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
                    'Desglose académico del costo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fechas: ${_formatFecha(widget.rango.start)} - ${_formatFecha(widget.rango.end)}',
                  ),
                  const SizedBox(height: 6),
                  _buildDetalleFila('Cantidad de días reservados', '$dias'),
                  _buildDetalleFila(
                    'Precio por noche',
                    '₡${_formatPrecio(widget.casa.precioPorNoche)}',
                  ),
                  const Divider(height: 20),
                  _buildDetalleFila(
                    'Monto del arrendamiento',
                    '₡${_formatPrecio(montoArrendamiento)}',
                  ),
                  Text(
                    'Resultado de $dias día(s) × ₡${_formatPrecio(widget.casa.precioPorNoche)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  _buildDetalleFila(
                    'Comisión de servicio (5%)',
                    '₡${_formatPrecio(comision)}',
                  ),
                  _buildDetalleFila(
                    'IVA sobre la comisión (13%)',
                    '₡${_formatPrecio(iva)}',
                  ),
                  const SizedBox(height: 6),
                  _buildDetalleFila(
                    'Ajuste financiero dinámico',
                    '₡${_formatPrecioConDecimales(ajuste)}',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Modelo académico de ajuste dinámico basado en el algoritmo del banquero.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Divider(height: 24),
                  _buildDetalleFila(
                    'Total a pagar',
                    '₡${_formatPrecio(total)}',
                    bold: true,
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
                onPressed: _procesandoPago ? null : _confirmarReserva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _procesandoPago
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Confirmar Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
