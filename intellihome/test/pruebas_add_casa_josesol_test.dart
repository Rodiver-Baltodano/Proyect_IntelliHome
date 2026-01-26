import 'package:flutter_test/flutter_test.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/autenticacion/services/registro_casa_service.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/reservas/services/reserva_service.dart';
import 'package:intellihome/modules/reservas/services/whatsapp_service.dart';

class _FakeWhatsAppService extends WhatsAppService {
  _FakeWhatsAppService()
      : super(
          accountSid: 'TEST',
          authToken: 'TEST',
          fromNumber: 'whatsapp:+14155238886',
          countryCode: '+506',
        );

  @override
  Future<WhatsAppResult> enviarConfirmacionReserva({
    required String telefono,
    required String nombreUsuario,
    required String reservationId,
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return WhatsAppResult.success('OK (mock)', messageSid: 'TEST_SID');
  }
}

void main() {
  test('Prueba lógica: añadir casa y reservar', () async {
    print('=== PRUEBA LÓGICA: AÑADIR CASA (usuario juanperez123) ===');

    // 1) Verificar usuario existente
    final usuariosRepo = UsuarioRepositorioJson(rutaArchivo: 'usuarios_integrado.json');
    final usuario = await usuariosRepo.buscarPorIdentificador('juanperez123');

    if (usuario == null) {
      print('❌ Usuario "juanperez123" no encontrado.');
      return;
    }

    print('✅ Usuario encontrado: ${usuario.username} (id: ${usuario.id})');

    // 2) Crear servicio de registro de casa
    final casasRepo = CasaRepositorioJson(rutaArchivo: 'casas_test_josesol.json');
    final servicio = RegistroCasaServicio(repositorio: casasRepo);

    // 3) Datos de casa válidos
    final fechasNoDisponibles = [
      DateTime.now().add(const Duration(days: 5)),
      DateTime.now().add(const Duration(days: 6)),
    ];

    // 4) Registrar 3 casas
    final casasOk = <bool>[];
    for (int i = 1; i <= 3; i++) {
      final resultado = await servicio.registrarCasa(
        nombre: 'Casa de prueba $i de juanperez123',
        precioPorNoche: 45000 + (i * 1000),
        maxPersonas: 4 + i,
        habitaciones: 2,
        descripcion: 'Casa de prueba #$i para validar el flujo de registro.',
        fotos: ['foto$i.jpg'],
        ubicacion: 'San José, Costa Rica',
        reglasUso: 'No fumar\nNo fiestas',
        amenidades: [1, 2, 4, 7, 10],
        fechasNoDisponibles: fechasNoDisponibles,
      );
      if (!resultado.exitoso) {
        print('❌ Registro fallido: ${resultado.mensaje} (${resultado.campo ?? 'sin campo'})');
      }
      casasOk.add(resultado.exitoso);
    }

    if (casasOk.every((e) => e)) {
      print('✅ 3 casas registradas correctamente.');
    } else {
      print('❌ Falló el registro de alguna casa.');
    }

    // 5) Cargar casas y seleccionar una para reservar
    final casas = await casasRepo.cargarCasas();
    if (casas.isEmpty) {
      print('❌ No hay casas registradas para reservar.');
      return;
    }
    final casaParaReserva = casas.last;

    // 6) Buscar un usuario distinto para reservar
    final usuarios = await usuariosRepo.cargarUsuarios();
    final usuarioReserva = usuarios.firstWhere(
      (u) => u.id != usuario.id,
      orElse: () => usuario,
    );

    if (usuarioReserva.id == usuario.id) {
      print('❌ No se encontró un usuario distinto para la reserva.');
      return;
    }

    // 7) Crear reserva
    final reservasRepo = ReservaRepositorioJson(rutaArchivo: 'reservas_test.json');
    final reservaService = ReservaService(
      repositorio: reservasRepo,
      usuarioRepositorio: usuariosRepo,
      whatsappService: _FakeWhatsAppService(),
    );

    final resultadoReserva = await reservaService.createReservation(
      userId: usuarioReserva.id,
      propertyId: casaParaReserva.id,
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 12)),
    );

    if (resultadoReserva.exitoso) {
      print('✅ Reserva creada por ${usuarioReserva.username} en casa ${casaParaReserva.nombre}.');
    } else {
      print('❌ Reserva fallida: ${resultadoReserva.mensaje}');
    }
  });
}
