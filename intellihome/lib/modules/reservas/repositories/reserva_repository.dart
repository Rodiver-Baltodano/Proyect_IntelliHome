import 'dart:convert';
import 'dart:io';

import 'package:intellihome/modules/reservas/models/reserva.dart';

/// Repositorio para gestionar reservas almacenadas en un archivo JSON
class ReservaRepositorioJson {
  final String rutaArchivo;

  ReservaRepositorioJson({required this.rutaArchivo});

  /// Lee el archivo JSON y devuelve la lista de reservas.
  Future<List<Reserva>> cargarReservas() async {
    final archivo = File(rutaArchivo);

    ///print('[Reserva_Repository] Cargando reservas desde: $rutaArchivo');

    if (!await archivo.exists()) {
      ///print(' [Reserva_Repository] Archivo no existe, retornando lista vacía.');
      return [];
    }

    final contenido = await archivo.readAsString();
    if (contenido.trim().isEmpty) {
      return [];
    }

    final dynamic data = jsonDecode(contenido);

    List<dynamic> listaJson;

    if (data is List) {
      listaJson = data;
    } else if (data is Map<String, dynamic> && data['reservas'] is List) {
      listaJson = data['reservas'] as List;
    } else {
      throw FormatException('Formato JSON de reservas no soportado.');
    }

    return listaJson
        .whereType<Map<String, dynamic>>()
        .map((r) => Reserva.fromJson(r))
        .toList();
  }

  /// Guarda la lista completa de reservas al archivo JSON.
  /// Por simplicidad, guarda como LISTA RAÍZ.
  Future<void> guardarReservas(List<Reserva> reservas) async {
    final archivo = File(rutaArchivo);

    // Asegurar que la carpeta exista
    await archivo.parent.create(recursive: true);

    final lista = reservas.map((r) => r.toJson()).toList();
    final contenido = const JsonEncoder.withIndent('  ').convert(lista);

    await archivo.writeAsString(contenido);
    ///print(' [reserva_repository] ${reservas.length} reservas guardadas exitosamente.');
  }

  /// Busca una reserva por su ID
  Future<Reserva?> buscarPorId(String reservationId) async {
    final reservas = await cargarReservas();
    try {
      return reservas.firstWhere((r) => r.reservationId == reservationId);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene todas las reservas de una propiedad específica
  Future<List<Reserva>> obtenerPorPropiedad(String propertyId) async {
    final reservas = await cargarReservas();
    return reservas.where((r) => r.propertyId == propertyId).toList();
  }

  /// Obtiene todas las reservas con un estado específico
  Future<List<Reserva>> obtenerPorEstado(String status) async {
    final reservas = await cargarReservas();
    return reservas.where((r) => r.status == status).toList();
  }

  /// Obtiene todas las reservas de un usuario específico
  Future<List<Reserva>> obtenerPorUsuario(String userId) async {
    final reservas = await cargarReservas();
    return reservas.where((r) => r.userId == userId).toList();
  }

  /// Obtiene reservas activas (PENDING o CONFIRMED) para una propiedad
  Future<List<Reserva>> obtenerReservasActivas(String propertyId) async {
    final reservas = await cargarReservas();
    return reservas.where((r) => 
      r.propertyId == propertyId && 
      (r.status == ReservaStatus.pending || 
       r.status == ReservaStatus.confirmed ||
       r.status == ReservaStatus.active) 
    ).toList();
  }

  /// Agrega una nueva reserva
  Future<void> agregarReserva(Reserva reserva) async {
    final reservas = await cargarReservas();
    
    // Verificar que no exista ya una reserva con el mismo ID
    if (reservas.any((r) => r.reservationId == reserva.reservationId)) {
      throw StateError('Ya existe una reserva con id=${reserva.reservationId}');
    }

    reservas.add(reserva);
    await guardarReservas(reservas);
    ///print(' [reserva_repository] Nueva reserva agregada: ${reserva.reservationId}');
  }

  /// Actualiza una reserva existente
  Future<void> actualizarReserva(Reserva reservaActualizada) async {
    final reservas = await cargarReservas();

    final index = reservas.indexWhere((r) => r.reservationId == reservaActualizada.reservationId);
    if (index == -1) {
      throw StateError('No se encontró la reserva con id=${reservaActualizada.reservationId}');
    }

    reservas[index] = reservaActualizada;
    await guardarReservas(reservas);
    ///print(' [reserva_repository] Reserva actualizada: ${reservaActualizada.reservationId}');
  }

  /// Elimina una reserva por su ID
  Future<void> eliminarReserva(String reservationId) async {
    final reservas = await cargarReservas();
    
    final cantidadInicial = reservas.length;
    reservas.removeWhere((r) => r.reservationId == reservationId);

    if (reservas.length == cantidadInicial) {
      throw StateError('No se encontró la reserva con id=$reservationId');
    }

    await guardarReservas(reservas);
    ///print(' [reserva_repository] Reserva eliminada: $reservationId');
  }

  /// Cancela una reserva (cambia su estado a CANCELLED)
  Future<void> cancelarReserva(String reservationId) async {
    final reserva = await buscarPorId(reservationId);
    
    if (reserva == null) {
      throw StateError('No se encontró la reserva con id=$reservationId');
    }

    final reservaCancelada = reserva.copyWith(status: ReservaStatus.cancelled);
    await actualizarReserva(reservaCancelada);
    ///print(' [reserva_repository] Reserva cancelada: $reservationId');
  }

  /// Confirma una reserva (cambia su estado de PENDING a CONFIRMED)
  Future<void> confirmarReserva(String reservationId) async {
    final reserva = await buscarPorId(reservationId);
    
    if (reserva == null) {
      throw StateError('No se encontró la reserva con id=$reservationId');
    }

    if (reserva.status != ReservaStatus.pending) {
      throw StateError('Solo se pueden confirmar reservas en estado PENDING');
    }

    final reservaConfirmada = reserva.copyWith(status: ReservaStatus.confirmed);
    await actualizarReserva(reservaConfirmada);
    ///print(' [reserva_repository] Reserva confirmada: $reservationId');
  }

  /// Verifica si hay conflicto de fechas para una propiedad
  Future<bool> tieneConflictoFechas({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeReservationId,
  }) async {
    final reservasActivas = await obtenerReservasActivas(propertyId);

    for (var reserva in reservasActivas) {
      // Excluir la reserva actual si se está editando
      if (excludeReservationId != null && reserva.reservationId == excludeReservationId) {
        continue;
      }

      // Verificar si hay solapamiento de fechas
      if (_fechasSeSolapan(
        startDate, endDate,
        reserva.startDate, reserva.endDate,
      )) {
        return true;
      }
    }

    return false;
  }

  /// Verifica si dos rangos de fechas se solapan
  bool _fechasSeSolapan(
    DateTime start1, DateTime end1,
    DateTime start2, DateTime end2,
  ) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }
}
