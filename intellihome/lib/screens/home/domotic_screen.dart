import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/modules/autenticacion/services/tcp_client.dart';
import 'package:intellihome/modules/reservas/services/reserva_service.dart';
import 'package:intellihome/modules/reservas/repositories/reserva_repository.dart';
import 'package:intellihome/modules/reservas/models/reserva.dart';
import 'package:intellihome/modules/autenticacion/repositories/usuario_repository.dart';
import 'package:intellihome/modules/autenticacion/repositories/casa_repositorio_json.dart';
import 'package:intellihome/session/session_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'dart:io';

class DomoticScreen extends StatefulWidget {
  const DomoticScreen({super.key});

  @override
  State<DomoticScreen> createState() => _DomoticScreenState();
}

class _DomoticScreenState extends State<DomoticScreen> {
  final TcpClient _tcpClient = TcpClient(); // Singleton - siempre la misma instancia
  bool _isConnected = false;
  bool _flameDetected = false;
  bool _shockDetected = false;
  bool _puertaAbierta = false; // Inicia cerrada (0°)
  bool _garajeAbierto = false; // Inicia cerrado (90°)

  // Servicio de reservas para notificaciones
  ReservaService? _reservaService;
  String? _reservaActiva;

  // Control de notificaciones enviadas
  bool _notificacionIncendioEnviada = false;
  bool _notificacionSismoEnviada = false;

  // Mapeo de habitaciones a pines GPIO
  final Map<String, int> _roomToPinMap = {
    'garaje': 1, // GP1
    'sala': 2, // GP2
    'cocina': 3, // GP3
    'bano1': 4, // GP4
    'bano2': 5, // GP5
    'cuarto1': 6, // GP6
    'cuarto2': 7, // GP7
    'cuarto3': 8, // GP8
  };

  // Estados de las luces por habitación
  Map<String, bool> lightStates = {
    'garaje': false,
    'sala': false,
    'cocina': false,
    'bano1': false,
    'bano2': false,
    'cuarto1': false,
    'cuarto2': false,
    'cuarto3': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupTcpCallbacks();
    _connectToRaspberryPi();
  }

  /// VERSIÓN MEJORADA - Inicialización robusta del servicio de reservas
    Future<void> _initializeServices() async {
    try {
      debugPrint('🔄 [INIT] Iniciando servicios de notificación...');

      // 1. Verificar usuario actual
      final userId = SessionManager.currentUserId;
      debugPrint('👤 [INIT] Usuario actual: ${userId ?? "NO AUTENTICADO"}');

      if (userId == null) {
        debugPrint(
          '⚠️ [INIT] No hay usuario autenticado - notificaciones deshabilitadas',
        );
        return;
      }

      // 2. Obtener directorio de documentos de la app
      final appDir = await getApplicationDocumentsDirectory();
      debugPrint('📁 [INIT] Directorio de la app: ${appDir.path}');

      // 3. Definir rutas de archivos
      final usuariosPath = p.join(appDir.path, 'usuarios_integrado.json');
      final casasPath = p.join(appDir.path, 'casas_integrado.json');
      final reservasPath = p.join(appDir.path, 'reservas_integrado.json');

      debugPrint('📂 [INIT] Rutas de archivos:');
      debugPrint('  - Usuarios: $usuariosPath');
      debugPrint('  - Casas: $casasPath');
      debugPrint('  - Reservas: $reservasPath');

      // 4. CAMBIO IMPORTANTE: Verificar si está usando Azure
      final usandoAzure = dotenv.env['RESERVAS_BLOB_SAS_URL']?.isNotEmpty ?? false;
      
      if (usandoAzure) {
        debugPrint('☁️ [INIT] Modo Azure Blob Storage detectado');
        debugPrint('✅ [INIT] No se requieren archivos JSON locales');
      } else {
        debugPrint('💾 [INIT] Modo JSON local detectado');
        
        // Verificar existencia de archivos solo si NO está usando Azure
        final usuariosFile = File(usuariosPath);
        final casasFile = File(casasPath);
        final reservasFile = File(reservasPath);

        bool todosExisten = true;

        if (!await usuariosFile.exists()) {
          debugPrint('❌ [INIT] Archivo de usuarios NO ENCONTRADO: $usuariosPath');
          todosExisten = false;
        } else {
          debugPrint('✅ [INIT] Archivo de usuarios encontrado');
        }

        if (!await casasFile.exists()) {
          debugPrint('❌ [INIT] Archivo de casas NO ENCONTRADO: $casasPath');
          todosExisten = false;
        } else {
          debugPrint('✅ [INIT] Archivo de casas encontrado');
        }

        if (!await reservasFile.exists()) {
          debugPrint('❌ [INIT] Archivo de reservas NO ENCONTRADO: $reservasPath');
          debugPrint(
            '💡 [INIT] Verifica que el archivo exista en el directorio de documentos',
          );
          todosExisten = false;
        } else {
          debugPrint('✅ [INIT] Archivo de reservas encontrado');
        }

        if (!todosExisten) {
          debugPrint(
            '❌ [INIT] Faltan archivos requeridos - abortando inicialización',
          );
          return;
        }

        debugPrint('✅ [INIT] Todos los archivos encontrados correctamente');
      }

      // 5. Inicializar repositorios (funcionan tanto con JSON como Azure)
      debugPrint('🔧 [INIT] Inicializando repositorios...');
      final reservaRepo = ReservaRepositorioJson(rutaArchivo: reservasPath);
      final usuarioRepo = UsuarioRepositorioJson(rutaArchivo: usuariosPath);
      final casaRepo = CasaRepositorioJson(rutaArchivo: casasPath);

      // 6. Inicializar servicio con todos los repositorios
      debugPrint('🔧 [INIT] Creando servicio de reservas...');
      _reservaService = ReservaService(
        repositorio: reservaRepo,
        usuarioRepositorio: usuarioRepo,
        casaRepositorio: casaRepo,
      );

      debugPrint('✅ [INIT] Servicio de reservas inicializado correctamente');

      // 7. Buscar reservas del usuario
      debugPrint('🔍 [INIT] Buscando reservas del usuario $userId...');
      
      List<Reserva> reservas;
      try {
        reservas = await reservaRepo.obtenerPorUsuario(userId);
        debugPrint('📋 [INIT] Reservas encontradas: ${reservas.length}');
      } catch (e) {
        debugPrint('❌ [INIT] Error al cargar reservas: $e');
        debugPrint('💡 [INIT] Continuando sin reservas...');
        reservas = [];
      }

      if (reservas.isEmpty) {
        debugPrint('⚠️ [INIT] El usuario no tiene reservas registradas');
        debugPrint(
          '💡 [INIT] El servicio está inicializado pero no hay reserva activa',
        );
        return;
      }

      // 8. Mostrar todas las reservas encontradas
      debugPrint('📋 [INIT] Listado de reservas:');
      for (var i = 0; i < reservas.length; i++) {
        final r = reservas[i];
        debugPrint('  ${i + 1}. Reserva ${r.reservationId}');
        debugPrint('     Status: ${r.status}');
        debugPrint('     Casa: ${r.nombreCasa}');
        debugPrint('     Fechas: ${r.startDate} - ${r.endDate}');
      }

      // 9. Seleccionar reserva activa (prioridad: ACTIVE > CONFIRMED > PENDING > primera disponible)
      debugPrint('🔍 [INIT] Seleccionando reserva activa...');

      var reservaSeleccionada = reservas
          .where((r) => r.status == ReservaStatus.active)
          .firstOrNull;

      if (reservaSeleccionada == null) {
        debugPrint('⚠️ [INIT] No hay reserva ACTIVE, buscando CONFIRMED...');
        reservaSeleccionada = reservas
            .where((r) => r.status == ReservaStatus.confirmed)
            .firstOrNull;
      }

      if (reservaSeleccionada == null) {
        debugPrint('⚠️ [INIT] No hay reserva CONFIRMED, buscando PENDING...');
        reservaSeleccionada = reservas
            .where((r) => r.status == ReservaStatus.pending)
            .firstOrNull;
      }

      if (reservaSeleccionada == null) {
        debugPrint(
          '⚠️ [INIT] No hay reserva con estado válido, usando la primera disponible...',
        );
        reservaSeleccionada = reservas.firstOrNull;
      }

      // 10. Guardar reserva seleccionada
      if (reservaSeleccionada != null) {
        if (mounted) {
          setState(() {
            _reservaActiva = reservaSeleccionada!.reservationId;
          });
        }

        debugPrint('✅ [INIT] ══════════════════════════════════════════');
        debugPrint('✅ [INIT] RESERVA SELECCIONADA EXITOSAMENTE');
        debugPrint('✅ [INIT] ID: ${reservaSeleccionada.reservationId}');
        debugPrint('✅ [INIT] Status: ${reservaSeleccionada.status}');
        debugPrint('✅ [INIT] Casa: ${reservaSeleccionada.nombreCasa}');
        debugPrint('✅ [INIT] Usuario: ${reservaSeleccionada.userId}');
        debugPrint('🔔 [INIT] NOTIFICACIONES DE EMERGENCIA: HABILITADAS');
        debugPrint('✅ [INIT] ══════════════════════════════════════════');

        if (reservaSeleccionada.status != ReservaStatus.active) {
          debugPrint(
            '⚠️ [INIT] NOTA: La reserva no está ACTIVE (está ${reservaSeleccionada.status})',
          );
          debugPrint(
            '⚠️ [INIT] Las notificaciones de emergencia funcionarán de todas formas',
          );
        }
      } else {
        debugPrint('❌ [INIT] No se pudo seleccionar ninguna reserva');
        debugPrint(
          '💡 [INIT] El servicio está disponible pero no hay reserva activa',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [INIT] ══════════════════════════════════════════');
      debugPrint('❌ [INIT] ERROR CRÍTICO EN INICIALIZACIÓN');
      debugPrint('❌ [INIT] Error: $e');
      debugPrint('❌ [INIT] ══════════════════════════════════════════');
      debugPrint('Stack trace completo:');
      debugPrint('$stackTrace');
      debugPrint('══════════════════════════════════════════');
    }
  }

  void _setupTcpCallbacks() {
    // Configurar callbacks del TCP client
    _tcpClient.onDisconnected = () {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    };

    _tcpClient.onError = (error) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    };

    // Callback para recibir mensajes del servidor (datos de sensores)
    _tcpClient.onMessageReceived = (message) {
      if (mounted) {
        _processSensorData(message);
      }
    };
  }

  void _processSensorData(String message) {
    // Formato esperado: "SENSOR:flame:true,shock:false"
    if (message.startsWith('SENSOR:')) {
      try {
        final data = message.substring(7).trim();
        final parts = data.split(',');

        final previousFlame = _flameDetected;
        final previousShock = _shockDetected;

        for (var part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            final sensor = keyValue[0].trim();
            final value = keyValue[1].trim().toLowerCase() == 'true';

            if (mounted) {
              setState(() {
                if (sensor == 'flame') {
                  _flameDetected = value;
                } else if (sensor == 'shock') {
                  _shockDetected = value;
                }
              });
            }
          }
        }

        // Vibrar, mostrar alerta y enviar notificación si hay detección nueva
        if (!previousFlame && _flameDetected) {
          HapticFeedback.vibrate();
          _showMessage('🔥 ¡LLAMA DETECTADA!');
          _enviarNotificacionIncendio();
        }
        if (!previousShock && _shockDetected) {
          HapticFeedback.vibrate();
          _showMessage('📳 ¡VIBRACIÓN DETECTADA!');
          _enviarNotificacionSismo();
        }

        // Resetear flags si los sensores vuelven a normal
        if (previousFlame && !_flameDetected) {
          _notificacionIncendioEnviada = false;
        }
        if (previousShock && !_shockDetected) {
          _notificacionSismoEnviada = false;
        }
      } catch (e) {
        debugPrint('❌ [SENSOR] Error procesando datos: $e');
      }
    } else if (message.trim() == 'OK') {
      // Confirmación de comando ejecutado
      debugPrint('✅ [TCP] Comando ejecutado correctamente');
    }
  }

  Future<void> _connectToRaspberryPi() async {
    try {
      // Intenta conectar al servidor TCP en la Raspberry Pi Pico W
      final connected = await _tcpClient.connect('10.134.222.158', 8080);

      if (mounted) {
        setState(() {
          _isConnected = connected;
        });

        // Solo muestra mensaje si conecta exitosamente
        if (connected) {
          final l10n = AppLocalizations.of(context);
          _showMessage(l10n.connectedToRaspberry);
        }
        // No muestra mensaje de error si no conecta
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
        // Error de conexión silencioso - solo actualiza el estado
      }
    }
  }

  Future<void> _toggleLight(String room) async {
    final currentState = lightStates[room] ?? false;
    final newState = !currentState;
    final pin = _roomToPinMap[room];

    if (pin == null) return;

    if (_isConnected) {
      try {
        // Envía comando al servidor MicroPython
        // Formato: "PIN:ESTADO" ejemplo: "1:ON" o "1:OFF"
        final command = '$pin:${newState ? 'ON' : 'OFF'}\n';
        await _tcpClient.sendMessage(command);

        if (mounted) {
          setState(() {
            lightStates[room] = newState;
          });
          final l10n = AppLocalizations.of(context);
          final roomName = _getRoomName(room, l10n);
          final status = newState ? l10n.turnedOn : l10n.turnedOff;
          _showMessage('$roomName: $status');
        }
      } catch (e) {
        // Error al enviar comando - silencioso
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      }
    } else {
      // Sin conexión - intenta reconectar silenciosamente
      await _connectToRaspberryPi();
    }
  }

  Future<void> _togglePuerta() async {
    if (!_isConnected) {
      _showMessage('No hay conexión con el dispositivo');
      return;
    }

    try {
      final newState = !_puertaAbierta;
      // 0° = cerrada, 90° = abierta
      final angle = newState ? 90 : 0;
      final command = 'SERVO1:$angle\n';

      await _tcpClient.sendMessage(command);

      if (mounted) {
        setState(() {
          _puertaAbierta = newState;
        });
        _showMessage(newState ? '🚪 Puerta Abierta' : '🚪 Puerta Cerrada');
      }
    } catch (e) {
      _showMessage('Error al controlar la puerta');
    }
  }

  Future<void> _toggleGaraje() async {
    if (!_isConnected) {
      _showMessage('No hay conexión con el dispositivo');
      return;
    }

    try {
      final newState = !_garajeAbierto;
      // 90° = cerrado, 180° = abierto
      final angle = newState ? 180 : 90;
      final command = 'SERVO2:$angle\n';

      await _tcpClient.sendMessage(command);

      if (mounted) {
        setState(() {
          _garajeAbierto = newState;
        });
        _showMessage(newState ? '🚗 Garaje Abierto' : '🚗 Garaje Cerrado');
      }
    } catch (e) {
      _showMessage('Error al controlar el garaje');
    }
  }

  String _getRoomName(String roomKey, AppLocalizations l10n) {
    switch (roomKey) {
      case 'garaje':
        return l10n.garage;
      case 'sala':
        return l10n.livingRoom;
      case 'cocina':
        return l10n.kitchen;
      case 'bano1':
        return l10n.bathroom1;
      case 'bano2':
        return l10n.bathroom2;
      case 'cuarto1':
        return l10n.bedroom1;
      case 'cuarto2':
        return l10n.bedroom2;
      case 'cuarto3':
        return l10n.bedroom3;
      default:
        return roomKey.toUpperCase();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// VERSIÓN MEJORADA - Envío de notificación de incendio con mejor manejo de errores
  Future<void> _enviarNotificacionIncendio() async {
    debugPrint('🔥 [NOTIF] ══════════════════════════════════════════');
    debugPrint('🔥 [NOTIF] Iniciando envío de notificación de INCENDIO');

    // 1. Verificar si ya se envió
    if (_notificacionIncendioEnviada) {
      debugPrint('⚠️ [NOTIF] Notificación ya enviada previamente - saltando');
      debugPrint('══════════════════════════════════════════');
      return;
    }

    // 2. Verificar servicio
    if (_reservaService == null) {
      debugPrint('❌ [NOTIF] ERROR: Servicio de reservas NO DISPONIBLE');
      debugPrint('💡 [NOTIF] El servicio no se inicializó correctamente');
      debugPrint('💡 [NOTIF] Revisa los logs de [INIT] para más detalles');
      debugPrint('══════════════════════════════════════════');
      return;
    }

    debugPrint('✅ [NOTIF] Servicio de reservas disponible');

    // 3. Verificar reserva activa
    if (_reservaActiva == null) {
      debugPrint('❌ [NOTIF] ERROR: No hay reserva activa');
      debugPrint(
        '💡 [NOTIF] No se pudo seleccionar una reserva para notificaciones',
      );
      debugPrint('══════════════════════════════════════════');
      return;
    }

    debugPrint('✅ [NOTIF] Reserva activa encontrada: $_reservaActiva');
    debugPrint('📱 [NOTIF] Enviando notificación vía WhatsApp...');

    // 4. Marcar como enviada ANTES de intentar enviar (evita duplicados)
    _notificacionIncendioEnviada = true;

    try {
      // 5. Intentar enviar notificación
      final resultado = await _reservaService!.enviarNotificacionIncendio(
        _reservaActiva!,
      );

      if (resultado.exitoso) {
        debugPrint('✅ [NOTIF] ══════════════════════════════════════════');
        debugPrint('✅ [NOTIF] NOTIFICACIÓN ENVIADA EXITOSAMENTE');
        debugPrint('✅ [NOTIF] Mensaje: ${resultado.mensaje}');
        debugPrint('✅ [NOTIF] ══════════════════════════════════════════');

        if (mounted) {
          _showMessage('📱 Alerta de incendio enviada por WhatsApp');
        }
      } else {
        debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
        debugPrint('❌ [NOTIF] ERROR AL ENVIAR NOTIFICACIÓN');
        debugPrint('❌ [NOTIF] Mensaje: ${resultado.mensaje}');
        debugPrint('❌ [NOTIF] Código: ${resultado.codigoError ?? "N/A"}');
        debugPrint('❌ [NOTIF] ══════════════════════════════════════════');

        if (mounted) {
          _showMessage('Error: ${resultado.mensaje}');
        }

        // Permitir reintentar si falló
        _notificacionIncendioEnviada = false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
      debugPrint('❌ [NOTIF] EXCEPCIÓN AL ENVIAR NOTIFICACIÓN');
      debugPrint('❌ [NOTIF] Error: $e');
      debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('══════════════════════════════════════════');

      // Permitir reintentar si hubo excepción
      _notificacionIncendioEnviada = false;
    }
  }

  /// VERSIÓN MEJORADA - Envío de notificación de sismo con mejor manejo de errores
  Future<void> _enviarNotificacionSismo() async {
    debugPrint('📳 [NOTIF] ══════════════════════════════════════════');
    debugPrint('📳 [NOTIF] Iniciando envío de notificación de SISMO');

    // 1. Verificar si ya se envió
    if (_notificacionSismoEnviada) {
      debugPrint('⚠️ [NOTIF] Notificación ya enviada previamente - saltando');
      debugPrint('══════════════════════════════════════════');
      return;
    }

    // 2. Verificar servicio
    if (_reservaService == null) {
      debugPrint('❌ [NOTIF] ERROR: Servicio de reservas NO DISPONIBLE');
      debugPrint('💡 [NOTIF] El servicio no se inicializó correctamente');
      debugPrint('💡 [NOTIF] Revisa los logs de [INIT] para más detalles');
      debugPrint('══════════════════════════════════════════');
      return;
    }

    debugPrint('✅ [NOTIF] Servicio de reservas disponible');

    // 3. Verificar reserva activa
    if (_reservaActiva == null) {
      debugPrint('❌ [NOTIF] ERROR: No hay reserva activa');
      debugPrint(
        '💡 [NOTIF] No se pudo seleccionar una reserva para notificaciones',
      );
      debugPrint('══════════════════════════════════════════');
      return;
    }

    debugPrint('✅ [NOTIF] Reserva activa encontrada: $_reservaActiva');
    debugPrint('📱 [NOTIF] Enviando notificación vía WhatsApp...');

    // 4. Marcar como enviada ANTES de intentar enviar (evita duplicados)
    _notificacionSismoEnviada = true;

    try {
      // 5. Intentar enviar notificación
      final resultado = await _reservaService!.enviarNotificacionSismo(
        _reservaActiva!,
      );

      if (resultado.exitoso) {
        debugPrint('✅ [NOTIF] ══════════════════════════════════════════');
        debugPrint('✅ [NOTIF] NOTIFICACIÓN ENVIADA EXITOSAMENTE');
        debugPrint('✅ [NOTIF] Mensaje: ${resultado.mensaje}');
        debugPrint('✅ [NOTIF] ══════════════════════════════════════════');

        if (mounted) {
          _showMessage('📱 Alerta de sismo enviada por WhatsApp');
        }
      } else {
        debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
        debugPrint('❌ [NOTIF] ERROR AL ENVIAR NOTIFICACIÓN');
        debugPrint('❌ [NOTIF] Mensaje: ${resultado.mensaje}');
        debugPrint('❌ [NOTIF] Código: ${resultado.codigoError ?? "N/A"}');
        debugPrint('❌ [NOTIF] ══════════════════════════════════════════');

        if (mounted) {
          _showMessage('Error: ${resultado.mensaje}');
        }

        // Permitir reintentar si falló
        _notificacionSismoEnviada = false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
      debugPrint('❌ [NOTIF] EXCEPCIÓN AL ENVIAR NOTIFICACIÓN');
      debugPrint('❌ [NOTIF] Error: $e');
      debugPrint('❌ [NOTIF] ══════════════════════════════════════════');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      debugPrint('══════════════════════════════════════════');

      // Permitir reintentar si hubo excepción
      _notificacionSismoEnviada = false;
    }
  }

  @override
  void dispose() {
    // ✅ SOLO limpia callbacks - NO desconectes (es un Singleton)
    _tcpClient.clearCallbacks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        // ✅ SOLO limpia callbacks al volver atrás - NO desconectes
        _tcpClient.clearCallbacks();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.domoticControl),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // ✅ SOLO limpia callbacks antes de volver - NO desconectes
              _tcpClient.clearCallbacks();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // Indicador de conexión
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            // Botón de reconexión
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _connectToRaspberryPi,
              tooltip: l10n.reconnect,
            ),
          ],
        ),
        body: Stack(
          children: [
            // Contenido principal
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Panel de sensores
                    _buildSensorPanel(l10n),
                    const SizedBox(height: 16),

                    // Plano de la casa con botones
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              // Imagen del plano de la casa
                              Positioned.fill(
                                child: Image.asset(
                                  'lib/assets/icons/house_plan.png',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Garaje - GP1
                              _buildSquareLightButton(
                                'garaje',
                                l10n.garage,
                                left: constraints.maxWidth * 0.336,
                                top: constraints.maxHeight * 0.677,
                                width: constraints.maxHeight * 0.3245,
                                height: constraints.maxHeight * 0.261,
                              ),

                              // Botón Garaje (servo) - En el garaje
                              _buildDoorButtonOnPlan(
                                label: '',
                                icon: Icons.garage,
                                isOpen: _garajeAbierto,
                                onPressed: _toggleGaraje,
                                left: constraints.maxWidth * 0.811,
                                top: constraints.maxHeight * 0.757,
                              ),

                              // Botón Puerta (servo) - En la sala
                              _buildDoorButtonOnPlan(
                                label: '',
                                icon: Icons.door_front_door,
                                isOpen: _puertaAbierta,
                                onPressed: _togglePuerta,
                                left: constraints.maxWidth * 0.811,
                                top: constraints.maxHeight * 0.495,
                              ),

                              // Sala - GP2
                              _buildSquareLightButton(
                                'sala',
                                l10n.livingRoom,
                                left: constraints.maxWidth * 0.338,
                                top: constraints.maxHeight * 0.425,
                                width: constraints.maxHeight * 0.32243,
                                height: constraints.maxHeight * 0.2552,
                              ),

                              // Cocina - GP3
                              _buildSquareLightButton(
                                'cocina',
                                l10n.kitchen,
                                left: constraints.maxWidth * 0.145,
                                top: constraints.maxHeight * 0.425,
                                width: constraints.maxHeight * 0.1345,
                                height: constraints.maxHeight * 0.2561,
                              ),

                              // Baño 1 - GP4
                              _buildSquareLightButton(
                                'bano1',
                                l10n.bathroom1,
                                left: constraints.maxWidth * 0.145,
                                top: constraints.maxHeight * 0.28775,
                                width: constraints.maxHeight * 0.1357,
                                height: constraints.maxHeight * 0.142,
                              ),

                              // Baño 2 - GP5
                              _buildSquareLightButton(
                                'bano2',
                                l10n.bathroom2,
                                left: constraints.maxWidth * 0.553,
                                top: constraints.maxHeight * 0.28775,
                                width: constraints.maxHeight * 0.175,
                                height: constraints.maxHeight * 0.142,
                              ),

                              // Cuarto 1 - GP6
                              _buildSquareLightButton(
                                'cuarto1',
                                l10n.bedroom1,
                                left: constraints.maxWidth * 0.145,
                                top: constraints.maxHeight * 0.104,
                                width: constraints.maxHeight * 0.1345,
                                height: constraints.maxHeight * 0.1883,
                              ),

                              // Cuarto 2 - GP7
                              _buildSquareLightButton(
                                'cuarto2',
                                l10n.bedroom2,
                                left: constraints.maxWidth * 0.338,
                                top: constraints.maxHeight * 0.104,
                                width: constraints.maxHeight * 0.151,
                                height: constraints.maxHeight * 0.1883,
                              ),

                              // Cuarto 3 - GP8
                              _buildSquareLightButton(
                                'cuarto3',
                                l10n.bedroom3,
                                left: constraints.maxWidth * 0.553,
                                top: constraints.maxHeight * 0.104,
                                width: constraints.maxHeight * 0.175,
                                height: constraints.maxHeight * 0.1883,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Alerta de fuego (pantalla completa)
            if (_flameDetected)
              _buildFullScreenAlert(
                color: Colors.red.withOpacity(0.85),
                icon: Icons.local_fire_department,
                title: '¡FUEGO DETECTADO!',
                iconColor: Colors.red.shade900,
              ),

            // Alerta de sismo (pantalla completa)
            if (_shockDetected)
              _buildFullScreenAlert(
                color: Colors.brown.withOpacity(0.85),
                icon: Icons.warning_amber_rounded,
                title: '¡SISMO DETECTADO!',
                iconColor: Colors.brown.shade900,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenAlert({
    required Color color,
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Positioned.fill(
      child: Container(
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 120, color: iconColor),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorPanel(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Indicador de conexión
          _buildConnectionIndicator(l10n),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Sensores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sensor de llama
              _buildSensorIndicator(
                l10n: l10n,
                icon: Icons.local_fire_department,
                label: l10n.flame,
                isActive: _flameDetected,
                activeColor: Colors.red,
              ),

              // Separador
              Container(width: 1, height: 40, color: Colors.grey.shade300),

              // Sensor de vibración
              _buildSensorIndicator(
                l10n: l10n,
                icon: Icons.vibration,
                label: l10n.vibration,
                isActive: _shockDetected,
                activeColor: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isConnected
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isConnected ? l10n.connected : l10n.disconnected,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorIndicator({
    required AppLocalizations l10n,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor.withOpacity(0.2)
                : Colors.grey.shade200,
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? activeColor : Colors.grey.shade600,
            size: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : Colors.grey.shade700,
          ),
        ),
        Text(
          isActive ? l10n.detected : l10n.normal,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? activeColor : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSquareLightButton(
    String roomKey,
    String roomName, {
    double? left,
    double? right,
    double? top,
    double? bottom,
    double width = 52.5,
    double height = 60,
  }) {
    final isOn = lightStates[roomKey] ?? false;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: GestureDetector(
        onTap: () => _toggleLight(roomKey),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white.withOpacity(0.3),
            border: Border.all(
              color: isOn ? Colors.yellow.shade600 : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 28,
                color: isOn ? Colors.amber.shade600 : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                roomName,
                style: TextStyle(
                  fontSize: 11.25, // Aumentado de 9 a 11.25 (25% más grande)
                  fontWeight: FontWeight.bold,
                  color: isOn
                      ? Colors.amber.shade900
                      : AppColors.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoorButtonOnPlan({
    required String label,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onPressed,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isOpen ? Colors.green.shade500 : Colors.grey.shade400,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
