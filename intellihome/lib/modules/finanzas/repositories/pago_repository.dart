import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellihome/modules/finanzas/models/pago.dart';
import 'package:intellihome/modules/finanzas/repositories/pago_azure_blob_repository.dart';

class PagoRepositorioJson {
  final String rutaArchivo;
  PagoAzureBlobRepository? _azureRepo;

  PagoRepositorioJson({required this.rutaArchivo});

  bool get _usarAzure {
    final pagosUrl = dotenv.env['PAGOS_BLOB_SAS_URL'];
    return pagosUrl != null && pagosUrl.isNotEmpty;
  }

  PagoAzureBlobRepository _getAzureRepo() {
    if (_azureRepo != null) return _azureRepo!;
    final pagosUrl = dotenv.env['PAGOS_BLOB_SAS_URL'] ?? '';
    _azureRepo = PagoAzureBlobRepository(pagosBlobSasUrl: pagosUrl);
    return _azureRepo!;
  }

  Future<List<Pago>> cargarPagos() async {
    if (_usarAzure) {
      return _getAzureRepo().cargarPagos();
    }
    final archivo = File(rutaArchivo);
    if (!await archivo.exists()) return [];

    final contenido = await archivo.readAsString();
    if (contenido.trim().isEmpty) return [];

    final dynamic data = jsonDecode(contenido);
    if (data is! List) return [];
    return data.map((e) => Pago.fromJson(e)).toList();
  }

  Future<void> guardarPagos(List<Pago> pagos) async {
    if (_usarAzure) {
      await _getAzureRepo().guardarPagos(pagos);
      return;
    }
    final archivo = File(rutaArchivo);
    await archivo.parent.create(recursive: true);
    final contenido = const JsonEncoder.withIndent('  ')
        .convert(pagos.map((p) => p.toJson()).toList());
    await archivo.writeAsString(contenido);
  }

  Future<void> agregarPago(Pago pago) async {
    if (_usarAzure) {
      await _getAzureRepo().agregarOActualizarPago(pago);
      return;
    }
    final pagos = await cargarPagos();
    if (pagos.any((p) => p.pagoId == pago.pagoId)) {
      throw StateError('Ya existe un pago con id=${pago.pagoId}');
    }
    pagos.add(pago);
    await guardarPagos(pagos);
  }
}
