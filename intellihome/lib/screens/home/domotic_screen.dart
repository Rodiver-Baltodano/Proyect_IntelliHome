import 'package:flutter/material.dart';
import 'package:intellihome/config/app_colors.dart';
import 'package:intellihome/l10n/app_localizations.dart';
import 'package:intellihome/modules/autenticacion/services/tcp_client.dart';

class DomoticScreen extends StatefulWidget {
  const DomoticScreen({super.key});

  @override
  State<DomoticScreen> createState() => _DomoticScreenState();
}

class _DomoticScreenState extends State<DomoticScreen> {
  final TcpClient _tcpClient = TcpClient();
  bool _isConnected = false;
  bool _garajeAbierto = false;
  bool _shockDetected = false;
  bool _flameDetected = false;
  bool _puertaAbierta = false;

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
    _setupTcpCallbacks();
    _connectToRaspberryPi();
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

        // Mostrar mensaje si hay detección nueva
        if (!previousFlame && _flameDetected) {
          _showMessage('🔥 ¡LLAMA DETECTADA!');
        }
        if (!previousShock && _shockDetected) {
          _showMessage('📳 ¡VIBRACIÓN DETECTADA!');
        }
      } catch (e) {
        print('Error procesando datos de sensores: $e');
      }
    } else if (message.trim() == 'OK') {
      // Confirmación de comando ejecutado
      print('Comando ejecutado correctamente');
    }
  }

  Future<void> _connectToRaspberryPi() async {
    try {
      // Intenta conectar al servidor TCP en la Raspberry Pi Pico W
      final connected = await _tcpClient.connect('10.243.100.158', 8080);

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
      // 0° = cerrada, 90° = abierta
      final angle = newState ? 90 : 0;
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

  @override
  void dispose() {
    // Limpiar callbacks antes de desconectar
    _tcpClient.onDisconnected = null;
    _tcpClient.onError = null;
    _tcpClient.onMessageReceived = null;
    _tcpClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        // Desconectar antes de volver
        await _tcpClient.disconnect();
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
              // Desconectar antes de volver
              await _tcpClient.disconnect();
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
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Panel de sensores
                _buildSensorPanel(l10n),
                const SizedBox(height: 16),

                // Botones de control de puertas (servos)
                _buildDoorControlPanel(),
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
                          _buildLightButton(
                            'garaje',
                            l10n.garage,
                            left: constraints.maxWidth * 0.50,
                            top: constraints.maxHeight * 0.68,
                          ),

                          // Sala - GP2
                          _buildLightButton(
                            'sala',
                            l10n.livingRoom,
                            left: constraints.maxWidth * 0.50,
                            top: constraints.maxHeight * 0.49,
                          ),

                          // Cocina - GP3
                          _buildLightButton(
                            'cocina',
                            l10n.kitchen,
                            left: constraints.maxWidth * 0.16,
                            top: constraints.maxHeight * 0.49,
                          ),

                          // Baño 1 - GP4
                          _buildLightButton(
                            'bano1',
                            l10n.bathroom1,
                            left: constraints.maxWidth * 0.16,
                            top: constraints.maxHeight * 0.32,
                          ),

                          // Baño 2 - GP5
                          _buildLightButton(
                            'bano2',
                            l10n.bathroom2,
                            left: constraints.maxWidth * 0.60,
                            top: constraints.maxHeight * 0.32,
                          ),

                          // Cuarto 1 - GP6
                          _buildLightButton(
                            'cuarto1',
                            l10n.bedroom1,
                            left: constraints.maxWidth * 0.15,
                            top: constraints.maxHeight * 0.18,
                          ),

                          // Cuarto 2 - GP7
                          _buildLightButton(
                            'cuarto2',
                            l10n.bedroom2,
                            left: constraints.maxWidth * 0.35,
                            top: constraints.maxHeight * 0.18,
                          ),

                          // Cuarto 3 - GP8
                          _buildLightButton(
                            'cuarto3',
                            l10n.bedroom3,
                            left: constraints.maxWidth * 0.60,
                            top: constraints.maxHeight * 0.18,
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
          _buildConnectionIndicator(),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Sensores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sensor de llama
              _buildSensorIndicator(
                icon: Icons.local_fire_department,
                label: 'Llama',
                isActive: _flameDetected,
                activeColor: Colors.red,
              ),

              // Separador
              Container(width: 1, height: 40, color: Colors.grey.shade300),

              // Sensor de vibración
              _buildSensorIndicator(
                icon: Icons.vibration,
                label: 'Vibración',
                isActive: _shockDetected,
                activeColor: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
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
            _isConnected ? 'Conectado' : 'Desconectado',
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
          isActive ? 'DETECTADO' : 'Normal',
          style: TextStyle(
            fontSize: 10,
            color: isActive ? activeColor : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLightButton(
    String roomKey,
    String roomName, {
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final isOn = lightStates[roomKey] ?? false;

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
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
            child: IconButton(
              icon: Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                size: 28,
              ),
              color: isOn ? Colors.amber.shade600 : Colors.grey.shade600,
              onPressed: () => _toggleLight(roomKey),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roomName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorControlPanel() {
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
      child: Row(
        children: [
          // Botón Puerta
          Expanded(
            child: _buildDoorButton(
              label: 'Puerta',
              icon: Icons.door_front_door,
              isOpen: _puertaAbierta,
              onPressed: _togglePuerta,
            ),
          ),
          const SizedBox(width: 12),

          // Botón Garaje
          Expanded(
            child: _buildDoorButton(
              label: 'Garaje',
              icon: Icons.garage,
              isOpen: _garajeAbierto,
              onPressed: _toggleGaraje,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorButton({
    required String label,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOpen ? Colors.green.shade500 : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isOpen ? 4 : 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isOpen ? 'ABIERTA' : 'CERRADA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
