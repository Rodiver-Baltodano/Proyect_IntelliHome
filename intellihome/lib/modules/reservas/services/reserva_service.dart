import 'package:intellihome/modules/reservas/models/reserva.dart';
import 'package:intellihome/modules/reservas/models/resultado_reserva.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/reservas/services/whatsapp_service.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar las operaciones de reservas
class ReservaService {
  final ReservaRepositorioJson _repositorio;
  final UsuarioRepositorioJson? _usuarioRepositorio;
  final CasaRepositorioJson? _casaRepositorio;
  final WhatsAppService _whatsappService;
  final _uuid = const Uuid();

  ReservaService({
    required ReservaRepositorioJson repositorio,
    UsuarioRepositorioJson? usuarioRepositorio,
    CasaRepositorioJson? casaRepositorio,
    WhatsAppService? whatsappService,
  })  : _repositorio = repositorio,
        _usuarioRepositorio = usuarioRepositorio,
        _casaRepositorio = casaRepositorio,
        _whatsappService = whatsappService ?? WhatsAppService();

  ///  Crear una reserva válida según fechas
  Future<ResultadoReserva> createReservation({
    required String userId,
    required String propertyId,
    required String nombreCasa,
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

        // Validar que tenga método de pago (solo tarjeta)
        final tieneMetodoPago = usuario.datosTargeta != null;
        
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

      final hoy = DateTime.now();
      final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
      final inicioSinHora = DateTime(startDate.year, startDate.month, startDate.day);
      if (inicioSinHora.isBefore(hoySinHora)) {
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
        nombreCasa: nombreCasa,
        accessDomotics: false,
      );

      await _repositorio.agregarReserva(nuevaReserva);

      // Enviar WhatsApp de confirmación
      await sendWhatsapp(
        userId: userId,
        reservationId: nuevaReserva.reservationId,
        propertyId: propertyId,
        nombreCasa: nombreCasa,
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

  /// Envía notificación de incendio solo si la reserva está activa
  Future<ResultadoReserva> enviarNotificacionIncendio(String reservationId) async {
    try {
      final reserva = await _repositorio.buscarPorId(reservationId);
      
      if (reserva == null) {
        return ResultadoReserva.fallo(
          mensaje: 'Reserva no encontrada',
          codigoError: 'RESERVATION_NOT_FOUND',
        );
      }

      // Obtener información del usuario y la casa para enviar la notificación
      if (_usuarioRepositorio != null && _casaRepositorio != null) {
        final usuario = await _usuarioRepositorio.buscarPorId(reserva.userId);
        final casa = await _casaRepositorio.buscarPorId(reserva.propertyId);
        
        if (usuario != null && casa != null) {
          await _whatsappService.enviarNotificacionIncendio(
            propertyId: reserva.propertyId,
            horadesatre: DateTime.now(),
            nombreUsuario: usuario.username,
            telefono: usuario.telefono,
            nombreCasa: casa.nombre,
          );
        }
      }

      return ResultadoReserva.exito(
        mensaje: 'Notificación de incendio enviada exitosamente',
        reserva: reserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al enviar notificación de incendio: ${e.toString()}',
        codigoError: 'NOTIFICATION_ERROR',
      );
    }
  }

  /// Envía notificación de sismo solo si la reserva está activa
  Future<ResultadoReserva> enviarNotificacionSismo(String reservationId) async {
    try {
      final reserva = await _repositorio.buscarPorId(reservationId);
      
      if (reserva == null) {
        return ResultadoReserva.fallo(
          mensaje: 'Reserva no encontrada',
          codigoError: 'RESERVATION_NOT_FOUND',
        );
      }

      // Obtener información del usuario y la casa para enviar la notificación
      if (_usuarioRepositorio != null && _casaRepositorio != null) {
        final usuario = await _usuarioRepositorio.buscarPorId(reserva.userId);
        final casa = await _casaRepositorio.buscarPorId(reserva.propertyId);
        
        if (usuario != null && casa != null) {
          await _whatsappService.enviarNotificacionSismo(
            propertyId: reserva.propertyId,
            horadesatre: DateTime.now(),
            nombreUsuario: usuario.username,
            telefono: usuario.telefono,
            nombreCasa: casa.nombre,
          );
        }
      }

      return ResultadoReserva.exito(
        mensaje: 'Notificación de sismo enviada exitosamente',
        reserva: reserva,
      );
    } catch (e) {
      return ResultadoReserva.fallo(
        mensaje: 'Error al enviar notificación de sismo: ${e.toString()}',
        codigoError: 'NOTIFICATION_ERROR',
      );
    }
  }

  /// Obtener una reserva específica
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

  /// Activar reservas cuando llega su fecha de inicio
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
            print('[Reservas] Reserva ${reserva.reservationId} activada - Acceso domótico habilitado');
          }
        }
      }

      return reservasActivadas;
    } catch (e) {
      print('[Reservas] Error al activar reservas: $e');
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
            print('[Reservas] Reserva ${reserva.reservationId} finalizada');
          }
        }
      }

      return reservasFinalizadas;
    } catch (e) {
      print('[Reservas] Error al finalizar reservas: $e');
      return [];
    }
  }

  /// Envía mensaje de WhatsApp de confirmación usando Twilio API
  Future<bool> sendWhatsapp({
    required String userId,
    required String reservationId,
    required String propertyId,
    required String nombreCasa,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_usuarioRepositorio != null) {
        final usuario = await _usuarioRepositorio.buscarPorId(userId);
        
        if (usuario != null) {
          final telefono = usuario.telefono;
          final nombre = usuario.nombreApellidos;
          
          print('[WhatsApp] Enviando confirmación a +$telefono');
          
          // Enviar mensaje usando Twilio API
          final casaNombre = await _casaRepositorio?.buscarPorId(propertyId);
          final nombrePropiedad = casaNombre?.nombre ?? propertyId;

          final resultado = await _whatsappService.enviarConfirmacionReserva(
            telefono: telefono,
            nombreUsuario: nombre,
            reservationId: reservationId,
            propertyName: nombrePropiedad,
            envio: DateTime.now(),
            startDate: startDate,
            endDate: endDate,
          );

          if (resultado.success) {
            print('[WhatsApp] Mensaje enviado exitosamente');
            print('[WhatsApp] SID: ${resultado.messageSid}');
            return true;
          } else {
            print('[WhatsApp] Error: ${resultado.message}');
            return false;
          }
        } else {
          print('[WhatsApp] Usuario no encontrado');
          return false;
        }
      } else {
        print('[WhatsApp] Repositorio de usuarios no disponible');
        return false;
      }
    } catch (e) {
      print('[WhatsApp] Error al enviar mensaje: $e');
      return false;
    }
  }

  ///  Verifica si el status está ACTIVE y actualiza accessDomotics
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
