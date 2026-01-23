# Módulo de Reservas - IntelliHome

## Descripción

Módulo completo para gestionar reservas de propiedades en IntelliHome, siguiendo la arquitectura existente del proyecto.

## Estructura del Módulo

```
lib/modules/reservas/
├── reservas.dart                      # Archivo barrel (exports)
├── models/
│   ├── reserva.dart                   # Modelo de Reserva
│   └── resultado_reserva.dart         # Resultado de operaciones
├── repositories/
│   └── reserva_repository.dart        # Persistencia en JSON
├── services/
│   └── reserva_service.dart           # Lógica de negocio
└── validators/
    └── reserva_validators.dart        # Validaciones
```

## Formato JSON

Las reservas se guardan en formato JSON con la siguiente estructura:

```json
{
  "reservationId": "uuid-v4",
  "status": "PENDING|CONFIRMED|CANCELLED|COMPLETED",
  "startDate": "2026-02-15T15:00:00.000Z",
  "endDate": "2026-02-20T11:00:00.000Z",
  "propertyId": "casa-playa-001",
  "accessDomotics": false
}
```

### Estados de Reserva

- **PENDING**: Reserva creada, pendiente de confirmación
- **CONFIRMED**: Reserva confirmada
- **CANCELLED**: Reserva cancelada
- **COMPLETED**: Reserva completada (check-out realizado)


### 1. Inicializar el Repositorio

```dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intellihome/modules/reservas/reservas.dart';

// En tu aplicación:
final appDir = await getApplicationDocumentsDirectory();
final rutaJson = p.join(appDir.path, 'reservas.json');
final repositorio = ReservaRepositorioJson(rutaArchivo: rutaJson);
```

### 2. Crear el Servicio

```dart
final reservaService = ReservaService(repositorio: repositorio);
```

### 3. Crear una Reserva

```dart
final resultado = await reservaService.crearReserva(
  propertyId: 'casa-playa-001',
  startDate: DateTime(2026, 3, 15, 15, 0),
  endDate: DateTime(2026, 3, 20, 11, 0),
  accessDomotics: false,
);

if (resultado.exitoso) {
  print('Reserva creada: ${resultado.reserva?.reservationId}');
} else {
  print('Error: ${resultado.mensaje}');
}
```

### 4. Confirmar una Reserva

```dart
final resultado = await reservaService.confirmarReserva(reservationId);

if (resultado.exitoso) {
  print('Reserva confirmada exitosamente');
}
```

### 5. Verificar Disponibilidad

```dart
final disponible = await reservaService.verificarDisponibilidad(
  propertyId: 'casa-playa-001',
  startDate: DateTime(2026, 3, 15),
  endDate: DateTime(2026, 3, 20),
);

if (disponible) {
  print('Propiedad disponible');
} else {
  print('Propiedad no disponible en esas fechas');
}
```

### 6. Obtener Reservas de una Propiedad

```dart
final reservas = await reservaService.obtenerReservasPorPropiedad('casa-playa-001');

for (var reserva in reservas) {
  print('Reserva: ${reserva.reservationId} - ${reserva.status}');
}
```

### 7. Cancelar una Reserva

```dart
final resultado = await reservaService.cancelarReserva(reservationId);

if (resultado.exitoso) {
  print('Reserva cancelada');
}
```

### 8. Actualizar Acceso Domótico

```dart
final resultado = await reservaService.actualizarAccesoDomotico(
  reservationId: reservationId,
  accessDomotics: true,
);
```

## Validaciones

El módulo incluye validadores completos:

```dart
import 'package:intellihome/modules/reservas/validators/reserva_validators.dart';

// Validar fechas
final errorFechas = ReservaValidators.validarFechas(startDate, endDate);

// Validar duración mínima
final errorDuracion = ReservaValidators.validarDuracionMinima(
  startDate, 
  endDate, 
  diasMinimos: 2
);

// Validar todas las reglas
final errores = ReservaValidators.validarReservaCompleta(
  propertyId: 'casa-001',
  startDate: startDate,
  endDate: endDate,
  diasMinimos: 1,
  diasMaximos: 365,
);

if (errores.isEmpty) {
  print('Validación exitosa');
} else {
  print('Errores: ${errores.join(', ')}');
}
```


### Operaciones Disponibles

```dart
// Cargar todas las reservas
final reservas = await repositorio.cargarReservas();

// Buscar por ID
final reserva = await repositorio.buscarPorId(reservationId);

// Obtener por propiedad
final reservasProp = await repositorio.obtenerPorPropiedad(propertyId);

// Obtener por estado
final reservasPendientes = await repositorio.obtenerPorEstado('PENDING');

// Obtener reservas activas (PENDING o CONFIRMED)
final activas = await repositorio.obtenerReservasActivas(propertyId);

// Agregar reserva
await repositorio.agregarReserva(nuevaReserva);

// Actualizar reserva
await repositorio.actualizarReserva(reservaActualizada);

// Eliminar reserva
await repositorio.eliminarReserva(reservationId);

// Confirmar reserva
await repositorio.confirmarReserva(reservationId);

// Cancelar reserva
await repositorio.cancelarReserva(reservationId);

// Verificar conflictos de fechas
final tieneConflicto = await repositorio.tieneConflictoFechas(
  propertyId: propertyId,
  startDate: startDate,
  endDate: endDate,
);
```

### En main.dart

```dart
import 'package:intellihome/modules/reservas/reservas.dart';

// Inicializar repositorio al inicio
ReservaRepositorioJson? _reservaRepo;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final appDir = await getApplicationDocumentsDirectory();
    final rutaJson = p.join(appDir.path, 'reservas.json');
    _reservaRepo = ReservaRepositorioJson(rutaArchivo: rutaJson);
  });
}
```

### Provider (Opcional)

Si deseas usar Provider para el state management:

```dart
class ReservaProvider extends ChangeNotifier {
  final ReservaService _service;
  List<Reserva> _reservas = [];
  
  ReservaProvider(this._service);
  
  List<Reserva> get reservas => _reservas;
  
  Future<void> cargarReservas() async {
    _reservas = await _service.obtenerTodasLasReservas();
    notifyListeners();
  }
  
  Future<ResultadoReserva> crearReserva({...}) async {
    final resultado = await _service.crearReserva(...);
    if (resultado.exitoso) {
      await cargarReservas();
    }
    return resultado;
  }
}
```

## Características

✅ Persistencia en JSON local  
✅ Validación de disponibilidad (no permite solapamiento de fechas)  
✅ Gestión de estados (PENDING, CONFIRMED, CANCELLED, COMPLETED)  
✅ Control de acceso domótico  
✅ Validadores robustos  
✅ Manejo de errores completo  
✅ Logs informativos  
✅ API intuitiva y consistente con el módulo de autenticación  

## Ejemplo Completo

Ver `reservas_ejemplo.json` para un ejemplo de estructura de datos.