import 'dart:convert';
import 'dart:io';
import 'package:intellihome/modules/autenticacion/models/casa.dart';

class CasaRepositorioJson {
  final String rutaArchivo;

  CasaRepositorioJson({required this.rutaArchivo});

  Future<List<Casa>> cargarCasas() async {
    final archivo = File(rutaArchivo);
    if (!await archivo.exists()) return [];

    final contenido = await archivo.readAsString();
    if (contenido.isEmpty) return [];

    final List<dynamic> data = jsonDecode(contenido);
    return data.map((e) => Casa.fromJson(e)).toList();
  }

  Future<void> guardarCasa(Casa casa) async {
    final casas = await cargarCasas();
    casas.add(casa);

    final archivo = File(rutaArchivo);
    await archivo.parent.create(recursive: true);

    final contenido =
        const JsonEncoder.withIndent('  ').convert(casas.map((c) => c.toJson()).toList());

    await archivo.writeAsString(contenido);
  }
}
