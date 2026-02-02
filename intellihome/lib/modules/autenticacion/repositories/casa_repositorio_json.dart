import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_azure_blob_repository.dart';

class CasaRepositorioJson {
  final String rutaArchivo;
  CasaAzureBlobRepository? _azureRepo;

  CasaRepositorioJson({required this.rutaArchivo});

  bool get _usarAzure {
    final casasUrl = dotenv.env['CASAS_BLOB_SAS_URL'];
    final imagesUrl = dotenv.env['IMAGES_CONTAINER_SAS_URL'];
    return casasUrl != null &&
        casasUrl.isNotEmpty &&
        imagesUrl != null &&
        imagesUrl.isNotEmpty;
  }

  CasaAzureBlobRepository _getAzureRepo() {
    if (_azureRepo != null) return _azureRepo!;
    final casasUrl = dotenv.env['CASAS_BLOB_SAS_URL'] ?? '';
    final imagesUrl = dotenv.env['IMAGES_CONTAINER_SAS_URL'] ?? '';
    _azureRepo = CasaAzureBlobRepository(
      casasBlobSasUrl: casasUrl,
      imagesContainerSasUrl: imagesUrl,
    );
    return _azureRepo!;
  }

  Future<List<Casa>> cargarCasas() async {
    if (_usarAzure) {
      return _getAzureRepo().cargarCasas();
    }
    final archivo = File(rutaArchivo);
    if (!await archivo.exists()) return [];

    final contenido = await archivo.readAsString();
    if (contenido.isEmpty) return [];

    final List<dynamic> data = jsonDecode(contenido);
    return data.map((e) => Casa.fromJson(e)).toList();
  }

  Future<Casa?> buscarPorId(String casaId) async {
    final casas = await cargarCasas();
    try {
      return casas.firstWhere((c) => c.id == casaId);
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarCasa(Casa casa) async {
    if (_usarAzure) {
      final casas = await cargarCasas();
      if (casas.any((c) => c.id == casa.id)) {
        throw StateError('Ya existe una casa con id=${casa.id}');
      }
      casas.add(casa);
      await _getAzureRepo().guardarCasas(casas);
      return;
    }
    final casas = await cargarCasas();
    casas.add(casa);

    final archivo = File(rutaArchivo);
    await archivo.parent.create(recursive: true);

    final contenido =
        const JsonEncoder.withIndent('  ').convert(casas.map((c) => c.toJson()).toList());

    await archivo.writeAsString(contenido);
  }

  Future<void> actualizarCasa(Casa casaActualizada) async {
    if (_usarAzure) {
      await _getAzureRepo().agregarOActualizarCasa(casaActualizada);
      return;
    }
    final casas = await cargarCasas();
    final index = casas.indexWhere((c) => c.id == casaActualizada.id);
    if (index == -1) {
      throw StateError('No se encontró la casa con id=${casaActualizada.id}');
    }

    casas[index] = casaActualizada;

    final archivo = File(rutaArchivo);
    await archivo.parent.create(recursive: true);

    final contenido =
        const JsonEncoder.withIndent('  ').convert(casas.map((c) => c.toJson()).toList());

    await archivo.writeAsString(contenido);
  }
}
