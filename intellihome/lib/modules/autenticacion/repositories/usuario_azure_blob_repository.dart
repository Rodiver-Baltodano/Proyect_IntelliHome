import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intellihome/modules/autenticacion/models/usuario.dart';

class UsuarioAzureBlobRepository {
  final String usersBlobSasUrl;
  final String imagesContainerSasUrl;

  UsuarioAzureBlobRepository({
    required this.usersBlobSasUrl,
    required this.imagesContainerSasUrl,
  });

  Future<List<Usuario>> cargarUsuarios() async {
    final response = await http.get(Uri.parse(usersBlobSasUrl));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar usuarios (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> guardarUsuarios(List<Usuario> usuarios) async {
    final body = const JsonEncoder.withIndent('  ')
        .convert(usuarios.map((u) => u.toJson()).toList());

    final response = await http.put(
      Uri.parse(usersBlobSasUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al guardar usuarios (${response.statusCode})');
    }
  }

  Future<void> agregarOActualizarUsuario(Usuario usuario) async {
    final usuarios = await cargarUsuarios();
    final index = usuarios.indexWhere((u) => u.id == usuario.id);
    if (index >= 0) {
      usuarios[index] = usuario;
    } else {
      usuarios.add(usuario);
    }
    await guardarUsuarios(usuarios);
  }

  Future<String> subirFotoPerfil({
    required String userId,
    required File file,
  }) async {
    final blobUrl = _buildImageBlobUrl(userId);
    final bytes = await file.readAsBytes();

    final response = await http.put(
      Uri.parse(blobUrl),
      headers: {
        'x-ms-blob-type': 'BlockBlob',
        'Content-Type': 'image/jpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al subir imagen (${response.statusCode})');
    }

    return blobUrl;
  }

  String _buildImageBlobUrl(String userId) {
    final uri = Uri.parse(imagesContainerSasUrl);
    final basePath = uri.path.replaceAll(RegExp(r'/+$'), '');
    final newPath = '$basePath/users/$userId.jpg';
    return uri.replace(path: newPath).toString();
  }
}
