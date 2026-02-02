import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> cargarUsuarios() async {
  final response = await http.get(Uri.parse('https://intellihomestorage.blob.core.windows.net/data/users.json?sp=r&st=2026-02-02T02:19:00Z&se=2026-02-02T10:34:00Z&spr=https&sv=2024-11-04&sr=b&sig=KDAeNXZ6f9OvM40BFmrb%2BHU85oZI9sWlZmJoBqKUFRs%3D'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Error al cargar usuarios');
  }
}

Future<void> comprobarImagen() async {
  const imageUrl = 'https://intellihomestorage.blob.core.windows.net/images/casas/IntelliHomeLogo.png?sp=r&st=2026-02-02T02:30:02Z&se=2026-02-02T10:45:02Z&spr=https&sv=2024-11-04&sr=b&sig=ivap2Hra6iNDc5yltVchNRd34P6dGasnl04ngKB6oEY%3D';
  if (imageUrl == 'PEGA_AQUI_LA_URL_DEL_BLOB') {
    print('Debes reemplazar la URL de la imagen antes de ejecutar.');
    return;
  }

  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    print('Imagen OK. Bytes: ${response.bodyBytes.length}');
  } else {
    print('Error al descargar imagen. Status: ${response.statusCode}');
  }
}

Future<void> main() async {
  try {
    final usuarios = await cargarUsuarios();
    print('Usuarios cargados: ${usuarios.length}');
    print('Datos:');
    print(const JsonEncoder.withIndent('  ').convert(usuarios));
    await comprobarImagen();
  } catch (e) {
    print('Fallo al ejecutar: $e');
  }
}