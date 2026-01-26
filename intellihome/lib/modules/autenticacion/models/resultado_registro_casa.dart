class ResultadoRegistroCasa {
  final bool exitoso;
  final String mensaje;
  final String? campo;

  const ResultadoRegistroCasa._({
    required this.exitoso,
    required this.mensaje,
    this.campo,
  });

  factory ResultadoRegistroCasa.exito({String mensaje = 'Registro exitoso'}) {
    return ResultadoRegistroCasa._(
      exitoso: true,
      mensaje: mensaje,
    );
  }

  factory ResultadoRegistroCasa.fallo({
    required String mensaje,
    String? campo,
  }) {
    return ResultadoRegistroCasa._(
      exitoso: false,
      mensaje: mensaje,
      campo: campo,
    );
  }
}
