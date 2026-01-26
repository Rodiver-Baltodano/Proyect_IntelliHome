import 'package:uuid/uuid.dart';
import 'package:intellihome/modules/autenticacion/models/casa.dart';
import 'package:intellihome/modules/autenticacion/models/resultado_registro_casa.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/modules/autenticacion/validators/validaciones_casa.dart';

class RegistroCasaServicio {
  final CasaRepositorioJson repositorio;

  RegistroCasaServicio({required this.repositorio});

  Future<ResultadoRegistroCasa> registrarCasa({
    required String nombre,
    required double precioPorNoche,
    required int maxPersonas,
    required int habitaciones,
    required String descripcion,
    required List<String> fotos,
    required String ubicacion,
    required String reglasUso,
    required List<int> amenidades,
    required List<DateTime> fechasNoDisponibles,

  }) async {
    // VALIDACIONES
    if (!ValidacionesCasa.nombreValido(nombre)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'nombre',
        mensaje: 'Nombre inválido',
      );
    }
    if (!ValidacionesCasa.precioValido(precioPorNoche)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'precioPorNoche',
        mensaje: 'Precio por noche inválido',
      );
    }
    if (!ValidacionesCasa.personasValidas(maxPersonas)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'maxPersonas',
        mensaje: 'Cantidad de personas inválida',
      );
    }
    if (!ValidacionesCasa.habitacionesValidas(habitaciones)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'habitaciones',
        mensaje: 'Cantidad de habitaciones inválida',
      );
    }
    if (!ValidacionesCasa.descripcionValida(descripcion)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'descripcion',
        mensaje: 'Descripción inválida (mínimo 10 caracteres)',
      );
    }
    if (!ValidacionesCasa.fotosValidas(fotos)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'fotos',
        mensaje: 'Fotos inválidas (1 a 10 imágenes)',
      );
    }
    if (!ValidacionesCasa.ubicacionValida(ubicacion)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'ubicacion',
        mensaje: 'Ubicación inválida',
      );
    }
    if (!ValidacionesCasa.reglasUsoValidas(reglasUso)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'reglasUso',
        mensaje: 'Reglas de uso inválidas',
      );
    }
    if (!ValidacionesCasa.amenidadesValidas(amenidades)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'amenidades',
        mensaje: 'Amenidades inválidas',
      );
    }
    if (!ValidacionesCasa.fechasNoDisponiblesValidas(fechasNoDisponibles)) {
      return ResultadoRegistroCasa.fallo(
        campo: 'fechasNoDisponibles',
        mensaje: 'Fechas no disponibles inválidas',
      );
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
    return ResultadoRegistroCasa.exito(mensaje: 'Casa registrada correctamente');
  }}
