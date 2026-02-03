import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intellihome/modules/finanzas/models/pago.dart';

class PagoAzureBlobRepository {
  final String pagosBlobSasUrl;

  PagoAzureBlobRepository({
    required this.pagosBlobSasUrl,
  });

  Future<List<Pago>> cargarPagos() async {
    final response = await http.get(Uri.parse(pagosBlobSasUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar pagos (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data.map((e) => Pago.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> guardarPagos(List<Pago> pagos) async {
    final body = const JsonEncoder.withIndent('  ')
        .convert(pagos.map((p) => p.toJson()).toList());

    final response = await http.put(
      Uri.parse(pagosBlobSasUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al guardar pagos (${response.statusCode})');
    }
  }

  Future<void> agregarOActualizarPago(Pago pago) async {
    final pagos = await cargarPagos();
    final index = pagos.indexWhere((p) => p.pagoId == pago.pagoId);
    if (index >= 0) {
      pagos[index] = pago;
    } else {
      pagos.add(pago);
    }
    await guardarPagos(pagos);
  }
}
