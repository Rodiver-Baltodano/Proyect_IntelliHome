import 'package:uuid/uuid.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/autenticacion/validators/validaciones_casa.dart';

class RegistroCasaServicio {
  final CasaRepositorioJson repositorio;

  RegistroCasaServicio({required this.repositorio});

  Future<bool> registrarCasa({
    required String nombre,
    required double precioPorNoche,
    required int maxPersonas,
    required int habitaciones,
    required String descripcion,
    required List<String> fotos,
    required String ubicacion,
    required List<String> reglasUso,
    required List<int> amenidades,
    required List<DateTime> fechasNoDisponibles,

  }) async {
    // VALIDACIONES
    if (!ValidacionesCasa.nombreValido(nombre)) return false;
    if (!ValidacionesCasa.precioValido(precioPorNoche)) return false;
    if (!ValidacionesCasa.personasValidas(maxPersonas)) return false;
    if (!ValidacionesCasa.habitacionesValidas(habitaciones)) return false;
    if (!ValidacionesCasa.descripcionValida(descripcion)) return false;
    if (!ValidacionesCasa.fotosValidas(fotos)) return false;
    if (!ValidacionesCasa.ubicacionValida(ubicacion)) return false;
    if (!ValidacionesCasa.reglasUsoValidas(reglasUso)) return false;
    if (!ValidacionesCasa.amenidadesValidas(amenidades)) return false;
    if (!ValidacionesCasa.fechasNoDisponiblesValidas(fechasNoDisponibles)) {
      return false;
}


    final nuevaCasa = Casa(
      id: const Uuid().v4(),
      nombre: nombre,
      precioPorNoche: precioPorNoche,
      maxPersonas: maxPersonas,
      habitaciones: habitaciones,
      descripcion: descripcion,
      fotos: fotos,
      ubicacion: ubicacion,
      reglasUso: reglasUso,
      amenidades: amenidades,
      fechaRegistro: DateTime.now(),
      fechasNoDisponibles: fechasNoDisponibles,
    );

    await repositorio.guardarCasa(nuevaCasa);
    return true;
  }}
