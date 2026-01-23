/// Resultado de una operación de reserva
class ResultadoReserva {
  /// Indica si la operación fue exitosa
  final bool exitoso;

  /// Mensaje descriptivo del resultado
  final String mensaje;

  /// La reserva creada o modificada (si la operación fue exitosa)
  final Reserva? reserva;

  /// Código de error opcional
  final String? codigoError;

  ResultadoReserva({
    required this.exitoso,
    required this.mensaje,
    this.reserva,
    this.codigoError,
  });

  /// Constructor para resultado exitoso
  factory ResultadoReserva.exito({
    required String mensaje,
    Reserva? reserva,
  }) {
    return ResultadoReserva(
      exitoso: true,
      mensaje: mensaje,
      reserva: reserva,
    );
  }

  /// Constructor para resultado fallido
  factory ResultadoReserva.fallo({
    required String mensaje,
    String? codigoError,
  }) {
    return ResultadoReserva(
      exitoso: false,
      mensaje: mensaje,
      codigoError: codigoError,
    );
  }

  @override
  String toString() {
    return 'ResultadoReserva(exitoso: $exitoso, mensaje: $mensaje, '
        'reserva: ${reserva?.reservationId ?? "null"})';
  }
}
