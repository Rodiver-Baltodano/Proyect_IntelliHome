import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:path/path.dart' as p;

class CasaAzureBlobRepository {
  final String casasBlobSasUrl;
  final String imagesContainerSasUrl;

  CasaAzureBlobRepository({
    required this.casasBlobSasUrl,
    required this.imagesContainerSasUrl,
  });

  Future<List<Casa>> cargarCasas() async {
    final response = await http.get(Uri.parse(casasBlobSasUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar casas (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data.map((e) => Casa.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> guardarCasas(List<Casa> casas) async {
    final body = const JsonEncoder.withIndent('  ')
        .convert(casas.map((c) => c.toJson()).toList());

    final response = await http.put(
      Uri.parse(casasBlobSasUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al guardar casas (${response.statusCode})');
    }
  }

  Future<void> agregarOActualizarCasa(Casa casa) async {
    final casas = await cargarCasas();
    final index = casas.indexWhere((c) => c.id == casa.id);
    if (index >= 0) {
      casas[index] = casa;
    } else {
      casas.add(casa);
    }
    await guardarCasas(casas);
  }

  Future<String> subirFotoCasa({
    required String casaId,
    required int index,
    required File file,
  }) async {
    final ext = p.extension(file.path).toLowerCase();
    final safeExt = ext.isNotEmpty ? ext : '.jpg';
    final blobUrl = _buildCasaImageBlobUrl(
      casaId: casaId,
      fileName: '${casaId}_$index$safeExt',
    );
    final bytes = await file.readAsBytes();
    final contentType = safeExt == '.png' ? 'image/png' : 'image/jpeg';

    final response = await http.put(
      Uri.parse(blobUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': contentType,
      },
      body: bytes,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al subir imagen (${response.statusCode})');
    }

    return blobUrl;
  }

  String _buildCasaImageBlobUrl({
    required String casaId,
    required String fileName,
  }) {
    final uri = Uri.parse(imagesContainerSasUrl);
    final basePath = uri.path.replaceAll(RegExp(r'/+$'), '');
    final newPath = '$basePath/houses/$casaId/$fileName';
    return uri.replace(path: newPath).toString();
  }
}
