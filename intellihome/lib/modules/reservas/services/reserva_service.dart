import 'package:intellihome/modules/reservas/models/reserva.dart';
import 'package:intellihome/modules/reservas/models/resultado_reserva.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para gestionar las operaciones de reservas
class ReservaService {
  final ReservaRepositorioJson _repositorio;
  final UsuarioRepositorioJson? _usuarioRepositorio;
  final _uuid = const Uuid();

  ReservaService({
    required ReservaRepositorioJson repositorio,
    UsuarioRepositorioJson? usuarioRepositorio,
  })  : _repositorio = repositorio,
        _usuarioRepositorio = usuarioRepositorio;

  /// 1. createReservation - Crear una reserva válida según fechas
  /// Valida que el usuario tenga método de pago registrado
  Future<ResultadoReserva> createReservation({
    required String userId,
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Validar que el usuario tenga método de pago
      if (_usuarioRepositorio != null) {
        final usuario = await _usuarioRepositorio.buscarPorId(userId);
        
        if (usuario == null) {
          return ResultadoReserva.fallo(
            mensaje: 'Usuario no encontrado',
            codigoError: 'USER_NOT_FOUND',
          );
        }

        // Validar que tenga método de pago (tarjeta o IBAN)
        final tieneMetodoPago = usuario.datosTargeta != null || 
                                usuario.numeroIBAN.isNotEmpty;
        
        if (!tieneMetodoPago) {
          return ResultadoReserva.fallo(
            mensaje: 'Método de pago no registrado',
            codigoError: 'NO_PAYMENT_METHOD',
          );
        }
      }

      // Validar fechas
      if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
        return ResultadoReserva.fallo(
          mensaje: 'La fecha de fin debe ser posterior a la fecha de inicio',
          codigoError: 'INVALID_DATES',
        );
      }

      if (startDate.isBefore(DateTime.now())) {
        return ResultadoReserva.fallo(
          mensaje: 'La fecha de inicio no puede ser en el pasado',
          codigoError: 'PAST_DATE',
        );
      }

      // Verificar disponibilidad
      final tieneConflicto = await _repositorio.tieneConflictoFechas(
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );

      if (tieneConflicto) {
        return ResultadoReserva.fallo(
          mensaje: 'La propiedad no está disponible en las fechas seleccionadas',
          codigoError: 'DATE_CONFLICT',
        );
      }

      // Crear la reserva
      final nuevaReserva = Reserva(
        reservationId: _uuid.v4(),
        userId: userId,
        status: ReservaStatus.pending,
        startDate: startDate,
        endDate: endDate,
        propertyId: propertyId,
        accessDomotics: false,
      );

      await _repositorio.agregarReserva(nuevaReserva);

      // Enviar WhatsApp de confirmación
      await sendWhatsapp(
        userId: userId,
        reservationId: nuevaReserva.reservationId,
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );

      return ResultadoReserva.exito(
        mensaje: 'Se reservó correctamente',
        reserva: nuevaReserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al crear la reserva: ${e.toString()}',
        codigoError: 'CREATE_ERROR',
      );
    }
  }

  /// Confirma una reserva pendiente
  Future<ResultadoReserva> confirmarReserva(String reservationId) async {
    try {
      await _repositorio.confirmarReserva(reservationId);
      final reserva = await _repositorio.buscarPorId(reservationId);

      return ResultadoReserva.exito(
        mensaje: 'Reserva confirmada exitosamente',
        reserva: reserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al confirmar la reserva: ${e.toString()}',
        codigoError: 'CONFIRM_ERROR',
      );
    }
  }

  /// Cancela una reserva
  Future<ResultadoReserva> cancelarReserva(String reservationId) async {
    try {
      await _repositorio.cancelarReserva(reservationId);
      final reserva = await _repositorio.buscarPorId(reservationId);

      return ResultadoReserva.exito(
        mensaje: 'Reserva cancelada exitosamente',
        reserva: reserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al cancelar la reserva: ${e.toString()}',
        codigoError: 'CANCEL_ERROR',
      );
    }
  }

  /// 2. getReservationById - Obtener una reserva específica
  Future<Reserva?> getReservationById(String reservationId) async {
    return await _repositorio.buscarPorId(reservationId);
  }

  /// Obtiene una reserva por su ID (método legacy)
  Future<Reserva?> obtenerReserva(String reservationId) async {
    return await getReservationById(reservationId);
  }

  /// Obtiene todas las reservas de una propiedad
  Future<List<Reserva>> obtenerReservasPorPropiedad(String propertyId) async {
    return await _repositorio.obtenerPorPropiedad(propertyId);
  }

  /// Obtiene las reservas activas de una propiedad
  Future<List<Reserva>> obtenerReservasActivas(String propertyId) async {
    return await _repositorio.obtenerReservasActivas(propertyId);
  }

  /// Verifica disponibilidad de una propiedad en un rango de fechas
  Future<bool> verificarDisponibilidad({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final tieneConflicto = await _repositorio.tieneConflictoFechas(
      propertyId: propertyId,
      startDate: startDate,
      endDate: endDate,
    );
    return !tieneConflicto;
  }

  /// Actualiza el acceso domótico de una reserva
  Future<ResultadoReserva> actualizarAccesoDomotico({
    required String reservationId,
    required bool accessDomotics,
  }) async {
    try {
      final reserva = await _repositorio.buscarPorId(reservationId);
      
      if (reserva == null) {
        return ResultadoReserva.fallo(
          mensaje: 'Reserva no encontrada',
          codigoError: 'NOT_FOUND',
        );
      }

      final reservaActualizada = reserva.copyWith(accessDomotics: accessDomotics);
      await _repositorio.actualizarReserva(reservaActualizada);

      return ResultadoReserva.exito(
        mensaje: 'Acceso domótico actualizado exitosamente',
        reserva: reservaActualizada,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al actualizar el acceso domótico: ${e.toString()}',
        codigoError: 'UPDATE_ERROR',
      );
    }
  }

  /// Obtiene todas las reservas
  Future<List<Reserva>> obtenerTodasLasReservas() async {
    return await _repositorio.cargarReservas();
  }

  /// 4. activateReservationsByDate - Activar reservas cuando llega su fecha de inicio
  /// Si currentDate >= startDate & status == PENDING, entonces status = ACTIVE
  Future<List<Reserva>> activateReservationsByDate() async {
    try {
      final todasReservas = await _repositorio.cargarReservas();
      final reservasActivadas = <Reserva>[];
      final ahora = DateTime.now();

      for (var reserva in todasReservas) {
        // Si la fecha actual es mayor o igual a la fecha de inicio y está PENDING
        if (ahora.isAfter(reserva.startDate) || ahora.isAtSameMomentAs(reserva.startDate)) {
          if (reserva.status == ReservaStatus.pending) {
            final reservaActualizada = reserva.copyWith(
              status: ReservaStatus.active,
              accessDomotics: true, // Activar acceso domótico
            );
            await _repositorio.actualizarReserva(reservaActualizada);
            reservasActivadas.add(reservaActualizada);
            print('✅ [RESERVAS] Reserva ${reserva.reservationId} activada - Acceso domótico habilitado');
          }
        }
      }

      return reservasActivadas;
    } catch (e) {
      print('❌ Error al activar reservas: $e');
      return [];
    }
  }


  /// Si currentDate > endDate & status == ACTIVE, entonces status = FINISHED
  Future<List<Reserva>> finishReservationsByDate() async {
    try {
      final todasReservas = await _repositorio.cargarReservas();
      final reservasFinalizadas = <Reserva>[];
      final ahora = DateTime.now();

      for (var reserva in todasReservas) {
        // Si la fecha actual es mayor a la fecha de fin y está ACTIVE
        if (ahora.isAfter(reserva.endDate)) {
          if (reserva.status == ReservaStatus.active) {
            final reservaActualizada = reserva.copyWith(
              status: ReservaStatus.finished,
              accessDomotics: false, // Desactivar acceso domótico
            );
            await _repositorio.actualizarReserva(reservaActualizada);
            reservasFinalizadas.add(reservaActualizada);
            print('✅ Reserva ${reserva.reservationId} finalizada');
          }
        }
      }

      return reservasFinalizadas;
    } catch (e) {
      print('❌ Error al finalizar reservas: $e');
      return [];
    }
  }

  /// 6. sendWhatsapp - Envía mensaje de WhatsApp de confirmación
  Future<void> sendWhatsapp({
    required String userId,
    required String reservationId,
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_usuarioRepositorio != null) {
        final usuario = await _usuarioRepositorio.buscarPorId(userId);
        
        if (usuario != null) {
          final telefono = usuario.telefono;
          final nombre = usuario.nombreApellidos;
          
          // Formatear fechas
          final inicio = '${startDate.day}/${startDate.month}/${startDate.year}';
          final fin = '${endDate.day}/${endDate.month}/${endDate.year}';
          
          // Mensaje de confirmación
          final mensaje = '''🏠 *IntelliHome - Confirmación de Reserva*

Hola $nombre,

✅ Tu reserva ha sido confirmada exitosamente.

📋 *Detalles:*
• Reserva ID: $reservationId
• Propiedad: $propertyId
• Check-in: $inicio
• Check-out: $fin

¡Esperamos que disfrutes tu estadía!

_IntelliHome Team_''';

          print('📱 [WhatsApp] Enviando mensaje a +$telefono');
          print('📝 Mensaje: $mensaje');
          
          // Aquí iría la integración real con API de WhatsApp
          // Por ahora solo simulamos el envío
          print('✅ [WhatsApp] Mensaje enviado exitosamente');
        }
      }
    } catch (e) {
      print('❌ [WhatsApp] Error al enviar mensaje: $e');
    }
  }

  /// 7. canAccessDomotics - Verifica si el status está ACTIVE y actualiza accessDomotics
  Future<ResultadoReserva> canAccessDomotics(String reservationId) async {
    try {
      final reserva = await _repositorio.buscarPorId(reservationId);
      
      if (reserva == null) {
        return ResultadoReserva.fallo(
          mensaje: 'Reserva no encontrada',
          codigoError: 'NOT_FOUND',
        );
      }

      // Verificar si el estado es ACTIVE
      final puedeAcceder = reserva.status == ReservaStatus.active;
      
      // Actualizar accessDomotics según el estado
      if (reserva.accessDomotics != puedeAcceder) {
        final reservaActualizada = reserva.copyWith(accessDomotics: puedeAcceder);
        await _repositorio.actualizarReserva(reservaActualizada);
        
        final mensaje = puedeAcceder 
            ? 'Acceso domótico activado' 
            : 'Acceso domótico desactivado (reserva no está activa)';
        
        return ResultadoReserva.exito(
          mensaje: mensaje,
          reserva: reservaActualizada,
        );
      }

      return ResultadoReserva.exito(
        mensaje: 'Estado de acceso domótico: ${puedeAcceder ? "Activo" : "Inactivo"}',
        reserva: reserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al verificar acceso domótico: ${e.toString()}',
        codigoError: 'ACCESS_ERROR',
      );
    }
  }
}
