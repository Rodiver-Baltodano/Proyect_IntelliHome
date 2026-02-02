import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intellihome/modules/reservas/models/reserva.dart';

class ReservaAzureBlobRepository {
  final String reservasBlobSasUrl;

  ReservaAzureBlobRepository({
    required this.reservasBlobSasUrl,
  });

  Future<List<Reserva>> cargarReservas() async {
    final response = await http.get(Uri.parse(reservasBlobSasUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar reservas (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data.map((e) => Reserva.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> guardarReservas(List<Reserva> reservas) async {
    final body = const JsonEncoder.withIndent('  ')
        .convert(reservas.map((r) => r.toJson()).toList());

    final response = await http.put(
      Uri.parse(reservasBlobSasUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al guardar reservas (${response.statusCode})');
    }
  }

  Future<void> agregarOActualizarReserva(Reserva reserva) async {
    final reservas = await cargarReservas();
    final index = reservas.indexWhere((r) => r.reservationId == reserva.reservationId);
    if (index >= 0) {
      reservas[index] = reserva;
    } else {
      reservas.add(reserva);
    }
    await guardarReservas(reservas);
  }
}
