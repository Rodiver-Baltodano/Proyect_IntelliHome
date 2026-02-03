import 'package:intellihome/modules/finanzas/services/algoritmo_banquero.dart';

void main() {
  final casos = [
    {'dia': 1, 'mes': 1, 'monto': 80000.0},
    {'dia': 15, 'mes': 7, 'monto': 250000.0},
    {'dia': 31, 'mes': 12, 'monto': 50000.0},
    {'dia': 5, 'mes': 2, 'monto': 0.0},
  ];

  for (final caso in casos) {
    final resultado = AlgoritmoBanquero.calcularAjusteFinanciero(
      dia: caso['dia'] as int,
      mes: caso['mes'] as int,
      montoTotal: caso['monto'] as double,
    );

    print(
      'día=${caso['dia']}, mes=${caso['mes']}, monto=${caso['monto']} => ajuste=$resultado',
    );
  }
}