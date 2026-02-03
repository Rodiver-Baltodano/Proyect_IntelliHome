class AlgoritmoBanquero {
  /// Calcula el valor de ajuste financiero usando el algoritmo definido.
  ///
  /// Entradas:
  /// - [dia]: día del mes (entero)
  /// - [mes]: mes (entero)
  /// - [montoTotal]: monto total (decimal)
  ///
  /// Constantes internas:
  /// - IVA = 0.13
  /// - Comisión = 0.05
  static double calcularAjusteFinanciero({
    required int dia,
    required int mes,
    required double montoTotal,
  }) {
    const double porcentajeImpuesto = 0.13;
    const double comision = 0.05;

    final double limiteMaximo = 0.10 * montoTotal;

    final double mediaArmonica =
        (porcentajeImpuesto + comision) > 0
            ? 2 / ((1 / porcentajeImpuesto) + (1 / comision))
            : 0;

    final double factorAjuste = (dia + mes) / 100;
    double mediaAjustada = mediaArmonica * factorAjuste;

    if (mediaAjustada > limiteMaximo) {
      mediaAjustada = limiteMaximo;
    }

    return mediaAjustada;
  }
}
