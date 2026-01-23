import 'package:intellihome/modules/reservas/models/reserva.dart';
import 'package:intellihome/modules/reservas/models/resultado_reserva.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar las operaciones de reservas
class ReservaService {
  final ReservaRepositorioJson _repositorio;
  final _uuid = const Uuid();

  ReservaService({required ReservaRepositorioJson repositorio})
      : _repositorio = repositorio;

  /// Crea una nueva reserva
  Future<ResultadoReserva> crearReserva({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
    bool accessDomotics = false,
  }) async {
    try {
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
        status: ReservaStatus.pending,
        startDate: startDate,
        endDate: endDate,
        propertyId: propertyId,
        accessDomotics: accessDomotics,
      );

      await _repositorio.agregarReserva(nuevaReserva);

      return ResultadoReserva.exito(
        mensaje: 'Reserva creada exitosamente',
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

  /// Obtiene una reserva por su ID
  Future<Reserva?> obtenerReserva(String reservationId) async {
    return await _repositorio.buscarPorId(reservationId);
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
}
