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
  
  // Mapeo de habitaciones a pines GPIO
  final Map<String, int> _roomToPinMap = {
    'garaje': 1,    // GP1
    'sala': 2,      // GP2
    'cocina': 3,    // GP3
    'bano1': 4,     // GP4
    'bano2': 5,     // GP5
    'cuarto1': 6,   // GP6
    'cuarto2': 7,   // GP7
    'cuarto3': 8,   // GP8
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
    _connectToRaspberryPi();
  }

  Future<void> _connectToRaspberryPi() async {
    try {
      // Intenta conectar al servidor TCP en la Raspberry Pi Pico W
      // Cambia esta IP por la IP de tu Raspberry Pi Pico W
      final connected = await _tcpClient.connect('10.243.100.158', 8080);
      
      setState(() {
        _isConnected = connected;
      });

      if (connected) {
        _showMessage('Conectado a Raspberry Pi Pico W');
      } else {
        _showMessage('No se pudo conectar al dispositivo');
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      _showMessage('Error al conectar: $e');
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
        
        setState(() {
          lightStates[room] = newState;
        });
        
        _showMessage('${room.toUpperCase()}: ${newState ? 'Encendido' : 'Apagado'}');
      } catch (e) {
        _showMessage('Error al enviar comando: $e');
      }
    } else {
      _showMessage('No hay conexión con el dispositivo');
      // Intenta reconectar
      await _connectToRaspberryPi();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tcpClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Domótico'),
        centerTitle: true,
        elevation: 0,
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
            tooltip: 'Reconectar',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                    'Garaje',
                    left: constraints.maxWidth * 0.50,
                    top: constraints.maxHeight * 0.68,
                  ),
                  
                  // Sala - GP2
                  _buildLightButton(
                    'sala',
                    'Sala',
                    left: constraints.maxWidth * 0.50,
                    top: constraints.maxHeight * 0.49,
                  ),
                  
                  // Cocina - GP3
                  _buildLightButton(
                    'cocina',
                    'Cocina',
                    left: constraints.maxWidth * 0.16,
                    top: constraints.maxHeight * 0.49,
                  ),
                  
                  // Baño 1 - GP4
                  _buildLightButton(
                    'bano1',
                    'Baño 1',
                    left: constraints.maxWidth * 0.16,
                    top: constraints.maxHeight * 0.32,
                  ),
                  
                  // Baño 2 - GP5
                  _buildLightButton(
                    'bano2',
                    'Baño 2',
                    left: constraints.maxWidth * 0.60,
                    top: constraints.maxHeight * 0.32,
                  ),
                  
                  // Cuarto 1 - GP6
                  _buildLightButton(
                    'cuarto1',
                    'Cuarto 1',
                    left: constraints.maxWidth * 0.15,
                    top: constraints.maxHeight * 0.18,
                  ),
                  
                  // Cuarto 2 - GP7
                  _buildLightButton(
                    'cuarto2',
                    'Cuarto 2',
                    left: constraints.maxWidth * 0.35,
                    top: constraints.maxHeight * 0.18,
                  ),
                  
                  // Cuarto 3 - GP8
                  _buildLightButton(
                    'cuarto3',
                    'Cuarto 3',
                    left: constraints.maxWidth * 0.60,
                    top: constraints.maxHeight * 0.18,
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
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
}