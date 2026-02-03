import 'package:flutter_test/flutter_test.dart';
import 'package:intellihome/modules/finanzas/services/algoritmo_banquero.dart';
import 'package:intellihome/modules/autenticacion/validators/validaciones_casa.dart';
import 'package:intellihome/modules/autenticacion/validators/validators.dart';
import 'package:intellihome/modules/reservas/models/reserva.dart';

void main() {
  // === Bloque 1: Algoritmo del banquero ===
  // Verifica que el cálculo financiero responda al factor temporal
  // y que respete el límite máximo definido por el algoritmo.
  group('AlgoritmoBanquero.calcularAjusteFinanciero', () {
    test('retorna un valor proporcional al factor temporal', () {
      final resultado = AlgoritmoBanquero.calcularAjusteFinanciero(
        dia: 10,
        mes: 2,
        montoTotal: 1000,
      );

      // Se usa closeTo porque el cálculo involucra divisiones y decimales,
      // por lo que pueden existir pequeñas variaciones de precisión.
      expect(resultado, closeTo(0.008664, 0.0001));
    });

    test('aplica el límite máximo cuando lo supera', () {
      final resultado = AlgoritmoBanquero.calcularAjusteFinanciero(
        dia: 31,
        mes: 12,
        montoTotal: 0.1,
      );

      expect(resultado, closeTo(0.01, 0.0001));
    });
  });

  // === Bloque 2: Validaciones de casas ===
  // Se valida la longitud mínima de la descripción.
  group('ValidacionesCasa.descripcionValida', () {
    test('acepta descripciones con longitud suficiente', () {
      final resultado = ValidacionesCasa.descripcionValida(
        'Descripción válida con más de diez caracteres',
      );

      expect(resultado, isTrue);
    });

    test('rechaza descripciones demasiado cortas', () {
      final resultado = ValidacionesCasa.descripcionValida('Muy corta');

      expect(resultado, isFalse);
    });
  });

  // Se valida el rango permitido de cantidad de fotos.
  group('ValidacionesCasa.fotosValidas', () {
    test('acepta entre 1 y 10 fotos', () {
      final resultado = ValidacionesCasa.fotosValidas(['a.jpg', 'b.jpg']);

      expect(resultado, isTrue);
    });

    test('rechaza más de 10 fotos', () {
      final resultado = ValidacionesCasa.fotosValidas(
        List.generate(11, (index) => 'foto_$index.jpg'),
      );

      expect(resultado, isFalse);
    });
  });

  // === Bloque 3: Validaciones de autenticación ===
  // Se prueba el formato correcto de correo electrónico.
  group('ValidacionesAutenticacion.esEmailValido', () {
    test('acepta un correo bien formado', () {
      final resultado =
          ValidacionesAutenticacion.esEmailValido('user@test.com');

      expect(resultado, isTrue);
    });

    test('rechaza un correo inválido', () {
      final resultado =
          ValidacionesAutenticacion.esEmailValido('correo-invalido');

      expect(resultado, isFalse);
    });
  });

  // === Bloque 4: Modelo de reservas ===
  // Se valida que copyWith solo reemplace los campos enviados.
  group('Reserva.copyWith', () {
    test('actualiza solo los campos enviados', () {
      final reserva = Reserva(
        reservationId: 'r1',
        userId: 'u1',
        status: ReservaStatus.pending,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
        propertyId: 'p1',
        nombreCasa: 'Casa Uno',
      );

      final actualizada = reserva.copyWith(status: ReservaStatus.confirmed);

      expect(actualizada.status, ReservaStatus.confirmed);
      expect(actualizada.userId, reserva.userId);
      expect(actualizada.propertyId, reserva.propertyId);
    });

    test('mantiene valores originales si no se pasan cambios', () {
      final reserva = Reserva(
        reservationId: 'r2',
        userId: 'u2',
        status: ReservaStatus.pending,
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 12),
        propertyId: 'p2',
        nombreCasa: 'Casa Dos',
      );

      final copia = reserva.copyWith();

      expect(copia.reservationId, reserva.reservationId);
      expect(copia.status, reserva.status);
      expect(copia.nombreCasa, reserva.nombreCasa);
    });
  });
}
