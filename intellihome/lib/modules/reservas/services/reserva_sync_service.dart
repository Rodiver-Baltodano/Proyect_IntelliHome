import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/reservas/services/reserva_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReservaSyncService {
  Future<void> activarReservasPendientesHoy() async {
    final appDir = await getApplicationDocumentsDirectory();
    final reservasPath = p.join(appDir.path, 'reservas_integrado.json');
    final reservasRepo = ReservaRepositorioJson(rutaArchivo: reservasPath);
    final service = ReservaService(repositorio: reservasRepo);
    await service.activateReservationsByDate();
  }
}
