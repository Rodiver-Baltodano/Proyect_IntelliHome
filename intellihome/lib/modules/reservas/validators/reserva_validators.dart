/// Validadores para el módulo de reservas
class ReservaValidators {
  /// Valida que las fechas sean correctas
  static String? validarFechas(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return 'La fecha de fin debe ser posterior a la fecha de inicio';
    }

    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'La fecha de inicio no puede ser en el pasado';
    }

    return null;
  }

  /// Valida la duración mínima de la reserva
  static String? validarDuracionMinima(DateTime startDate, DateTime endDate, {int diasMinimos = 1}) {
    final duracion = endDate.difference(startDate).inDays;
    
    if (duracion < diasMinimos) {
      return 'La reserva debe ser de al menos $diasMinimos día(s)';
    }

    return null;
  }

  /// Valida la duración máxima de la reserva
  static String? validarDuracionMaxima(DateTime startDate, DateTime endDate, {int diasMaximos = 365}) {
    final duracion = endDate.difference(startDate).inDays;
    
    if (duracion > diasMaximos) {
      return 'La reserva no puede exceder $diasMaximos días';
    }

    return null;
  }

  /// Valida que la fecha de inicio no sea muy lejana
  static String? validarFechaMaximaAnticipacion(DateTime startDate, {int diasMaximos = 365}) {
    final diasAnticipacion = startDate.difference(DateTime.now()).inDays;
    
    if (diasAnticipacion > diasMaximos) {
      return 'No se pueden hacer reservas con más de $diasMaximos días de anticipación';
    }

    return null;
  }

  /// Valida el ID de la propiedad
  static String? validarPropertyId(String? propertyId) {
    if (propertyId == null || propertyId.trim().isEmpty) {
      return 'El ID de la propiedad es requerido';
    }

    return null;
  }

  /// Valida el ID de la reserva
  static String? validarReservationId(String? reservationId) {
    if (reservationId == null || reservationId.trim().isEmpty) {
      return 'El ID de la reserva es requerido';
    }

    return null;
  }

  /// Valida todas las reglas de una reserva
  static List<String> validarReservaCompleta({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
    int diasMinimos = 1,
    int diasMaximos = 365,
  }) {
    final errores = <String>[];

    final errorPropertyId = validarPropertyId(propertyId);
    if (errorPropertyId != null) errores.add(errorPropertyId);

    final errorFechas = validarFechas(startDate, endDate);
    if (errorFechas != null) errores.add(errorFechas);

    final errorDuracionMin = validarDuracionMinima(startDate, endDate, diasMinimos: diasMinimos);
    if (errorDuracionMin != null) errores.add(errorDuracionMin);

    final errorDuracionMax = validarDuracionMaxima(startDate, endDate, diasMaximos: diasMaximos);
    if (errorDuracionMax != null) errores.add(errorDuracionMax);

    final errorAnticipacion = validarFechaMaximaAnticipacion(startDate);
    if (errorAnticipacion != null) errores.add(errorAnticipacion);

    return errores;
  }
}
